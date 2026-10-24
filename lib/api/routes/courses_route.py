from flask import Blueprint, jsonify, request

from models import Course
from utils import as_list, save_all

courses_bp = Blueprint('courses', __name__)


@courses_bp.route('/courses', methods=['POST'])
def add_courses():
    try:
        rows = [Course(
            course_name=d['course_name'], course_code=d['course_code'],
            department=d['department'], duration=d['duration'],
        ) for d in as_list(request.get_json())]
    except KeyError as e:
        return jsonify({'message': f'Missing field: {e}'}), 400
    return save_all(rows)


@courses_bp.route('/courses', methods=['GET'])
def list_courses():
    return jsonify([
        {'id': c.id, 'course_code': c.course_code, 'course_name': c.course_name,
         'department': c.department, 'duration': c.duration}
        for c in Course.query.all()
    ])
