import json
from app import create_app
from models import db, Course

app = create_app()

with app.app_context():
    with open('courses.json', encoding='utf-8') as f:
        data = json.load(f)

    created = 0
    for row in data:
        exists = Course.query.filter_by(course_code=row['course_code']).first()
        if exists:
            continue
        db.session.add(Course(
            course_name=row['course_name'],
            course_code=row['course_code'],
            department=row['department'],
            duration=row['duration'],
        ))
        created += 1

    db.session.commit()
    print(f"Inserted {created} courses. Total in DB: {Course.query.count()}")