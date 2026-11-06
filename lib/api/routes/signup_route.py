import re

from flask import Blueprint, jsonify, request
from sqlalchemy.exc import IntegrityError
from models import db, Course, Student


signup_bp = Blueprint('signup', __name__)

EMAIL_RE = re.compile(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')


@signup_bp.route('/signup', methods=['POST'])
def signup():
    data = request.get_json(silent=True) or {}
    student_id = str(data.get('student_id') or '').strip()
    email = str(data.get('email') or '').strip().lower()
    course_name = str(data.get('course_name') or '').strip()
    year_of_study = data.get('year_of_study')
    password = data.get('password') or ''

    if not student_id or not email or not course_name or not password or year_of_study is None:
        return jsonify({
            'message': (
                'student_id, email, course_name, year_of_study and password '
                'are required'
            ),
        }), 400
    if len(student_id) > 10:
        return jsonify({'message': 'Student number must be at most 10 characters'}), 400
    if not EMAIL_RE.match(email):
        return jsonify({'message': 'Enter a valid email address'}), 400
    if len(password) < 6:
        return jsonify({'message': 'Password must be at least 6 characters'}), 400
    if isinstance(year_of_study, bool) or not isinstance(year_of_study, int):
        return jsonify({'message': 'Year of study must be a whole number'}), 400
    if year_of_study < 1:
        return jsonify({'message': 'Year of study must be at least 1'}), 400

    # the course must exist in the database (matched by name, ignoring case)
    course = Course.query.filter(
        db.func.lower(Course.course_name) == course_name.lower()
    ).first()
    if course is None:
        return jsonify({'message': 'Selected course does not exist'}), 400
    if year_of_study > course.duration:
        return jsonify({
            'message': f'Year of study must be between 1 and {course.duration}',
        }), 400

    if Student.query.filter_by(student_id=student_id).first():
        return jsonify({'message': 'Student number already registered'}), 409
    if Student.query.filter_by(email=email).first():
        return jsonify({'message': 'Email already registered'}), 409

    student = Student(
        student_id=student_id,
        email=email,
        course_id=course.id,
        year_of_study=year_of_study,
    )
    student.set_password(password)
    db.session.add(student)
    try:
        db.session.commit()
    except IntegrityError:
        db.session.rollback()
        return jsonify({'message': 'Student number or email already registered'}), 409

    return jsonify({'message': 'Account created', 'student_id': student_id}), 201