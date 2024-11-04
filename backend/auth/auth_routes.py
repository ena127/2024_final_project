from flask import Blueprint, request, jsonify
from .auth_service import AuthService

auth_bp = Blueprint('auth', __name__)
auth_service = AuthService()

@auth_bp.route('/signup', methods=['POST'])
def signup():
    """Registers a new user with provided data."""
    data = request.json
    response, status_code = auth_service.register_user(data)
    return jsonify(response), status_code

@auth_bp.route('/login', methods=['POST'])
def login():
    """Logs in a user by validating credentials and returns a JWT token."""
    data = request.json
    response, status_code = auth_service.login_user(data)
    return jsonify(response), status_code