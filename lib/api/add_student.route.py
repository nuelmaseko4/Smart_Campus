from flask import app, app, request, jsonify
from model import db, Student

@app.route('/students', methods=['POST'])
def create_student():
    data = request.get_json()
    student = Student(
        student_id=data['student_id'],
        first_name=data['first_name'],
        last_name=data['last_name'],
        email=data['email'],
        course_id=data['course_id'],
        year_of_study=data['year_of_study']
    )
    db.session.add(student)
    db.session.commit()
    return jsonify({'message': 'Student created', 'id': student.id}), 201