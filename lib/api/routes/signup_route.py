from flask import Blueprint, jsonify, request
from sqlalchemy.exc import IntegrityError
from models import db, Course, Student


signup_bp = Blueprint('signup', __name__)


@signup_bp.route('/signup', methods=['POST'])
def signup():
    data = request.get_json(silent=True) or {}
    student_id = str(data.get('student_id') or '').strip()
    password = data.get('password') or ''
    course_code = str(data.get('course_code') or '').strip()
    course_id = data.get('course_id')

    if not student_id or not password or not (course_code or course_id):
        return jsonify({'message': 'student_id, password and course_code are required'}), 400
    if len(student_id) > 20:
        return jsonify({'message': 'student_id is too long (max 20 characters)'}), 400
    if len(password) < 6:
        return jsonify({'message': 'Password must be at least 6 characters'}), 400

    # find the course by code (case-insensitive), or by id if that was sent instead
    if course_code:
        course = Course.query.filter(
            db.func.upper(Course.course_code) == course_code.upper()
        ).first()
    else:
        course = db.session.get(Course, course_id)
    if course is None:
        return jsonify({'message': 'Selected course does not exist'}), 400

    if Student.query.filter_by(student_id=student_id).first():
        return jsonify({'message': 'Student ID already registered'}), 409

    student = Student(student_id=student_id, course_id=course.id)
    student.set_password(password)
    db.session.add(student)
    try:
        db.session.commit()
    except IntegrityError:
        db.session.rollback()
        return jsonify({'message': 'Student ID already registered'}), 409

    return jsonify({'message': 'Account created', 'student_id': student_id}), 201