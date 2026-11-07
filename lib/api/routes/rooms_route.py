from flask import Blueprint, jsonify

from models import rooms

rooms_bp = Blueprint('rooms', __name__)


@rooms_bp.route('/rooms', methods=['GET'])
def list_rooms():
    return jsonify([
        {'id': r.id, 'room_name': r.room_name, 'capacity': r.capacity, 'building': r.building}
        for r in rooms.query.all()
    ])
