from flask import jsonify
from sqlalchemy.exc import IntegrityError

from models import db


def as_list(data):
    if isinstance(data, list):
        return data
    if isinstance(data, dict):
        return [data]
    raise ValueError('Expected a JSON object or an array of objects')


def save_all(rows):
    db.session.add_all(rows)
    try:
        db.session.commit()
    except IntegrityError:
        db.session.rollback()
        return jsonify({'message': 'One or more records violate a database constraint'}), 409
    return jsonify({'message': 'Records created', 'count': len(rows)}), 201


def student_name(student):
    if student is None:
        return None

    # Try first_name / last_name first (if the model has them)
    first = (getattr(student, 'first_name', None) or '').strip()
    last = (getattr(student, 'last_name', None) or '').strip()
    full = ' '.join(part for part in (first, last) if part)

    # Fall back to a single 'name' column, then email
    return full or getattr(student, 'name', None) or student.email