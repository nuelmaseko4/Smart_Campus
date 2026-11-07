import os

from datetime import datetime

from app import app
from models import db, Student, rfid_card


def register_cards():
    student_id = os.getenv('CARD_REGISTRATION_STUDENT_ID', '').strip()
    card_ids = [
        card.strip()
        for card in os.getenv('CARD_REGISTRATION_CARD_IDS', '').split(',')
        if card.strip()
    ]

    if not student_id or not card_ids:
        raise ValueError('Set CARD_REGISTRATION_STUDENT_ID and CARD_REGISTRATION_CARD_IDS in lib/api/.env.')

    if Student.query.filter_by(student_id=student_id).first() is None:
        print("Student not found. No changes made.")
        return

    existing = rfid_card.query.filter(
        rfid_card.card_id.in_(card_ids)
    ).all()

    if any(card.student_id != student_id for card in existing):
        print("A card belongs to another student. No changes made.")
        return

    existing_ids = {card.card_id for card in existing}

    for card_id in card_ids:
        if card_id not in existing_ids:
            db.session.add(rfid_card(
                card_id=card_id,
                student_id=student_id,
                issued_at=datetime.now(),
                status="active",
            ))

    try:
        db.session.commit()
    except Exception:
        db.session.rollback()
        raise

    print('Card registration completed.')


if __name__ == "__main__":
    with app.app_context():
        register_cards()