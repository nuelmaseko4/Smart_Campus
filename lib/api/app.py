import os
from datetime import timedelta
from urllib.parse import urlparse

from flask import Flask, request
from flask_jwt_extended import JWTManager
from sqlalchemy import inspect, text

from models import db
from routes.auth_route import auth_bp
from routes.courses_route import courses_bp
from routes.lecturers_route import lecturer_bp
from routes.rooms_route import rooms_bp
from routes.signup_route import signup_bp
from routes.students_route import students_bp
from routes.timetable_route import timetable_bp


def create_app(config_overrides=None):
    app = Flask(__name__)
    app.config.from_mapping(
        SQLALCHEMY_DATABASE_URI='sqlite:///uni_connect.db',
        SQLALCHEMY_TRACK_MODIFICATIONS=False,
        JWT_SECRET_KEY='hjh7ggfgbnbjbnj889876',
        JWT_ACCESS_TOKEN_EXPIRES=timedelta(hours=12),
        RFID_READER_API_KEY=os.getenv('RFID_READER_API_KEY'),
        TIMETABLE_ADMIN_API_KEY=os.getenv('TIMETABLE_ADMIN_API_KEY'),
    )
    if config_overrides:
        app.config.update(config_overrides)

    db.init_app(app)
    JWTManager(app)

    for bp in (
        auth_bp,
        courses_bp,
        lecturer_bp,
        rooms_bp,
        signup_bp,
        students_bp,
        timetable_bp,
    ):
        app.register_blueprint(bp)

    with app.app_context():
        db.create_all()
        student_columns = {
            column['name'] for column in inspect(db.engine).get_columns('students')
        }
        if 'year_of_study' not in student_columns:
            with db.engine.begin() as connection:
                connection.execute(text(
                    'ALTER TABLE students ADD COLUMN '
                    'year_of_study INTEGER NOT NULL DEFAULT 1'
                ))
        timetable_columns = {
            column['name']
            for column in inspect(db.engine).get_columns('timetables')
        }
        with db.engine.begin() as connection:
            if 'year_of_study' not in timetable_columns:
                connection.execute(text(
                    'ALTER TABLE timetables ADD COLUMN '
                    'year_of_study INTEGER NOT NULL DEFAULT 1'
                ))
            if 'semester' not in timetable_columns:
                connection.execute(text(
                    'ALTER TABLE timetables ADD COLUMN '
                    'semester INTEGER NOT NULL DEFAULT 1'
                ))

    @app.after_request
    def add_local_development_cors(response):
        origin = request.headers.get('Origin')
        if origin:
            parsed_origin = urlparse(origin)
            if parsed_origin.hostname in {'localhost', '127.0.0.1', '::1'}:
                response.headers['Access-Control-Allow-Origin'] = origin
                response.headers['Access-Control-Allow-Headers'] = (
                    'Content-Type, Authorization, X-Reader-Token, '
                    'X-Timetable-Admin-Key'
                )
                response.headers['Access-Control-Allow-Methods'] = (
                    'GET, POST, PATCH, OPTIONS'
                )
                response.headers.add('Vary', 'Origin')
        return response

    @app.route('/')
    def home():
        return 'uni_connect API is running'

    return app


app = create_app()

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
