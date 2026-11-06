import unittest
from datetime import datetime, timedelta

from flask import Flask
from flask_jwt_extended import create_access_token
from flask_jwt_extended import JWTManager

from models import (
    Course,
    Gate,
    Student,
    Timetable,
    db,
    lecture,
    rfid_card,
    rooms,
)
from routes.auth_route import auth_bp
from routes.rooms_route import rooms_bp
from routes.students_route import students_bp


class StudentApiTests(unittest.TestCase):
    def setUp(self):
        self.app = Flask(__name__)
        self.app.config.update(
            TESTING=True,
            SQLALCHEMY_DATABASE_URI='sqlite://',
            SQLALCHEMY_TRACK_MODIFICATIONS=False,
            JWT_SECRET_KEY='test-secret-for-student-api-tests-32-bytes',
            RFID_READER_API_KEY='test-reader-secret',
        )
        db.init_app(self.app)
        JWTManager(self.app)
        self.app.register_blueprint(auth_bp)
        self.app.register_blueprint(rooms_bp)
        self.app.register_blueprint(students_bp)

        with self.app.app_context():
            db.create_all()
            self.course = Course(
                course_name='Computer Science',
                course_code='CS',
                department='Computing',
                duration=4,
            )
            self.other_course = Course(
                course_name='Accounting',
                course_code='ACC',
                department='Business',
                duration=3,
            )
            db.session.add_all([self.course, self.other_course])
            db.session.flush()

            self.lecturer = lecture(
                username='lecturer',
                password_hash='unused',
                lecture_name='Lecturer Name',
                department='Computing',
                email='lecturer@example.com',
            )
            self.room = rooms(
                room_name='R101',
                capacity=30,
                building='Main',
            )
            self.other_room = rooms(
                room_name='R102',
                capacity=20,
                building='Main',
            )
            self.gate = Gate(access_point='North entrance')
            self.student = Student(
                student_id='S100',
                email='student@example.com',
                course_id=self.course.id,
            )
            self.student.set_password('password')
            db.session.add_all([
                self.lecturer,
                self.room,
                self.other_room,
                self.gate,
                self.student,
            ])
            db.session.flush()

            now = datetime.now()
            self.timetable = Timetable(
                course_id=self.course.id,
                lecture_id=self.lecturer.id,
                room_id=self.room.id,
                start_time=now - timedelta(minutes=10),
                end_time=now + timedelta(minutes=50),
                unit_name='Programming',
            )
            db.session.add(self.timetable)
            db.session.flush()
            self.timetable_id = self.timetable.id
            self.other_course_id = self.other_course.id
            self.card = rfid_card(
                card_id='CARD-100',
                student_id=self.student.student_id,
                issued_at=now,
                status='active',
            )
            db.session.add(self.card)
            db.session.commit()

            self.student_token = create_access_token(
                identity=self.student.student_id,
                additional_claims={'role': 'student'},
            )
            self.lecturer_token = create_access_token(
                identity=self.lecturer.username,
                additional_claims={'role': 'lecturer'},
            )

        self.client = self.app.test_client()

    def tearDown(self):
        with self.app.app_context():
            db.session.remove()
            db.drop_all()
            db.engine.dispose()

    def auth_headers(self, token=None):
        return {'Authorization': f'Bearer {token or self.student_token}'}

    def test_profile_and_email_update_are_student_scoped(self):
        response = self.client.get(
            '/students/me',
            headers=self.auth_headers(),
        )
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json['student_id'], 'S100')
        self.assertEqual(response.json['course']['code'], 'CS')

        response = self.client.patch(
            '/students/me',
            headers=self.auth_headers(),
            json={'email': 'updated@example.com'},
        )
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json['email'], 'updated@example.com')

    def test_non_student_cannot_read_student_profile(self):
        response = self.client.get(
            '/students/me',
            headers=self.auth_headers(self.lecturer_token),
        )
        self.assertEqual(response.status_code, 403)

    def test_timetable_only_contains_student_course(self):
        response = self.client.get(
            '/students/me/timetable',
            headers=self.auth_headers(),
        )
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.json), 1)
        self.assertEqual(response.json[0]['unit_name'], 'Programming')
        self.assertEqual(response.json[0]['room']['name'], 'R101')

    def test_room_availability_excludes_overlapping_class(self):
        start = (datetime.now() - timedelta(minutes=5)).isoformat()
        end = (datetime.now() + timedelta(minutes=5)).isoformat()
        response = self.client.get(
            '/rooms/availability',
            query_string={'start_time': start, 'end_time': end},
            headers=self.auth_headers(),
        )
        self.assertEqual(response.status_code, 200)
        self.assertEqual(
            [room['room_name'] for room in response.json['rooms']],
            ['R102'],
        )

    def test_rfid_checkin_requires_reader_key_and_records_once(self):
        payload = {
            'card_id': 'CARD-100',
            'timetable_id': self.timetable_id,
        }
        response = self.client.post('/rfid/check-in', json=payload)
        self.assertEqual(response.status_code, 401)

        headers = {'X-Reader-Token': 'test-reader-secret'}
        response = self.client.post(
            '/rfid/check-in',
            json=payload,
            headers=headers,
        )
        self.assertEqual(response.status_code, 201)
        self.assertEqual(response.json['status'], 'present')

        response = self.client.post(
            '/rfid/check-in',
            json=payload,
            headers=headers,
        )
        self.assertEqual(response.status_code, 409)

        response = self.client.get(
            '/students/me/attendance',
            headers=self.auth_headers(),
        )
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json['summary']['present'], 1)
        self.assertEqual(len(response.json['records']), 1)

    def test_rfid_checkin_rejects_card_for_another_course(self):
        with self.app.app_context():
            student = Student.query.filter_by(student_id='S100').one()
            student.course_id = self.other_course_id
            db.session.commit()

        response = self.client.post(
            '/rfid/check-in',
            json={
                'card_id': 'CARD-100',
                'timetable_id': self.timetable_id,
            },
            headers={'X-Reader-Token': 'test-reader-secret'},
        )
        self.assertEqual(response.status_code, 403)

    def test_rfid_gate_entry_records_scan_for_student_history(self):
        response = self.client.post(
            '/rfid/gate-entry',
            json={
                'card_id': 'CARD-100',
                'access_point': 'North entrance',
            },
        )
        self.assertEqual(response.status_code, 401)

        response = self.client.post(
            '/rfid/gate-entry',
            json={
                'card_id': 'CARD-100',
                'access_point': 'North entrance',
            },
            headers={'X-Reader-Token': 'test-reader-secret'},
        )
        self.assertEqual(response.status_code, 201)
        self.assertTrue(response.json['access_granted'])

        response = self.client.get(
            '/students/me/gate-entries',
            headers=self.auth_headers(),
        )
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.json), 1)
        self.assertEqual(response.json[0]['access_point'], 'North entrance')

    def test_room_availability_requires_student_login(self):
        response = self.client.get(
            '/rooms/availability',
            query_string={
                'start_time': datetime.now().isoformat(),
                'end_time': (datetime.now() + timedelta(hours=1)).isoformat(),
            },
        )
        self.assertEqual(response.status_code, 401)


if __name__ == '__main__':
    unittest.main()
