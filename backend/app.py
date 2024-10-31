from flask import Flask
from flask_cors import CORS
from config import Config
from flask_restful import Api
from users import users_bp
from devices import devices_bp
from returns import returns_bp
from rentals import rentals_bp



import os
print(os.getcwd())


app = Flask(__name__)
CORS(app)
api = Api(app)

# config.py 파일에서 설정 로드
app.config.from_object(Config)

# Blueprint 등록
app.register_blueprint(users_bp, url_prefix='/users')
app.register_blueprint(devices_bp, url_prefix='/devices')
app.register_blueprint(returns_bp, url_prefix='/returns')
app.register_blueprint(rentals_bp, url_prefix='/rentals')


# Flask 서버 실행
if __name__ == '__main__':
    app.run(debug=True)