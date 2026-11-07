import unittest

from flask import Flask

from models import Course, Timetable, db, lecture, rooms
from routes.timetable_route import timetable_bp


class TimetableRouteTests(unittest.TestCase):
    def setUp(self):
        self.app = Flask(__name__)
        self.app.config.update(
            TESTING=True,
            SQLALCHEMY_DATABASE_URI='sqlite://',
            SQLALCHEMY_TRACK_MODIFICATIONS=False,
            TIMETABLE_ADMIN_API_KEY='test-timetable-key',
        )
        db.init_app(self.app)
        self.app.register_blueprint(timetable_bp)

        with self.app.app_context():
            db.create_all()
            self.course = Course(
                course_name='Computer Science',
                course_code='CS',
                department='Computing',
                duration=4,
            )
            self.lecturer = lecture(
                username='lecturer',
                password_hash='unused',
                lecture_name='Lecturer Name',
                department='Computing',
                email='lecturer@example.com',
            )
            self.other_lecturer = lecture(
                username='lecturer2',
                password_hash='unused',
                lecture_name='Other Lecturer',
                department='Computing',
                email='lecturer2@example.com',
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
            db.session.add_all([
                self.course,
                self.lecturer,
                self.other_lecturer,
                self.room,
                self.other_room,
            ])
            db.session.commit()
            self.course_id = self.course.id
            self.lecturer_id = self.lecturer.id
            self.other_lecturer_id = self.other_lecturer.id
            self.room_id = self.room.id
            self.other_room_id = self.other_room.id

        self.client = self.app.test_client()

    def tearDown(self):
        with self.app.app_context():
            db.session.remove()
            db.drop_all()
            db.engine.dispose()

    def headers(self, key='test-timetable-key'):
        return {'X-Timetable-Admin-Key': key}

    def entry(self, **overrides):
        data = {
            'course_id': self.course_id,
            'lecture_id': self.lecturer_id,
            'room_id': self.room_id,
            'year_of_study': 1,
            'semester': 1,
            'unit_name': 'Programming',
            'start_time': '2026-11-03T09:00:00',
            'end_time': '2026-11-03T10:00:00',
        }
        data.update(overrides)
        return data

    def test_postman_can_add_and_list_a_timetable_entry(self):
        response = self.client.post(
            '/timetables',
            json=self.entry(),
            headers=self.headers(),
        )

        self.assertEqual(response.status_code, 201)
        self.assertEqual(response.json['count'], 1)
        self.assertEqual(response.json['entries'][0]['year_of_study'], 1)

        listed = self.client.get('/timetables?course_id=1&year_of_study=1')
        self.assertEqual(listed.status_code, 200)
        self.assertEqual(len(listed.json), 1)
        self.assertEqual(listed.json[0]['unit_name'], 'Programming')

    def test_post_requires_admin_key(self):
        response = self.client.post('/timetables', json=self.entry())

        self.assertEqual(response.status_code, 401)

    def test_rejects_year_beyond_program_duration(self):
        response = self.client.post(
            '/timetables',
            json=self.entry(year_of_study=5),
            headers=self.headers(),
        )

        self.assertEqual(response.status_code, 400)
        self.assertIn('between 1 and 4', response.json['message'])

    def test_rejects_room_overlap(self):
        first = self.client.post(
            '/timetables',
            json=self.entry(),
            headers=self.headers(),
        )
        self.assertEqual(first.status_code, 201)

        response = self.client.post(
            '/timetables',
            json=self.entry(
                lecture_id=self.other_lecturer_id,
                start_time='2026-11-03T09:30:00',
                end_time='2026-11-03T10:30:00',
            ),
            headers=self.headers(),
        )

        self.assertEqual(response.status_code, 409)

    def test_bulk_entries_are_saved_atomically(self):
        rows = [
            self.entry(),
            self.entry(
                room_id=self.other_room_id,
                lecture_id=self.lecturer_id,
                start_time='2026-11-03T09:30:00',
                end_time='2026-11-03T10:30:00',
            ),
        ]
        response = self.client.post(
            '/timetables',
            json=rows,
            headers=self.headers(),
        )

        self.assertEqual(response.status_code, 409)
        with self.app.app_context():
            self.assertEqual(Timetable.query.count(), 0)

    def test_rejects_timezone_aware_schedule_times(self):
        response = self.client.post(
            '/timetables',
            json=self.entry(start_time='2026-11-03T09:00:00+02:00'),
            headers=self.headers(),
        )

        self.assertEqual(response.status_code, 400)


if __name__ == '__main__':
    unittest.main()
