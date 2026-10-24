from flask import Blueprint, jsonify, request
from flask_jwt_extended import (
    create_access_token, jwt_required, get_jwt_identity, get_jwt
)

from models import Student, lecture
from utils import student_name

auth_bp = Blueprint('auth', __name__)


@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json(silent=True) or {}
    role = data.get('role')
    user_id = str(data.get('id') or '').strip()
    password = data.get('password') or ''

    if role == 'student':
        person = Student.query.filter_by(student_id=user_id).first()
        name = student_name(person) if person else None
    elif role == 'lecturer':
        person = lecture.query.filter_by(lecture_id=user_id).first()
        name = person.lecture_name if person else None
    else:
        return jsonify({'message': 'Unknown role'}), 400

    if person is None or not person.check_password(password):
        return jsonify({'message': 'Invalid ID or password'}), 401

    token = create_access_token(identity=user_id, additional_claims={'role': role})
    return jsonify({'token': token, 'role': role, 'id': user_id, 'name': name}), 200


@auth_bp.route('/me', methods=['GET'])
@jwt_required()
def me():
    return jsonify({'id': get_jwt_identity(), 'role': get_jwt()['role']})
