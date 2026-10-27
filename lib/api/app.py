from datetime import timedelta

from flask import Flask
from flask_jwt_extended import JWTManager

from models import db
from routes.auth_route import auth_bp
from routes.courses_route import courses_bp
from routes.lecturers_route import lecturer_bp
from routes.rooms_route import rooms_bp
from routes.signup_route import signup_bp
from routes.students_route import students_bp


app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///uni_connect.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['JWT_SECRET_KEY'] = 'hjh7ggfgbnbjbnj889876'
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = timedelta(hours=12)

db.init_app(app)
jwt = JWTManager(app)

# register route files (blueprints)
for bp in (auth_bp, courses_bp, lecturer_bp, rooms_bp, signup_bp, students_bp):
    app.register_blueprint(bp)

with app.app_context():
    db.create_all()


@app.route('/')
def home():
    return 'uni_connect API is running'


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
