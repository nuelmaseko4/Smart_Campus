from datetime import datetime, timedelta
import hmac
import re

from flask import Blueprint, current_app, jsonify, request
from flask_jwt_extended import get_jwt, get_jwt_identity, jwt_required
from sqlalchemy import not_
from sqlalchemy.exc import IntegrityError

from models import (
    Attendance,
    Course,
    Gate,
    GateEntry,
    Student,
    Timetable,
    db,
    rfid_card,
    rooms,
)
from utils import as_list, save_all, student_name

students_bp = Blueprint('students', __name__)
EMAIL_RE = re.compile(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
CHECK_IN_EARLY_WINDOW = timedelta(minutes=15)


def current_student():
    if get_jwt().get('role') != 'student':
        return None, (jsonify({'message': 'Student access is required'}), 403)

    student = Student.query.filter_by(student_id=get_jwt_identity()).first()
    if student is None:
        return None, (jsonify({'message': 'Student account not found'}), 404)
    return student, None


def parse_local_datetime(value):
    if not value:
        return None, (jsonify({
            'message': 'start_time and end_time are required as local ISO datetimes',
        }), 400)
    try:
        parsed = datetime.fromisoformat(value)
    except ValueError:
        return None, (jsonify({
            'message': 'Use a valid local ISO datetime, for example 2026-03-20T09:00:00',
        }), 400)
    if parsed.tzinfo is not None:
        return None, (jsonify({
            'message': 'Use timezone-free local campus time',
        }), 400)
    return parsed, None


# admin / Postman use. Students sign themselves up through /signup.
@students_bp.route('/students', methods=['POST'])
def add_students():
    rows = []
    try:
        for d in as_list(request.get_json()):
            if not db.session.get(Course, d['course_id']):
                return jsonify({'message': f"course_id {d['course_id']} does not exist"}), 400
            s = Student(
                student_id=d['student_id'], course_id=d['course_id'],
                first_name=d.get('first_name'), last_name=d.get('last_name'),
                year_of_study=d.get('year_of_study', 1),
            )
            s.set_password(d['password'])
            rows.append(s)
    except ValueError as e:
        return jsonify({'message': str(e)}), 400
    except KeyError as e:
        return jsonify({'message': f'Missing field: {e}'}), 400
    return save_all(rows)


@students_bp.route('/students', methods=['GET'])
def list_students():
    return jsonify([
        {'id': s.id, 'student_id': s.student_id, 'name': student_name(s),
         'course_id': s.course_id, 'year_of_study': s.year_of_study}
        for s in Student.query.all()
    ])


@students_bp.route('/students/me', methods=['GET'])
@jwt_required()
def get_student_profile():
    student, error = current_student()
    if error:
        return error

    course = db.session.get(Course, student.course_id)
    return jsonify({
        'student_id': student.student_id,
        'email': student.email,
        'year_of_study': student.year_of_study,
        'course': {
            'id': course.id,
            'name': course.course_name,
            'code': course.course_code,
        },
    }), 200


@students_bp.route('/students/me', methods=['PATCH'])
@jwt_required()
def update_student_profile():
    student, error = current_student()
    if error:
        return error

    data = request.get_json(silent=True)
    if not isinstance(data, dict) or set(data) != {'email'}:
        return jsonify({'message': 'Provide only the email field'}), 400

    email = str(data.get('email') or '').strip().lower()
    if not EMAIL_RE.match(email):
        return jsonify({'message': 'Enter a valid email address'}), 400

    existing_student = Student.query.filter(
        db.func.lower(Student.email) == email,
        Student.student_id != student.student_id,
    ).first()
    if existing_student:
        return jsonify({'message': 'Email already registered'}), 409

    student.email = email
    try:
        db.session.commit()
    except IntegrityError:
        db.session.rollback()
        return jsonify({'message': 'Email already registered'}), 409

    return jsonify({
        'message': 'Profile updated',
        'student_id': student.student_id,
        'email': student.email,
    }), 200


@students_bp.route('/students/me/timetable', methods=['GET'])
@jwt_required()
def get_student_timetable():
    student, error = current_student()
    if error:
        return error

    timetable = (
        Timetable.query
        .filter_by(
            course_id=student.course_id,
            year_of_study=student.year_of_study,
        )
        .order_by(Timetable.start_time.asc())
        .all()
    )
    return jsonify([{
        'id': item.id,
        'course_id': item.course_id,
        'year_of_study': item.year_of_study,
        'semester': item.semester,
        'course_name': item.course.course_name,
        'unit_name': item.unit_name,
        'lecturer': item.lecture.lecture_name,
        'room': {
            'id': item.room.id,
            'name': item.room.room_name,
            'building': item.room.building,
        },
        'start_time': item.start_time.isoformat(),
        'end_time': item.end_time.isoformat(),
    } for item in timetable]), 200


@students_bp.route('/students/me/attendance', methods=['GET'])
@jwt_required()
def get_student_attendance():
    student, error = current_student()
    if error:
        return error

    rows = (
        db.session.query(Attendance, Timetable)
        .join(Timetable, Attendance.timetable_id == Timetable.id)
        .filter(Attendance.student_id == student.student_id)
        .order_by(Timetable.start_time.desc())
        .all()
    )
    records = [{
        'id': attendance.id,
        'timetable_id': timetable.id,
        'course_name': timetable.course.course_name,
        'unit_name': timetable.unit_name,
        'room_name': timetable.room.room_name,
        'start_time': timetable.start_time.isoformat(),
        'end_time': timetable.end_time.isoformat(),
        'status': attendance.status,
    } for attendance, timetable in rows]

    return jsonify({
        'summary': {
            'total': len(records),
            'present': sum(item['status'] == 'present' for item in records),
            'late': sum(item['status'] == 'late' for item in records),
            'absent': sum(item['status'] == 'absent' for item in records),
        },
        'records': records,
    }), 200


@students_bp.route('/students/me/gate-entries', methods=['GET'])
@jwt_required()
def get_student_gate_entries():
    student, error = current_student()
    if error:
        return error

    entries = (
        GateEntry.query
        .filter_by(student_id=student.student_id)
        .order_by(GateEntry.scanned_at.desc())
        .all()
    )
    return jsonify([{
        'id': entry.id,
        'access_point': entry.gate.access_point,
        'scanned_at': entry.scanned_at.isoformat(),
    } for entry in entries]), 200


@students_bp.route('/rooms/availability', methods=['GET'])
@jwt_required()
def room_availability():
    _, error = current_student()
    if error:
        return error

    start_time, error = parse_local_datetime(request.args.get('start_time'))
    if error:
        return error
    end_time, error = parse_local_datetime(request.args.get('end_time'))
    if error:
        return error
    if start_time >= end_time:
        return jsonify({'message': 'start_time must be before end_time'}), 400

    occupied_room_ids = (
        db.session.query(Timetable.room_id)
        .filter(
            Timetable.start_time < end_time,
            Timetable.end_time > start_time,
        )
        .distinct()
    )
    available_rooms = (
        rooms.query
        .filter(not_(rooms.id.in_(occupied_room_ids)))
        .order_by(rooms.room_name.asc())
        .all()
    )
    return jsonify({
        'start_time': start_time.isoformat(),
        'end_time': end_time.isoformat(),
        'rooms': [{
            'id': room.id,
            'room_name': room.room_name,
            'building': room.building,
            'capacity': room.capacity,
        } for room in available_rooms],
    }), 200


def check_reader_token():
    expected_token = current_app.config.get('RFID_READER_API_KEY')
    if not expected_token:
        return jsonify({'message': 'RFID reader API is not configured'}), 503

    supplied_token = request.headers.get('X-Reader-Token', '')
    if not hmac.compare_digest(str(expected_token), supplied_token):
        return jsonify({'message': 'Invalid RFID reader credentials'}), 401
    return None


@students_bp.route('/rfid/check-in', methods=['POST'])
def rfid_check_in():
    error = check_reader_token()
    if error:
        return error

    data = request.get_json(silent=True)
    if not isinstance(data, dict):
        return jsonify({'message': 'A JSON object is required'}), 400

    card_id = str(data.get('card_id') or '').strip()
    timetable_id = data.get('timetable_id')
    if not card_id or type(timetable_id) is not int or timetable_id < 1:
        return jsonify({
            'message': 'card_id and a positive integer timetable_id are required',
        }), 400

    card = rfid_card.query.filter_by(card_id=card_id, status='active').first()
    if card is None:
        return jsonify({'message': 'Active RFID card not found'}), 404

    student = Student.query.filter_by(student_id=card.student_id).first()
    timetable = db.session.get(Timetable, timetable_id)
    if student is None or timetable is None:
        return jsonify({'message': 'Student or timetable entry not found'}), 404
    if timetable.course_id != student.course_id:
        return jsonify({'message': 'Student is not enrolled in this class'}), 403

    now = datetime.now()
    if now < timetable.start_time - CHECK_IN_EARLY_WINDOW or now > timetable.end_time:
        return jsonify({'message': 'This class is not currently accepting check-ins'}), 409

    existing = Attendance.query.filter_by(
        timetable_id=timetable.id,
        student_id=student.student_id,
    ).first()
    if existing:
        return jsonify({'message': 'Attendance has already been recorded'}), 409

    attendance = Attendance(
        timetable_id=timetable.id,
        student_id=student.student_id,
        status='present',
    )
    db.session.add(attendance)
    db.session.commit()

    return jsonify({
        'message': 'Attendance recorded',
        'student_id': student.student_id,
        'timetable_id': timetable.id,
        'status': attendance.status,
    }), 201


@students_bp.route('/rfid/gate-entry', methods=['POST'])
def rfid_gate_entry():
    error = check_reader_token()
    if error:
        return error

    data = request.get_json(silent=True)
    if not isinstance(data, dict):
        return jsonify({'message': 'A JSON object is required'}), 400

    card_id = str(data.get('card_id') or '').strip()
    access_point = str(data.get('access_point') or '').strip()
    if not card_id or not access_point:
        return jsonify({
            'message': 'card_id and access_point are required',
        }), 400

    card = rfid_card.query.filter_by(card_id=card_id, status='active').first()
    if card is None:
        return jsonify({'message': 'Active RFID card not found'}), 404

    gate = Gate.query.filter_by(access_point=access_point).first()
    if gate is None:
        return jsonify({'message': 'Gate access point not found'}), 404

    student = Student.query.filter_by(student_id=card.student_id).first()
    if student is None:
        return jsonify({'message': 'Student account not found'}), 404

    entry = GateEntry(gate_id=gate.id, student_id=student.student_id)
    db.session.add(entry)
    db.session.commit()

    return jsonify({
        'message': 'Gate entry recorded',
        'access_granted': True,
        'student_id': student.student_id,
        'access_point': gate.access_point,
        'scanned_at': entry.scanned_at.isoformat(),
    }), 201
