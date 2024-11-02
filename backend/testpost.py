# api랑 연결 되는지,
# post 요청이 잘 전송되고 있는지만 테스트하기 위한 파일
# 전부 테스트 하고 나면 지울것

from flask import Flask, request, jsonify
from flask_restful import Resource
import pymysql

app = Flask(__name__)

# 예시: 데이터베이스 연결 함수 (필요 시 실제 연결로 수정)
def get_db_connection():
    try:
        # 데이터베이스 연결 설정 (수정 필요)
        conn = pymysql.connect(
            host="your_host",
            user="your_user",
            password="your_password",
            db="your_db",
            charset="utf8mb4",
            cursorclass=pymysql.cursors.DictCursor
        )
        return conn
    except pymysql.MySQLError as e:
        print(f"Database connection error: {e}")
        return None

@app.route('/test_post', methods=['POST'])
def test_post():
    # 요청된 JSON 데이터 가져오기
    data = request.json
    if not data:
        return jsonify({"error": "No data provided"}), 400  # 상태 코드 400: 잘못된 요청

    # 필수 필드 확인
    student_id = data.get('student_id')
    role = data.get('role')
    email = data.get('email')
    name = data.get('name')
    photo_url = data.get('photo_url')
    professor = data.get('professor')

    # 필수 필드가 누락된 경우 오류 반환
    if not all([student_id, role, email, name]):
        return jsonify({"error": "Missing required fields"}), 400  # 상태 코드 400: 잘못된 요청

    # 데이터베이스 연결
    try:
        conn = get_db_connection()
        if conn is None:
            return jsonify({"error": "Database connection failed"}), 500  # 상태 코드 500: 서버 오류

        cursor = conn.cursor()

        # 데이터베이스 삽입 시도
        try:
            cursor.execute(
                'INSERT INTO user (student_id, role, email, name, photo_url, professor) VALUES (%s, %s, %s, %s, %s, %s)',
                (student_id, role, email, name, photo_url, professor)
            )
            conn.commit()
            return jsonify({'message': 'User added successfully'}), 201  # 상태 코드 201: 성공적으로 생성됨
        except pymysql.MySQLError as e:
            print(f"Database error: {e}")
            conn.rollback()
            return jsonify({"error": "Failed to insert data"}), 500  # 상태 코드 500: 서버 오류
        finally:
            cursor.close()
            conn.close()

    # 예외 발생 시 오류 처리
    except Exception as e:
        print(f"Unexpected error: {e}")
        return jsonify({"error": "An unexpected error occurred"}), 500  # 상태 코드 500: 서버 오류

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)