from ..resources.database import get_db_connection
from ..utils.hashing import hash_password, verify_password
import jwt
from datetime import datetime, timedelta

SECRET_KEY = 'secretKey'

def register_user(user_data):
    password = hash_password(user_data.get('password'))
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        'INSERT INTO user (student_id, role, email, name, password) VALUES (%s, %s, %s, %s, %s)',
        (user_data['student_id'], user_data['role'], user_data['email'], user_data['name'], password)
    )
    conn.commit()
    cursor.close()
    conn.close()
    return {"message": "User registered successfully"}


def login_user(user_data):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('SELECT password FROM user WHERE student_id = %s', (user_data['student_id'],))
    user = cursor.fetchone()
    cursor.close()
    conn.close()

    if not user or not verify_password(user_data['password'], user[0]):
        return {"error": "Invalid credentials"}, 401

    token = jwt.encode(
        {'student_id': user_data['student_id'], 'exp': datetime.utcnow() + timedelta(hours=1)},
        SECRET_KEY,
        algorithm='HS256'
    )
    return {"token": token}