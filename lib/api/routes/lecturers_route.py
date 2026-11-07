import re

from flask import Blueprint, jsonify, request
from sqlalchemy.exc import IntegrityError

from models import db, lecture, Course

lecturer_bp = Blueprint('lecturer', __name__)

EMAIL_RE    = re.compile(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
USERNAME_RE = re.compile(r'^[a-zA-Z0-9_.-]{3,30}$')


@lecturer_bp.route('/signup/lecturer', methods=['POST'])
def signup_lecturer():
    data = request.get_json(silent=True) or {}

    name        = str(data.get('lecture_name') or '').strip()
    department  = str(data.get('department') or '').strip()
    email       = str(data.get('email') or '').strip().lower()
    username    = str(data.get('username') or '').strip()
    password    = data.get('password') or ''

    # courses = list of course_codes OR single course_code
    raw_courses = data.get('course_codes') or data.get('course_code') or []
    if isinstance(raw_courses, str):
        raw_courses = [raw_courses]
    course_codes = [str(c).strip().upper() for c in raw_courses if str(c).strip()]

    # ---- validate ----
    if not all([name, department, email, username, password]):
        return jsonify({'message': 'lecture_name, department, email, username and password are required'}), 400
    if not EMAIL_RE.match(email):
        return jsonify({'message': 'Enter a valid email address'}), 400
    if not USERNAME_RE.match(username):
        return jsonify({'message': 'Username must be 3–30 chars: letters, digits, . _ -'}), 400
    if len(password) < 6:
        return jsonify({'message': 'Password must be at least 6 characters'}), 400
    if not course_codes:
        return jsonify({'message': 'At least one course_code is required'}), 400

    # ---- resolve courses ----
    courses = Course.query.filter(Course.course_code.in_(course_codes)).all()
    found_codes = {c.course_code for c in courses}
    missing = [c for c in course_codes if c not in found_codes]
    if missing:
        return jsonify({'message': f'Unknown course_code(s): {missing}'}), 400

    # ---- duplicate checks ----
    if lecture.query.filter_by(username=username).first():
        return jsonify({'message': 'Username already taken'}), 409
    if lecture.query.filter_by(email=email).first():
        return jsonify({'message': 'Email already registered'}), 409

    # ---- create ----
    lec = lecture(
        lecture_name=name,
        department=department,
        email=email,
        username=username,
    )
    lec.set_password(password)
    lec.courses = courses           # attach all selected programs
    db.session.add(lec)
    try:
        db.session.commit()
    except IntegrityError:
        db.session.rollback()
        return jsonify({'message': 'Username or email already registered'}), 409

    return jsonify({
        'message': 'Lecturer account created',
        'username': lec.username,
        'lecture_name': lec.lecture_name,
        'department': lec.department,
        'email': lec.email,
        'course_codes': [c.course_code for c in lec.courses],
    }), 201


@lecturer_bp.route('/lecturers', methods=['GET'])
def list_lecturers():
    rows = lecture.query.order_by(lecture.username).all()
    return jsonify([{
        'id': l.id,
        'username': l.username,
        'name': l.lecture_name,
        'department': l.department,
        'email': l.email,
        'course_codes': [c.course_code for c in l.courses],
    } for l in rows])