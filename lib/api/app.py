from datetime import timedelta

from flask import Flask, request, jsonify
from flask_jwt_extended import (
    JWTManager, create_access_token, jwt_required, get_jwt_identity, get_jwt
)
from sqlalchemy.exc import IntegrityError

from models import db, Course, lecture, Student

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///uni_connect.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['JWT_SECRET_KEY'] = 'change-this-to-a-long-random-string'
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = timedelta(hours=12)

db.init_app(app)
jwt = JWTManager(app)

with app.app_context():
    db.create_all()


# ---------- helpers ----------
def as_list(data):
    return data if isinstance(data, list) else [data]


def save_all(rows):
    try:
        db.session.add_all(rows)
        db.session.commit()
        return jsonify({'message': f'{len(rows)} added'}), 201
    except IntegrityError as e:
        db.session.rollback()
        return jsonify({'message': 'Nothing saved: duplicate value',
                        'detail': str(e.orig)}), 400


@app.route('/')
def home():
    return 'uni_connect API is running'


# ---------- COURSES ----------
@app.route('/courses', methods=['POST'])
def add_courses():
    try:
        rows = [Course(
            course_name=d['course_name'], course_code=d['course_code'],
            department=d['department'], description=d.get('description'),
            duration=d['duration'],
        ) for d in as_list(request.get_json())]
    except KeyError as e:
        return jsonify({'message': f'Missing field: {e}'}), 400
    return save_all(rows)


@app.route('/courses', methods=['GET'])
def list_courses():
    return jsonify([
        {'id': c.id, 'course_code': c.course_code, 'course_name': c.course_name,
         'department': c.department, 'duration': c.duration}
        for c in Course.query.all()
    ])


# ---------- LECTURERS ----------
@app.route('/lecturers', methods=['POST'])
def add_lecturers():
    rows = []
    try:
        for d in as_list(request.get_json()):
            if not db.session.get(Course, d['course_id']):
                return jsonify({'message': f"course_id {d['course_id']} does not exist"}), 400
            l = lecture(
                lecture_id=d['lecture_id'], lecture_name=d['lecture_name'],
                department=d['department'], course_id=d['course_id'],
            )
            l.set_password(d['password'])
            rows.append(l)
    except KeyError as e:
        return jsonify({'message': f'Missing field: {e}'}), 400
    return save_all(rows)


@app.route('/lecturers', methods=['GET'])
def list_lecturers():
    return jsonify([
        {'id': l.id, 'lecture_id': l.lecture_id, 'name': l.lecture_name,
         'department': l.department, 'course_id': l.course_id}
        for l in lecture.query.all()
    ])


# ---------- STUDENTS ----------
@app.route('/students', methods=['POST'])
def add_students():
    rows = []
    try:
        for d in as_list(request.get_json()):
            if not db.session.get(Course, d['course_id']):
                return jsonify({'message': f"course_id {d['course_id']} does not exist"}), 400
            s = Student(
                student_id=d['student_id'], first_name=d['first_name'],
                last_name=d['last_name'], email=d['email'],
                course_id=d['course_id'], year_of_study=d['year_of_study'],
            )
            s.set_password(d['password'])
            rows.append(s)
    except KeyError as e:
        return jsonify({'message': f'Missing field: {e}'}), 400
    return save_all(rows)


@app.route('/students', methods=['GET'])
def list_students():
    return jsonify([
        {'id': s.id, 'student_id': s.student_id,
         'name': f'{s.first_name} {s.last_name}', 'email': s.email,
         'course_id': s.course_id, 'year_of_study': s.year_of_study}
        for s in Student.query.all()
    ])


# ---------- LOGIN ----------
@app.route('/login', methods=['POST'])
def login():
    data = request.get_json() or {}
    role = data.get('role')
    user_id = (data.get('id') or '').strip()
    password = data.get('password') or ''

    if role == 'student':
        person = Student.query.filter_by(student_id=user_id).first()
        name = f'{person.first_name} {person.last_name}' if person else None
    elif role == 'lecturer':
        person = lecture.query.filter_by(lecture_id=user_id).first()
        name = person.lecture_name if person else None
    else:
        return jsonify({'message': 'Unknown role'}), 400

    if person is None or not person.check_password(password):
        return jsonify({'message': 'Invalid ID or password'}), 401

    token = create_access_token(identity=user_id, additional_claims={'role': role})
    return jsonify({'token': token, 'role': role, 'id': user_id, 'name': name}), 200


@app.route('/me', methods=['GET'])
@jwt_required()
def me():
    return jsonify({'id': get_jwt_identity(), 'role': get_jwt()['role']})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)