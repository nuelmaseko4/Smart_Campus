from datetime import datetime

from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import generate_password_hash, check_password_hash

db = SQLAlchemy()


# lecture
# many-to-many: lecturer <-> courses
lecturer_courses = db.Table(
    'lecturer_courses',
    db.Column('lecturer_id', db.Integer, db.ForeignKey('lectures.id'), primary_key=True),
    db.Column('course_id',   db.Integer, db.ForeignKey('courses.id'),  primary_key=True),
)


class lecture(db.Model):
    __tablename__ = 'lectures'
    id = db.Column(db.Integer, primary_key=True)

    # login fields
    username = db.Column(db.String(50), unique=True, nullable=False, index=True)
    password_hash = db.Column(db.String(255), nullable=False)

    # profile fields
    lecture_name = db.Column(db.String(100), nullable=False)
    department   = db.Column(db.String(100), nullable=False)
    email        = db.Column(db.String(120), unique=True, nullable=False, index=True)

    # programs this lecturer teaches (many-to-many)
    courses = db.relationship(
        'Course',
        secondary=lecturer_courses,
        backref=db.backref('lecturers', lazy='dynamic'),
        lazy='select',
    )

    def set_password(self, password):
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

    def __repr__(self):
        return f"<lecture {self.username} ({self.lecture_name})>"

    
# courses
class Course(db.Model):
    __tablename__ = 'courses'
    id = db.Column(db.Integer, primary_key=True)
    course_name = db.Column(db.String(100), nullable=False)
    course_code = db.Column(db.String(20), unique=True, nullable=False)
    department = db.Column(db.String(100), nullable=False)
    duration = db.Column(db.Integer, nullable=False)


# timetable
class Timetable(db.Model):
    __tablename__ = 'timetables'
    id = db.Column(db.Integer, primary_key=True)
    course_id = db.Column(db.Integer, db.ForeignKey('courses.id'), nullable=False)
    lecture_id = db.Column(db.Integer, db.ForeignKey('lectures.id'), nullable=False)
    room_id = db.Column(db.Integer, db.ForeignKey('rooms.id'), nullable=False)  # 👈 new
    start_time = db.Column(db.DateTime, nullable=False)
    end_time = db.Column(db.DateTime, nullable=False)
    unit_name = db.Column(db.String(120), nullable=False)
    year_of_study = db.Column(
        db.Integer,
        nullable=False,
        default=1,
        server_default='1',
    )
    semester = db.Column(
        db.Integer,
        nullable=False,
        default=1,
        server_default='1',
    )

    course = db.relationship('Course', backref='timetables')
    lecture = db.relationship('lecture', backref='timetables')
    room = db.relationship('rooms', backref='timetables')

    __table_args__ = (
        db.UniqueConstraint('lecture_id', 'start_time', name='uq_lecture_slot'),
        db.UniqueConstraint('room_id', 'start_time', name='uq_room_slot'),
    )

    def __repr__(self):
        return f"<Timetable {self.course_id} @ {self.start_time:%Y-%m-%d %H:%M}>"


# attendance
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
    student_id = db.Column(db.String(10), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    course_id = db.Column(db.Integer, db.ForeignKey('courses.id'), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=True)
    year_of_study = db.Column(
        db.Integer,
        nullable=False,
        default=1,
        server_default='1',
    )


  
    def set_password(self, password):
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

# User (kept for later, e.g. admin accounts)
class User(db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
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



class Gate(db.Model):
    __tablename__ = 'gates'
    id = db.Column(db.Integer, primary_key=True)
    access_point = db.Column(db.String(100), unique=True, nullable=False)


class GateEntry(db.Model):
    __tablename__ = 'gate_entries'
    id = db.Column(db.Integer, primary_key=True)
    gate_id = db.Column(db.Integer, db.ForeignKey('gates.id'), nullable=False)
    student_id = db.Column(
        db.String(20),
        db.ForeignKey('students.student_id'),
        nullable=False,
    )
    scanned_at = db.Column(db.DateTime, nullable=False, default=datetime.now)

    gate = db.relationship('Gate')


class rooms(db.Model):
    __tablename__ = 'rooms'
    id = db.Column(db.Integer, primary_key=True)
    room_name = db.Column(db.String(20), unique=True, nullable=False)
    capacity = db.Column(db.Integer, nullable=False)
    building = db.Column(db.String(100), nullable=False)