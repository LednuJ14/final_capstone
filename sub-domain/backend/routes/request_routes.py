from flask import Blueprint, jsonify

request_bp = Blueprint('requests', __name__)

@request_bp.route('/', methods=['GET'])
def get_requests():
    return jsonify({'message': 'Request routes - coming soon'}), 200