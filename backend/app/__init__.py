from flask import Flask
from dotenv import load_dotenv
from app.db import init_db_pool

from app.routes.artisti import artisti_bp
from app.routes.auth import auth_bp

load_dotenv()

def create_app():
    app = Flask(__name__)
    
    with app.app_context():
        init_db_pool()
    
    app.register_blueprint(artisti_bp)
    app.register_blueprint(auth_bp, url_prefix='/auth')
    
    @app.route('/')
    def home():
        return "EasyGIG Backend Attivo"
    
    return app