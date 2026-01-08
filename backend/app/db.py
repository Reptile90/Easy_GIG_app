import os
import psycopg2
from psycopg2 import pool

connection_pool = None

def init_db_pool():
    global connection_pool
    
    connection_pool = pool.SimpleConnectionPool(
        1,10,
        host = os.getenv('DB_HOST'),
        database = os.getenv('DB_NAME'),
        user = os.getenv('DB_USER'),
        password = os.getenv('DB_PASS'),
        port = os.getenv('DB_PORT')
    )
    print('Database Connection Pool creato con successo!')
    

def get_db_conn():
    if connection_pool:
        return connection_pool.getconn()
    else:
        raise Exception("Il Pool del DB non è stato inizializzato!")
    
def release_db_conn(conn):
    if connection_pool:
        connection_pool.putconn(conn)
        
def close_db_pool():
    if connection_pool:
        connection_pool.closeall()