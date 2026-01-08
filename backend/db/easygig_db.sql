BEGIN;

DROP TABLE IF EXISTS Message, Chat, Sanction, Review, Booking, Slot, Photo, Promoter, Band, Soloist, Artist, Category, Genre, Organization, Venue, ArtisticDirector, AccountState, Person, Address, City, Region, Nation CASCADE;
DROP TYPE IF EXISTS TypeAccountState, TypeOrganization, TypeRequestState, TypeSlotState, TypeVenue CASCADE;
DROP DOMAIN IF EXISTS CAP, Civico, Via, GeoCoord, Email, PhoneNumber, IntGZ, RealGEZ CASCADE;

--CREAZIONE DEI DOMINI

CREATE DOMAIN RealGEZ AS REAL
    CHECK(
        VALUE >= 0
);

CREATE DOMAIN IntGZ AS INTEGER
    CHECK(
        VALUE > 0
);


CREATE DOMAIN PhoneNumber AS VARCHAR(20)
CHECK (
   VALUE ~ '^\+?[0-9]{1,3}?[- .]?[0-9]{3}[- .]?[0-9]{6,8}$'
);

CREATE DOMAIN Email AS VARCHAR(100)
CHECK (
    VALUE ~ '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
);

CREATE DOMAIN GeoCoord AS POINT
CHECK (
    VALUE[0] BETWEEN -90 AND 90 AND  -- Latitudine (x)
    VALUE[1] BETWEEN -180 AND 180    -- Longitudine (y)
);

CREATE DOMAIN Via AS VARCHAR(100)
CHECK(
    VALUE ~ '^[a-zA-Z0-9àèéìòùÀÈÉÌÒÙ .''-]+$'
);

CREATE DOMAIN Civico AS VARCHAR(10)
CHECK (
    VALUE ~* '^([0-9]+[a-zA-Z/-]*|s\.?n\.?c\.?)$'
);

CREATE DOMAIN CAP AS VARCHAR(5)
CHECK (
   VALUE ~ '^\d{5}$'
);

--CREAZIONE DEI TIPI COMPOSTI

CREATE TYPE TypeVenue AS ENUM (
    'in_piedi',
    'platea',
    'tavoli',
    'misto'
);

CREATE TYPE TypeSlotState AS ENUM (
    'disponibile',
    'in_trattativa',
    'occupato'
);

CREATE TYPE TypeRequestState AS ENUM (
    'pendente',
    'accettata',
    'rifiutata',
    'scaduta',
    'annullata'
);

CREATE TYPE TypeOrganization AS ENUM (
    'agency',
    'crew',
    'collective',
    'individual'

);

CREATE TYPE TypeAccountState AS ENUM (
    'attivo',
    'warning',
    'congelato'
);

--INSERIMENTO DELLE TABLE

CREATE TABLE Nation (
    nome VARCHAR(50) PRIMARY KEY
);

CREATE TABLE Region (
    nome VARCHAR(50) PRIMARY KEY,
    nation VARCHAR NOT NULL,
    CONSTRAINT fk_region_nation
        FOREIGN KEY (nation) REFERENCES Nation(nome)
);

CREATE TABLE City (
    nome VARCHAR(50) PRIMARY KEY,
    region VARCHAR NOT NULL,
    CONSTRAINT fk_city_region
        FOREIGN KEY (region) REFERENCES Region(nome)
);

CREATE TABLE Address (
    id SERIAL PRIMARY KEY,
    via Via NOT NULL,
    numeroCivico Civico NOT NULL,
    cap CAP NOT NULL,
    geo_coords GeoCoord NOT NULL,
    city VARCHAR NOT NULL,
    CONSTRAINT fk_address_city
        FOREIGN KEY (city) REFERENCES City(nome)
);


