from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

# lecture

class lecture(db.Model):
    __tablename__ = 'lectures'
    id = db.Column(db.Integer, primary_key=True)
    course_id = db.Column(db.Integer, db.ForeignKey('courses.id'), nullable=False)
    lecture_name = db.Column(db.String(100), nullable=False)
    department = db.Column(db.String(100), nullable=False)


# courses
class Course(db.Model):
    __tablename__ = 'courses'
    id = db.Column(db.Integer, primary_key=True)
    student_id = db.Column(db.String(20), db.ForeignKey('students.student_id'), nullable=False)
    course_name = db.Column(db.String(100), nullable=False)
    course_code = db.Column(db.String(20), unique=True, nullable=False)
    department = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text, nullable=True)
    duration = db.Column(db.Integer, nullable=False)


#timetable
class Timetable(db.Model):
    __tablename__ = 'timetables'
    id = db.Column(db.Integer, primary_key=True)
    course_id = db.Column(db.Integer, db.ForeignKey('courses.id'), nullable=False)
    lecture_id = db.Column(db.Integer, db.ForeignKey('lectures.id'), nullable=False)
    student_id = db.Column(db.String(20), db.ForeignKey('students.student_id'), nullable=False)
    start_time = db.Column(db.DateTime, nullable=False)
    end_time = db.Column(db.DateTime, nullable=False)


#attendance
class Attendance(db.Model):
    __tablename__ = 'attendances'
    id = db.Column(db.Integer, primary_key=True)
    timetable_id = db.Column(db.Integer, db.ForeignKey('timetables.id'), nullable=False)
    student_id = db.Column(db.String(20), db.ForeignKey('students.student_id'), nullable=False)
    status = db.Column(db.String(20), nullable=False)  # e.g., 'present', 'absent', 'late'


# student
class Student(db.Model):
    __tablename__ = 'students'
    id = db.Column(db.Integer, primary_key=True)
    student_id = db.Column(db.String(20), unique=True, nullable=False)
    first_name = db.Column(db.String(100), nullable=False)
    last_name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(100), unique=True, nullable=False)
    course_id = db.Column(db.Integer, db.ForeignKey('courses.id'), nullable=False)
    year_of_study = db.Column(db.Integer, nullable=False)

    #User relationship

class User(db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(128), nullable=False) 
    phone_number = db.Column(db.String(20), unique=True, nullable=True)
    student_id = db.Column(db.String(20), db.ForeignKey('students.student_id'), nullable=True)
    status = db.Column(db.String(20), nullable=False, default='active')  # e.g., 'active', 'inactive'

class rfid_card(db.Model):
    __tablename__ = 'rfid_cards'
    id = db.Column(db.Integer, primary_key=True)
    card_id = db.Column(db.String(50), unique=True, nullable=False)
    student_id = db.Column(db.String(20), db.ForeignKey('students.student_id'), nullable=False)
    issued_at = db.Column(db.DateTime, nullable=False)
    status = db.Column(db.String(20), nullable=False, default='active')  # e.g., 'active', 'inactive', 'lost'

class gates(db.Model):
    __tablename__ = 'gates'
    id = db.Column(db.Integer, primary_key=True)
    gate_name = db.Column(db.String(100), nullable=False)
    location = db.Column(db.String(100), nullable=False)

class rooms(db.Model):
    __tablename__ = 'rooms'
    id = db.Column(db.Integer, primary_key=True)
    room_number = db.Column(db.String(20), unique=True, nullable=False)
    capacity = db.Column(db.Integer, nullable=False)
    building = db.Column(db.String(100), nullable=False)
