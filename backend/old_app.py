import os
import psycopg2
from flask import Flask,jsonify
from dotenv import load_dotenv

load_dotenv()

app= Flask(__name__)

def get_db_connection():
    connection = psycopg2.connect(
        host = os.getenv('DB_HOST'),
        database = os.getenv('DB_NAME'),
        user = os.getenv('DB_USER'),
        password = os.getenv('DB_PASS'),
        port = os.getenv('DB_PORT')
    )
    return connection

@app.route('/')
def home():
    return "EasyGIG Backend è attivo! 🚀 Vai su <a href='/artisti'>/artisti</a> per vedere i dati."


@app.route('/artisti')
def get_artisti():
    connection = get_db_connection()
    cursor = connection.cursor()
    
    cursor.execute("SELECT * FROM esegui_ricerca_artisti(NULL, NULL);")
    artisti = cursor.fetchall()
    
    cursor.close()
    connection.close()
    
    lista_artisti = []
    for artista in artisti:
        lista_artisti.append({
            'id':artista[0],
            'nome':artista[1],
            'genere': artista[2],
            'zona':artista[3],
            'cachet':artista[4],
            'info_contatto':artista[5]
        })
        
    return jsonify(lista_artisti)

if __name__ == '__main__':
    app.run(debug=True)