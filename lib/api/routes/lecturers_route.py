from flask import Blueprint, jsonify, request

from models import db, Course, lecture
from utils import as_list, save_all

lecturers_bp = Blueprint('lecturers', __name__)


@lecturers_bp.route('/lecturers', methods=['POST'])
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


@lecturers_bp.route('/lecturers', methods=['GET'])
def list_lecturers():
    return jsonify([
        {'id': l.id, 'lecture_id': l.lecture_id, 'name': l.lecture_name,
         'department': l.department, 'course_id': l.course_id}
        for l in lecture.query.all()
    ])
