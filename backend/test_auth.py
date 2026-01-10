import requests
import random

BASE_URL = "http://127.0.0.1:5000/auth"

# --- GENERAZIONE DATI CASUALI (Per evitare errori di duplicati) ---
random_id = random.randint(1000, 9999)
email_casuale = f"utente_{random_id}@test.com"

# Generiamo un numero di telefono credibile a 10 cifre
# (Prefisso 333 + 7 cifre casuali)
# Questo risolve l'errore "phonenumber_check"
phone_casuale = f"333{random.randint(1000000, 9999999)}"

password_segreta = "PasswordSuperSegreta!"

print(f"--- PREPARAZIONE TEST ---")
print(f"Email usata: {email_casuale}")
print(f"Telefono usato: {phone_casuale}")
print("-" * 30)

# --- 1. TEST REGISTRAZIONE ---
print("\n--- 1. PROVO A REGISTRARE L'UTENTE ---")
nuovo_utente = {
    "nome": "Test",
    "cognome": "Finale",
    "email": email_casuale,
    "phone": phone_casuale, 
    "password": password_segreta
}

try:
    resp = requests.post(f"{BASE_URL}/register", json=nuovo_utente)
    print(f"Status: {resp.status_code} (Mi aspetto 201)")
    print(f"Risposta: {resp.json()}")
except Exception as e:
    print(f"ERRORE RICHIESTA: {e}")

# --- 2. TEST LOGIN CORRETTO ---
print("\n--- 2. PROVO A FARE LOGIN (Credenziali Giuste) ---")
credenziali = {
    "email": email_casuale,
    "password": password_segreta
}

try:
    resp = requests.post(f"{BASE_URL}/login", json=credenziali)
    print(f"Status: {resp.status_code} (Mi aspetto 200)")
    print(f"Risposta: {resp.json()}")
except Exception as e:
    print(f"ERRORE RICHIESTA: {e}")

# --- 3. TEST LOGIN SBAGLIATO (Opzionale) ---
print("\n--- 3. PROVO LOGIN CON PASSWORD SBAGLIATA ---")
credenziali_errate = {
    "email": email_casuale,
    "password": "passwordSbagliata"
}
try:
    resp = requests.post(f"{BASE_URL}/login", json=credenziali_errate)
    print(f"Status: {resp.status_code} (Mi aspetto 401)")
    print(f"Risposta: {resp.json()}")
except:
    pass