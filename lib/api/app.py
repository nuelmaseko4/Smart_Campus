from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager
from config import Config
from model import db, Student, User, Lecture, Course, Timetable, Attendance
from login_route import login_route