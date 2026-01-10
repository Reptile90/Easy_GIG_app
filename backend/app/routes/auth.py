from flask import Blueprint, request,jsonify
from werkzeug.security import generate_password_hash, check_password_hash
from app.db import get_db_conn,release_db_conn
import psycopg2

auth_bp = Blueprint('auth',__name__)

#registrazione
@auth_bp.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    
    #validazione dei dati
    if not data or not data.get('email') or not data.get('password'):
        return jsonify({"error": "Dati mancanti! Devi inserire email e password"})
    
    conn = None
    try:
        conn = get_db_conn()
        cursor = conn.cursor()
        
        #effettuo l'hashing della password
        hashed_pw = generate_password_hash(data['password'], method='pbkdf2:sha256')
        
        #inserimento nella tabella Person
        query_person = """
        INSERT INTO Person (nome,cognome,email,numerotelefono,password_hash)
        VALUES(%s,%s,%s,%s,%s)
        RETURNING id;
        """
        cursor.execute(query_person, (
            data.get('nome'),
            data.get('cognome'),
            data.get('email'),
            data.get('phone'),
            hashed_pw
        ))
        
        #recupero id creato
        
        new_user_id = cursor.fetchone()[0]
        
        
        #Inserimento in AccountState con stato iniziale attivo
        
        query_account = """
            INSERT INTO AccountState (person_id, strike_count,stato)
            VALUES (%s, 0, 'attivo');
        """
        
        cursor.execute(query_account,(new_user_id,))
        #Confermo la modifiche
        conn.commit()
        return jsonify({"message":"Utente registrato con successo!", "id": new_user_id}),201
    
    except psycopg2.IntegrityError as e:
        # Qui catturiamo l'errore esatto (e)
        if conn: conn.rollback()
        
        # 1. Stampiamolo nel terminale del server
        print(f"🛑 ERRORE DETTAGLIATO SQL: {e}")
        
        # 2. Mandiamolo anche al file di test così lo leggi subito
        return jsonify({"error": f"Errore Database: {e}"}), 409
    
    except Exception as e:
        if conn: conn.rollback()
        print(f"Errore registrazione: {e}")
        return jsonify({"error": "Errore interno del server"}),500
    
    finally:
        if conn: release_db_conn(conn)
        
        

#LOG-IN
@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    
    if not data or not data.get('email') or not data.get('password'):
        return jsonify({"error": "Email e password richieste"}), 400
    
    conn = None
    try:
        conn= get_db_conn()
        cursor = conn.cursor()
        
        #cerco l'utente tramite mail
        query = "SELECT id,nome, password_hash FROM Person WHERE email = %s"
        cursor.execute(query, (data['email'],))
        user = cursor.fetchone()
        
        cursor.close()
        
        if user and check_password_hash(user[2], data['password']):
            #LOGIN RIUSCITO
            return jsonify({
                "message": f"Bentornato, {user[1]}",
                "user_id": user[0],
                "status": "success"
            }),200
        
        else:
            # Login fallito (non diciamo se è sbagliata l'email o la psw per sicurezza)
            return jsonify({"error": "Credenziali non valide"}), 401
            
    except Exception as e:
        print(f"Errore login: {e}")
        return jsonify({"error": "Errore interno"}), 500
        
    finally:
        if conn: release_db_conn(conn)