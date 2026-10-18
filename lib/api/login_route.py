from flask import request, jsonify
from werkzeug.security import check_password_hash
from lib.api.model import Student, User
from model import User,Student 

def login_route(app):
    @app.route('/api/login', methods=['POST'])
    def login():
        data = request.get_json()
        username = data.get('student_id')
        password = data.get('password')

        user = User.query.filter_by(username=username).first()

        if user and check_password_hash(user.password_hash, password):
            return jsonify({'message': 'Login successful'}), 200
        else:
            return jsonify({'message': 'Invalid credentials'}), 401 