from datetime import datetime
import hmac

from flask import Blueprint, current_app, jsonify, request
from sqlalchemy import or_
from sqlalchemy.exc import IntegrityError

from models import Course, Timetable, db, lecture, rooms

timetable_bp = Blueprint('timetable', __name__)

REQUIRED_FIELDS = {
    'course_id',
    'lecture_id',
    'room_id',
    'unit_name',
    'start_time',
    'end_time',
    'year_of_study',
    'semester',
}


def positive_integer(value, field):
    if isinstance(value, bool) or not isinstance(value, int) or value < 1:
        return None, jsonify({
            'message': f'{field} must be a positive whole number',
        }), 400
    return value, None, None


def parse_timetable_datetime(value, field):
    if not isinstance(value, str) or not value.strip():
        return None, jsonify({'message': f'{field} must be a local ISO datetime'}), 400
    try:
        parsed = datetime.fromisoformat(value)
    except ValueError:
        return None, jsonify({
            'message': f'{field} must be a valid ISO datetime, for example '
            '2026-11-03T09:00:00',
        }), 400
    if parsed.tzinfo is not None:
        return None, jsonify({
            'message': f'{field} must use timezone-free local campus time',
        }), 400
    return parsed, None, None


def has_schedule_conflict(candidate, pending, room, lecturer):
    conflicts = Timetable.query.filter(
        Timetable.start_time < candidate.end_time,
        Timetable.end_time > candidate.start_time,
        or_(
            Timetable.room_id == candidate.room_id,
            Timetable.lecture_id == candidate.lecture_id,
        ),
    ).all()
    conflicts.extend(
        row for row in pending
        if row.start_time < candidate.end_time
        and row.end_time > candidate.start_time
        and (
            row.room_id == candidate.room_id
            or row.lecture_id == candidate.lecture_id
        )
    )
    if not conflicts:
        return None

    conflict = conflicts[0]
    if conflict.room_id == candidate.room_id:
        return f'Room {room.room_name} is already booked during this time'
    return f'Lecturer {lecturer.lecture_name} is already scheduled during this time'


def timetable_json(item):
    return {
        'id': item.id,
        'course_id': item.course_id,
        'course_code': item.course.course_code,
        'course_name': item.course.course_name,
        'lecture_id': item.lecture_id,
        'lecturer': item.lecture.lecture_name,
        'room_id': item.room_id,
        'room_name': item.room.room_name,
        'year_of_study': item.year_of_study,
        'semester': item.semester,
        'unit_name': item.unit_name,
        'start_time': item.start_time.isoformat(),
        'end_time': item.end_time.isoformat(),
    }


@timetable_bp.route('/timetables', methods=['GET'])
def list_timetables():
    query = Timetable.query
    for field in ('course_id', 'year_of_study', 'semester'):
        value = request.args.get(field)
        if value is not None:
            try:
                parsed = int(value)
            except ValueError:
                return jsonify({'message': f'{field} must be a positive whole number'}), 400
            if parsed < 1:
                return jsonify({'message': f'{field} must be a positive whole number'}), 400
            query = query.filter(getattr(Timetable, field) == parsed)

    rows = query.order_by(Timetable.start_time.asc()).all()
    return jsonify([timetable_json(item) for item in rows]), 200


@timetable_bp.route('/timetables', methods=['POST'])
def add_timetables():
    expected_key = current_app.config.get('TIMETABLE_ADMIN_API_KEY')
    if not expected_key:
        return jsonify({'message': 'Timetable administration is not configured'}), 503
    supplied_key = request.headers.get('X-Timetable-Admin-Key', '')
    if not hmac.compare_digest(str(expected_key), supplied_key):
        return jsonify({'message': 'Invalid timetable administration credentials'}), 401

    data = request.get_json(silent=True)
    rows = data if isinstance(data, list) else [data] if isinstance(data, dict) else None
    if not rows:
        return jsonify({'message': 'Provide a timetable object or a non-empty array'}), 400

    pending = []
    for index, row in enumerate(rows):
        prefix = f'Entry {index + 1}: '
        if not isinstance(row, dict):
            return jsonify({'message': f'{prefix}expected a JSON object'}), 400
        missing = REQUIRED_FIELDS - row.keys()
        if missing:
            return jsonify({
                'message': f'{prefix}missing fields: {", ".join(sorted(missing))}',
            }), 400

        parsed_ids = {}
        for field in ('course_id', 'lecture_id', 'room_id', 'year_of_study', 'semester'):
            value, error_response, status = positive_integer(row[field], field)
            if error_response:
                return jsonify({'message': prefix + error_response.json['message']}), status
            parsed_ids[field] = value

        course = db.session.get(Course, parsed_ids['course_id'])
        lecturer = db.session.get(lecture, parsed_ids['lecture_id'])
        room = db.session.get(rooms, parsed_ids['room_id'])
        if course is None:
            return jsonify({'message': f'{prefix}course_id does not exist'}), 400
        if lecturer is None:
            return jsonify({'message': f'{prefix}lecture_id does not exist'}), 400
        if room is None:
            return jsonify({'message': f'{prefix}room_id does not exist'}), 400

        unit_name = row['unit_name']
        if not isinstance(unit_name, str) or not unit_name.strip():
            return jsonify({'message': f'{prefix}unit_name is required'}), 400
        if parsed_ids['year_of_study'] > course.duration:
            return jsonify({
                'message': f'{prefix}year_of_study must be between 1 and '
                f'{course.duration} for {course.course_code}',
            }), 400

        start_time, error_response, status = parse_timetable_datetime(
            row['start_time'], 'start_time',
        )
        if error_response:
            return jsonify({'message': prefix + error_response.json['message']}), status
        end_time, error_response, status = parse_timetable_datetime(
            row['end_time'], 'end_time',
        )
        if error_response:
            return jsonify({'message': prefix + error_response.json['message']}), status
        if start_time >= end_time:
            return jsonify({
                'message': f'{prefix}start_time must be before end_time',
            }), 400

        item = Timetable(
            course_id=course.id,
            lecture_id=lecturer.id,
            room_id=room.id,
            year_of_study=parsed_ids['year_of_study'],
            semester=parsed_ids['semester'],
            unit_name=unit_name.strip(),
            start_time=start_time,
            end_time=end_time,
        )
        conflict = has_schedule_conflict(item, pending, room, lecturer)
        if conflict:
            return jsonify({'message': f'{prefix}{conflict}'}), 409
        pending.append(item)

    db.session.add_all(pending)
    try:
        db.session.commit()
    except IntegrityError:
        db.session.rollback()
        return jsonify({
            'message': 'A timetable entry conflicts with an existing entry',
        }), 409
    return jsonify({
        'message': 'Timetable entries created',
        'count': len(pending),
        'entries': [timetable_json(item) for item in pending],
    }), 201
