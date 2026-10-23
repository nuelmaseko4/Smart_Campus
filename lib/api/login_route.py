from flask import request, jsonify
from werkzeug.security import check_password_hash
from lib.api.models import Student, User
from lib.api.models import User,Student 

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

        if not all([email, password]):
            return jsonify({"error": "Missing email or password"}), 400

        # Dictionary to map roles to models
        roles = {
            "Student": Student,
            "Lecture": Lecture,
            
        }

        # Loop through roles and check credentials
        for role, model in roles.items():
            user = model.query.filter_by(Student_ID=student_id).first()
            if user and check_password_hash(user.password, password):
                # Create JWT with email as identity and role as claim
                access_token = create_access_token(
                    identity=email,
                    additional_claims={"role": role},
                    expires_delta=timedelta(days=1)
                )
                return jsonify({
                    "message": "Login successful",
                    "role": role,
                    "email": email,
                    "access_token": access_token
                }), 200

        return jsonify({"error": "Invalid credentials"}), 401