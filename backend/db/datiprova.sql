-- 1. MARIO ROSSI (Artista)
INSERT INTO Person (nome, cognome, numeroTelefono, email, password_hash) 
VALUES ('Mario', 'Rossi', '+39 333 1234567', 'mario.rossi@email.com', 'pwd_mario');

-- 2. BAND "I ROCKERS"
-- Nota: city_id deve matchare una città esistente (es. Pomezia)
INSERT INTO Artist (nome, cachet, negotiable, representative_id, genre, category, city_id, linkStreaming)
VALUES (
    'I Rockers di Pomezia', 
    300.00, 
    TRUE, 
    (SELECT id FROM Person WHERE email = 'mario.rossi@email.com'), 
    'Rock', 
    'Band Originale', 
    'Pomezia', 
    'http://spotify.com/rockers'
);

INSERT INTO Band (id) VALUES ((SELECT id FROM Artist WHERE nome = 'I Rockers di Pomezia'));

-- 3. LUIGI VERDI (Direttore Locale)
-- Uso un numero mobile anche qui per evitare errori di regex
INSERT INTO Person (nome, cognome, numeroTelefono, email, password_hash) 
VALUES ('Luigi', 'Verdi', '+39 333 9988777', 'luigi.verdi@email.com', 'pwd_luigi');

INSERT INTO ArtisticDirector (id) VALUES ((SELECT id FROM Person WHERE email = 'luigi.verdi@email.com'));

-- 4. INDIRIZZO LOCALE (Ardea)
INSERT INTO Address (via, numeroCivico, cap, geo_coords, city)
VALUES ('Via dei Rutuli', '10', '00040', '(41.608, 12.540)', 'Ardea');

-- 5. IL LOCALE (Venue)
INSERT INTO Venue (nome, numeroTelefono, email, configurazione_sala, capienza, strumentazione, indirizzo_id, director_id)
VALUES (
    'Il Pubbetto',
    '+39 333 5556666', -- Numero corretto a 3 cifre dopo prefisso
    'info@ilpubbetto.com',
    'tavoli',
    150,
    'Mixer e Casse',
    (SELECT id FROM Address WHERE via = 'Via dei Rutuli'),
    (SELECT id FROM Person WHERE email = 'luigi.verdi@email.com')
);

-- 6. SLOT DISPONIBILE
INSERT INTO Slot (venue_id, start_time, end_time, stato)
VALUES (
    (SELECT id FROM Venue WHERE nome = 'Il Pubbetto'),
    '2025-12-30 21:00:00',
    '2025-12-30 23:59:00',
    'disponibile'
);

-- 7. PRENOTAZIONE DI PROVA
INSERT INTO Booking (introductory_message, data_scadenza, slot_id, artist_id)
VALUES (
    'Ciao! Vorremmo suonare.',
    '2025-12-25 00:00:00',
    (SELECT id FROM Slot LIMIT 1),
    (SELECT id FROM Artist WHERE nome = 'I Rockers di Pomezia')
);