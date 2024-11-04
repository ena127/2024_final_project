from resources.database import get_db_connection
from utils.hashing import hash_password, verify_password
import jwt
from datetime import datetime, timedelta

SECRET_KEY = 'secretKey'

class AuthService:
    def __init__(self):
        self.secret_key = SECRET_KEY

    def register_user(self, user_data):
        """Registers a user by inserting data into the database."""
        # Input validation
        required_fields = ['student_id', 'password', 'role', 'email', 'name', 'photo_url', 'professor']
        if not all(field in user_data for field in required_fields):
            return {"error": "Missing required fields"}, 400

        # Hash password
        hashed_password = hash_password(user_data['password'])

        # Prepare user data
        student_id = user_data['student_id']
        role = user_data['role']
        email = user_data['email']
        name = user_data['name']
        photo_url = user_data['photo_url']
        professor = user_data['professor']

        # Database insertion
        try:
            conn = get_db_connection()
            cursor = conn.cursor()
            cursor.execute(
                '''INSERT INTO user (student_id, role, email, name, photo_url, professor, password)
                   VALUES (%s, %s, %s, %s, %s, %s, %s)''',
                (student_id, role, email, name, photo_url, professor, hashed_password)
            )
            conn.commit()
            return {"message": "User registered successfully"}, 201
        except Exception as e:
            print("Database error:", e)
            return {"error": "Database insertion failed"}, 500
        finally:
            cursor.close()
            conn.close()

    def login_user(self, user_data):
        """Logs in a user by checking credentials and returning a JWT token if valid."""
        # Input validation
        if 'student_id' not in user_data or 'password' not in user_data:
            return {"error": "Missing student_id or password"}, 400

        student_id = user_data['student_id']
        password = user_data['password']

        # Retrieve user from database
        try:
            conn = get_db_connection()
            cursor = conn.cursor()
            cursor.execute('SELECT password FROM user WHERE student_id = %s', (student_id,))
            user = cursor.fetchone()
        finally:
            cursor.close()
            conn.close()

        if not user or not verify_password(password, user[0]):
            return {"error": "Invalid credentials"}, 401

        # Generate JWT token
        token = jwt.encode(
            {'student_id': student_id, 'exp': datetime.utcnow() + timedelta(hours=1)},
            self.secret_key,
            algorithm='HS256'
        )
        return {"token": token}, 200