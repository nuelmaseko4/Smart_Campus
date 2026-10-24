from flask import Blueprint, jsonify, request

from models import db, Course, Student
from utils import as_list, save_all, student_name

students_bp = Blueprint('students', __name__)


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
            )
            s.set_password(d['password'])
            rows.append(s)
    except KeyError as e:
        return jsonify({'message': f'Missing field: {e}'}), 400
    return save_all(rows)


@students_bp.route('/students', methods=['GET'])
def list_students():
    return jsonify([
        {'id': s.id, 'student_id': s.student_id, 'name': student_name(s),
         'course_id': s.course_id}
        for s in Student.query.all()
    ])
