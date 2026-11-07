import unittest

from flask import Flask

from models import Course, Student, db
from routes.signup_route import signup_bp


class SignupRouteTests(unittest.TestCase):
    def setUp(self):
        self.app = Flask(__name__)
        self.app.config.update(
            TESTING=True,
            SQLALCHEMY_DATABASE_URI='sqlite://',
            SQLALCHEMY_TRACK_MODIFICATIONS=False,
        )
        db.init_app(self.app)
        self.app.register_blueprint(signup_bp)

        with self.app.app_context():
            db.create_all()
            self.course = Course(
                course_name='Computer Science',
                course_code='CS',
                department='Computing',
                duration=4,
            )
            db.session.add(self.course)
            db.session.commit()

        self.client = self.app.test_client()

    def tearDown(self):
        with self.app.app_context():
            db.session.remove()
            db.drop_all()
            db.engine.dispose()

    def signup(self, **overrides):
        data = {
            'student_id': 'S100',
            'email': 'student@example.com',
            'course_name': 'Computer Science',
            'year_of_study': 2,
            'password': 'password',
        }
        data.update(overrides)
        return self.client.post('/signup', json=data)

    def test_year_of_study_is_required(self):
        response = self.signup(year_of_study=None)

        self.assertEqual(response.status_code, 400)
        self.assertIn('year_of_study', response.json['message'])

    def test_year_of_study_must_be_within_course_duration(self):
        response = self.signup(year_of_study=5)

        self.assertEqual(response.status_code, 400)
        self.assertIn('between 1 and 4', response.json['message'])

    def test_signup_persists_year_of_study(self):
        response = self.signup()

        self.assertEqual(response.status_code, 201)
        with self.app.app_context():
            student = Student.query.filter_by(student_id='S100').one()
            self.assertEqual(student.year_of_study, 2)


if __name__ == '__main__':
    unittest.main()
