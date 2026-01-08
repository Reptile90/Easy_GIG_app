from flask import Blueprint, jsonify,request
from app.db import get_db_conn,release_db_conn

artisti_bp = Blueprint('artisti', __name__)

@artisti_bp.route('/artisti', methods=['GET'])
def get_artisti():
    
    genere = request.args.get('genere')
    regione = request.args.get('regione')
    
    conn = None
    
    try:
        conn = get_db_conn()
        cursor = conn.cursor()
        
        cursor.execute("SELECT * FROM esegui_ricerca_artisti(%s,%s);",(genere, regione))
        artisti = cursor.fetchall()
        
        cursor.close()
        
        lista_artisti = []
        for artista in artisti:
            lista_artisti.append({
                'id': artista[0],
                'nome': artista[1],
                'genere': artista[2],
                'zona': artista[3],
                'cachet': artista[4],
                'info_contatto': artista[5]
            })
        return jsonify(lista_artisti)
    
    except Exception as e:
        
        print(f"Errore {e}")
        return jsonify({"error": "Errore nel recupero dei dati"}),500
    finally:
        if conn:
            release_db_conn(conn)