CREATE TABLE Person (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cognome VARCHAR(100) NOT NULL,
    numeroTelefono PhoneNumber NOT NULL UNIQUE,
    email Email NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    data_creazione TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ArtisticDirector(
    id INTEGER PRIMARY KEY,
    CONSTRAINT fk_director_person
        FOREIGN KEY(id) REFERENCES Person(id)
        ON DELETE CASCADE
);

CREATE TABLE Venue(
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    numeroTelefono PhoneNumber NOT NULL UNIQUE,
    email Email NOT NULL UNIQUE,
    configurazione_sala TypeVenue NOT NULL,
    capienza IntGZ NOT NULL,
    strumentazione TEXT NOT NULL,
    indirizzo_id INTEGER NOT NULL,
    director_id INTEGER NOT NULL,
    CONSTRAINT fk_venue_address
        FOREIGN KEY(indirizzo_id) REFERENCES Address(id),
    CONSTRAINT fk_venue_director
        FOREIGN KEY (director_id) REFERENCES ArtisticDirector(id)
        ON DELETE CASCADE
);

CREATE TABLE Organization (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    tipo TypeOrganization NOT NULL,
    storico_eventi TEXT
    
);
CREATE TABLE Genre (
    nome VARCHAR(50) PRIMARY KEY
);

CREATE TABLE Category (
    nome VARCHAR(50) PRIMARY key
);

CREATE TABLE Artist(
    id SERIAL PRIMARY KEY,
    nome VARCHAR (100) NOT NULL,
    cachet RealGEZ NOT NULL,
    negotiable BOOLEAN NOT NULL,
    linkStreaming VARCHAR (255),
    fileUpload VARCHAR (500),
    representative_id INTEGER NOT NULL,
    genre VARCHAR(50) NOT NULL,
    category VARCHAR NOT NULL,
    city_name VARCHAR NOT NULL,
    CONSTRAINT fk_artist_city
        FOREIGN KEY (city_name) REFERENCES City(nome),
    CONSTRAINT fk_artist_representative
        FOREIGN KEY (representative_id) REFERENCES Person(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_artist_genre
        FOREIGN KEY(genre)REFERENCES Genre(nome)
        ON UPDATE CASCADE,
    CONSTRAINT fk_artist_category
        FOREIGN KEY(category)REFERENCES Category(nome)
        ON UPDATE CASCADE,
    CONSTRAINT check_media_obbligatory CHECK (
        linkStreaming IS NOT NULL
        OR
        fileUpload IS NOT NULL
    )
);

CREATE TABLE Soloist (
    id INTEGER PRIMARY KEY,
    CONSTRAINT fk_soloist_artist
        FOREIGN KEY (id) REFERENCES Artist(id)
        ON DELETE CASCADE
);

CREATE TABLE Band(
    id INTEGER PRIMARY KEY,
    CONSTRAINT fk_band_artist
        FOREIGN KEY (id) REFERENCES Artist(id)
        ON DELETE CASCADE
);

CREATE TABLE Promoter (
    id INTEGER PRIMARY KEY,
    organization_id INTEGER NOT NULL,
    CONSTRAINT fk_promoter_person
        FOREIGN KEY(id) REFERENCES Person(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_promoter_organization
        FOREIGN KEY(organization_id) REFERENCES Organization(id)
);

CREATE TABLE Photo (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100),
    source VARCHAR(500) NOT NULL,
    venue_id INTEGER NOT NULL,
    CONSTRAINT fk_photo_venue
        FOREIGN KEY (venue_id) REFERENCES Venue(id)
        ON DELETE CASCADE
);

CREATE TABLE Slot(
    id SERIAL PRIMARY KEY,
    venue_id INTEGER NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    stato TypeSlotState DEFAULT 'disponibile',
    CONSTRAINT fk_slot_venue
        FOREIGN KEY (venue_id) REFERENCES Venue(id)
        ON DELETE CASCADE,
    CONSTRAINT check_slot_time CHECK (end_time > start_time)
);


CREATE TABLE Booking (
    id SERIAL PRIMARY KEY,
    introductory_message TEXT NOT NULL,
    data_scadenza TIMESTAMP NOT NULL,
    istante_creazione TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    stato_richiesta TypeRequestState DEFAULT 'pendente',
    motivazione_annullamento TEXT,
    slot_id INTEGER NOT NULL,
    artist_id INTEGER NOT NULL,
    promoter_id INTEGER ,
    CONSTRAINT fk_booking_slot
        FOREIGN KEY (slot_id) REFERENCES Slot(id),
    CONSTRAINT fk_booking_artist
        FOREIGN KEY (artist_id) REFERENCES Artist(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_booking_promoter
        FOREIGN KEY (promoter_id) REFERENCES Promoter(id)
        ON DELETE SET NULL
);


CREATE TABLE Review (
    id SERIAL PRIMARY KEY,
    booking_id INTEGER NOT NULL UNIQUE,
    vote INTEGER NOT NULL CHECK (vote BETWEEN 1 AND 5),
    comment TEXT,
    data_creazione TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    author_id INTEGER NOT NULL,
    CONSTRAINT fk_review_booking
        FOREIGN KEY (booking_id) REFERENCES booking(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_review_author
        FOREIGN KEY (author_id) REFERENCES Person(id)
);


CREATE TABLE AccountState (
    id SERIAL PRIMARY KEY,
    person_id INTEGER NOT NULL UNIQUE,
    strike_count INTEGER DEFAULT 0 CHECK (strike_count >= 0),
    stato TypeAccountState DEFAULT 'attivo',
    ban_date TIMESTAMP,
    
    CONSTRAINT fk_state_person
        FOREIGN KEY (person_id) REFERENCES Person(id)
        ON DELETE CASCADE
);

CREATE TABLE Sanction (
    id SERIAL PRIMARY KEY,
    booking_id INTEGER NOT NULL,
    reason TEXT,
    data_creazione TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sanction_booking
        FOREIGN KEY(booking_id) REFERENCES Booking(id)
        ON DELETE CASCADE
);

CREATE TABLE Chat (
    id SERIAL PRIMARY KEY,
    booking_id INTEGER NOT NULL UNIQUE,
    is_active BOOLEAN DEFAULT TRUE,
    
    CONSTRAINT fk_chat_booking
        FOREIGN KEY (booking_id) REFERENCES Booking(id)
        ON DELETE CASCADE
);

CREATE TABLE Message (
    id SERIAL PRIMARY KEY,
    chat_id INTEGER NOT NULL,
    sender_id INTEGER NOT NULL,
    content TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_message_chat
        FOREIGN KEY (chat_id) REFERENCES Chat(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_message_sender
        FOREIGN KEY (sender_id) REFERENCES Person(id)
);


--FUNZIONI E TRIGGER

-- Funzione di controllo
CREATE OR REPLACE FUNCTION check_review_eligibility()
RETURNS TRIGGER AS $$
DECLARE
    booking_status TypeRequestState;
    event_end TIMESTAMP;
BEGIN
    -- Recuperiamo lo stato e la fine dell'evento
    SELECT b.stato_richiesta, s.end_time 
    INTO booking_status, event_end
    FROM Booking b
    JOIN Slot s ON b.slot_id = s.id
    WHERE b.id = NEW.booking_id;

    -- 1. Controllo Stato
    IF booking_status NOT IN ('accettata', 'annullata') THEN
        RAISE EXCEPTION 'Errore: Non puoi recensire una prenotazione in stato %', booking_status;
    END IF;

    -- 2. Controllo Temporale (Solo per eventi accettati)
    IF booking_status = 'accettata' AND CURRENT_TIMESTAMP < event_end THEN
        RAISE EXCEPTION 'Errore: Non puoi recensire un evento non ancora concluso.';
    END IF;
    
    -- 3. Controllo Temporale Annullata (La recensione deve essere successiva alla creazione prenotazione)
    -- Questo è implicito perché NEW.data_creazione è DEFAULT NOW()

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger
CREATE TRIGGER trigger_review_eligibility
BEFORE INSERT ON Review
FOR EACH ROW EXECUTE FUNCTION check_review_eligibility();


-- PARTE A: Impedire sanzioni illegali
CREATE OR REPLACE FUNCTION check_sanction_validity()
RETURNS TRIGGER AS $$
DECLARE
    b_status TypeRequestState;
BEGIN
    SELECT stato_richiesta INTO b_status FROM Booking WHERE id = NEW.booking_id;
    
    IF b_status <> 'scaduta' THEN
        RAISE EXCEPTION 'Errore: Le sanzioni si applicano solo a prenotazioni SCADUTE.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_sanction_check
BEFORE INSERT ON Sanction
FOR EACH ROW EXECUTE FUNCTION check_sanction_validity();

-- PARTE B: Creazione Automatica Sanzione (Viceversa)
-- Questo trigger scatta quando aggiorni lo stato della Booking a 'scaduta'
CREATE OR REPLACE FUNCTION auto_create_sanction()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.stato_richiesta = 'scaduta' AND OLD.stato_richiesta <> 'scaduta' THEN
        INSERT INTO Sanction (booking_id, reason)
        VALUES (NEW.id, 'Timeout: La prenotazione è scaduta senza risposta.');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_auto_sanction_on_expire
AFTER UPDATE OF stato_richiesta ON Booking
FOR EACH ROW EXECUTE FUNCTION auto_create_sanction();


ALTER TABLE Booking
ADD CONSTRAINT check_motivazione_annullamento
CHECK (
    (stato_richiesta = 'annullata' AND motivazione_annullamento IS NOT NULL AND length(trim(motivazione_annullamento)) > 0)
    OR
    (stato_richiesta <> 'annullata')
);




-- 2. Creiamo l'Indice Parziale (La vera magia)
-- Questo dice: "Slot ID deve essere unico SOLO TRA le righe che hanno stato 'accettata'"
CREATE UNIQUE INDEX idx_one_accepted_booking_per_slot 
ON Booking (slot_id) 
WHERE stato_richiesta = 'accettata';


CREATE OR REPLACE FUNCTION check_chat_activation()
RETURNS TRIGGER AS $$
DECLARE
    b_status TypeRequestState;
BEGIN
    SELECT stato_richiesta INTO b_status FROM Booking WHERE id = NEW.booking_id;
    
    IF b_status <> 'accettata' THEN
        RAISE EXCEPTION 'Errore: La chat può essere attivata solo per prenotazioni ACCETTATE.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_chat_activation
BEFORE INSERT ON Chat
FOR EACH ROW EXECUTE FUNCTION check_chat_activation();


-- Procedura unica per gestire il cambio stato (Accetta / Rifiuta / Annulla)
CREATE OR REPLACE PROCEDURE gestisci_prenotazione(
    p_booking_id INTEGER,
    p_azione VARCHAR, -- 'accetta', 'rifiuta', 'annulla'
    p_motivo TEXT DEFAULT NULL -- Obbligatorio solo per annulla
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_stato_attuale TypeRequestState;
    v_slot_id INTEGER;
    v_event_start TIMESTAMP;
BEGIN
    -- Recupero dati correnti
    SELECT b.stato_richiesta, b.slot_id, s.start_time
    INTO v_stato_attuale, v_slot_id, v_event_start
    FROM Booking b
    JOIN Slot s ON b.slot_id = s.id
    WHERE b.id = p_booking_id;

    -- AZIONE: ACCETTA
    IF p_azione = 'accetta' THEN
        -- Pre-condizione: deve essere PENDENTE
        IF v_stato_attuale <> 'pendente' THEN
            RAISE EXCEPTION 'Errore: Puoi accettare solo prenotazioni PENDENTI.';
        END IF;

        -- Post-condizioni
        UPDATE Booking SET stato_richiesta = 'accettata' WHERE id = p_booking_id;
        UPDATE Slot SET stato = 'occupato' WHERE id = v_slot_id;
        
        -- Nota: Rifiutare automaticamente le altre richieste sullo stesso slot?
        -- Per ora lasciamo che restino pendenti o si gestiscano a parte, come da specifica base.

    -- AZIONE: RIFIUTA
    ELSIF p_azione = 'rifiuta' THEN
        -- Pre-condizione: deve essere PENDENTE
        IF v_stato_attuale <> 'pendente' THEN
            RAISE EXCEPTION 'Errore: Puoi rifiutare solo prenotazioni PENDENTI.';
        END IF;

        -- Post-condizioni
        UPDATE Booking SET stato_richiesta = 'rifiutata' WHERE id = p_booking_id;
        -- Lo slot torna disponibile (o resta disponibile se lo era già)
        UPDATE Slot SET stato = 'disponibile' WHERE id = v_slot_id;

    -- AZIONE: ANNULLA
    ELSIF p_azione = 'annulla' THEN
        -- Pre-condizione 1: deve essere ACCETTATA
        IF v_stato_attuale <> 'accettata' THEN
            RAISE EXCEPTION 'Errore: Puoi annullare solo prenotazioni ACCETTATE.';
        END IF;
        
        -- Pre-condizione 2: Motivo obbligatorio
        IF p_motivo IS NULL OR length(trim(p_motivo)) = 0 THEN
            RAISE EXCEPTION 'Errore: Devi specificare un motivo per l''annullamento.';
        END IF;

        -- Pre-condizione 3: Evento non ancora avvenuto
        IF v_event_start <= CURRENT_TIMESTAMP THEN
             RAISE EXCEPTION 'Errore: Non puoi annullare un evento già iniziato o passato.';
        END IF;

        -- Post-condizioni
        UPDATE Booking 
        SET stato_richiesta = 'annullata', 
            motivazione_annullamento = p_motivo 
        WHERE id = p_booking_id;
        
        UPDATE Slot SET stato = 'disponibile' WHERE id = v_slot_id;

    ELSE
        RAISE EXCEPTION 'Azione non riconosciuta: %', p_azione;
    END IF;
END;
$$;


-- Funzione Trigger che scatta ad ogni modifica degli strike
CREATE OR REPLACE FUNCTION aggiorna_stato_account()
RETURNS TRIGGER AS $$
DECLARE
    -- Configuriamo qui le soglie (facili da cambiare in futuro)
    SOGLIA_WARNING CONSTANT INTEGER := 2;
    SOGLIA_BAN CONSTANT INTEGER := 3;
BEGIN
    -- Se gli strike non sono cambiati, non fare nulla
    IF NEW.strike_count = OLD.strike_count THEN
        RETURN NEW;
    END IF;

    -- Logica aggiornaStato()
    IF NEW.strike_count >= SOGLIA_BAN THEN
        NEW.stato := 'congelato';
        NEW.ban_date := CURRENT_TIMESTAMP; -- "this.istante diventa data corrente"
    ELSIF NEW.strike_count >= SOGLIA_WARNING THEN
        NEW.stato := 'warning';
    ELSE
        NEW.stato := 'attivo';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Colleghiamo il trigger alla tabella AccountState
CREATE TRIGGER trigger_update_account_status
BEFORE UPDATE OF strike_count ON AccountState
FOR EACH ROW EXECUTE FUNCTION aggiorna_stato_account();

-- Operazione Helper: incrementaStrike()
-- Si usa così: CALL incrementa_strike(123);
CREATE OR REPLACE PROCEDURE incrementa_strike(p_person_id INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE AccountState
    SET strike_count = strike_count + 1
    WHERE person_id = p_person_id;
    -- Il trigger sopra farà automaticamente aggiornaStato()
END;
$$;

-- Funzione di Ricerca Artisti
-- Restituisce una tabella virtuale con i risultati filtrati
CREATE OR REPLACE FUNCTION esegui_ricerca_artisti(
    p_genre_filter VARCHAR DEFAULT NULL,
    p_region_filter VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    artist_id INTEGER,
    nome_artista VARCHAR,
    genere VARCHAR,
    zona VARCHAR,
    cachet RealGEZ,
    contatti_visibili TEXT -- Mascherati o visibili
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.id,
        a.nome,
        a.genre,
        addr.city || ' (' || r.nome || ')',
        a.cachet,
        CASE
            -- Logica semplificata: Nella ricerca pubblica i contatti sono SEMPRE nascosti.
            -- I contatti si vedono solo dopo aver accettato la prenotazione (gestito altrove).
            WHEN acc.stato = 'congelato' THEN 'ACCOUNT SOSPESO'
            ELSE 'Contatti disponibili dopo prenotazione'
        END
    FROM Artist a
    JOIN Person p ON a.representative_id = p.id
    JOIN AccountState acc ON acc.person_id = p.id
    -- Join per la geografia (assumendo che l'artista abbia una sede/indirizzo nel profilo persona o separato)
    -- Per semplicità qui uso una join fittizia, nella realtà avresti l'indirizzo dell'artista
    LEFT JOIN Address addr ON 1=1 -- (Da collegare correttamente nel tuo modello dati specifico)
    LEFT JOIN City c ON addr.city = c.nome
    LEFT JOIN Region r ON c.region = r.nome
    WHERE
        acc.stato <> 'congelato' -- Esclude account congelati
        AND (p_genre_filter IS NULL OR a.genre = p_genre_filter)
        AND (p_region_filter IS NULL OR r.nome = p_region_filter);
END;
$$;

CREATE OR REPLACE PROCEDURE invia_messaggio(
    p_booking_id INTEGER,
    p_sender_id INTEGER,
    p_testo TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_chat_id INTEGER;
    v_booking_state TypeRequestState;
BEGIN
    -- 1. Recupera stato prenotazione e ID chat
    SELECT b.stato_richiesta, c.id
    INTO v_booking_state, v_chat_id
    FROM Booking b
    LEFT JOIN Chat c ON c.booking_id = b.id
    WHERE b.id = p_booking_id;

    -- Pre-condizione: Prenotazione deve essere ACCETTATA
    IF v_booking_state <> 'accettata' THEN
        RAISE EXCEPTION 'Errore: Puoi inviare messaggi solo se la prenotazione è ACCETTATA.';
    END IF;

    -- Pre-condizione: Testo non vuoto
    IF length(trim(p_testo)) = 0 THEN
        RAISE EXCEPTION 'Errore: Il messaggio non può essere vuoto.';
    END IF;

    -- Se la chat non esiste ancora (magari è il primo messaggio), creala
    IF v_chat_id IS NULL THEN
        INSERT INTO Chat (booking_id, is_active) VALUES (p_booking_id, TRUE)
        RETURNING id INTO v_chat_id;
    END IF;

    -- Inserimento Messaggio
    INSERT INTO Message (chat_id, sender_id, content, sent_at)
    VALUES (v_chat_id, p_sender_id, p_testo, CURRENT_TIMESTAMP);
END;
$$;



COMMIT;


