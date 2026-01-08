# EasyGIG  - Live Music Booking Platform

**EasyGIG** is a web platform designed to streamline and digitize the booking process between **Venues** and **Music Artists**. The goal is to solve the "empty calendar" problem for venue managers and the struggle of finding gigs for bands, starting with a hyper-local, data-driven approach.

##  Key Features
* **User Management:** Distinct roles for Artists (Bands/Soloists), Art Directors, and Promoters.
* **Smart Booking:** "Slot" system (time windows) provided by venues for artists to apply.
* **Advanced Database:** Complex business logic (overlap checks, fee validation, state management) implemented directly in SQL layers.
* **Search Engine:** High-performance filtering by Genre, Location (Region/City), and availability.

## 🛠 Tech Stack
The project is built following a modular and scalable architecture:

* **Backend:** Python 3, Flask (Application Factory Pattern + Blueprints).
* **Database:** PostgreSQL 16.
    * Extensive use of `PL/pgSQL` (Stored Procedures & Functions).
    * Complex constraints (`CHECK`, `Foreign Keys`) and Triggers for data integrity.
    * Normalized geographic tables (Regions, Cities).
* **DB Driver:** `Psycopg2` implementing **Connection Pooling** for high performance.
* **Security:** Environment variable management (.env) and secure authentication flow.

## 📂 Project Structure
```text
/backend
├── app/
│   ├── routes/       # API Endpoints (Controllers)
│   ├── services/     # Business Logic layer
│   ├── db.py         # PostgreSQL Connection Pool Management
│   └── __init__.py   # Application Factory
├── db/               # SQL Scripts (Schema, Seed Data, Functions)
├── run.py            # Entry point
└── .env              # Configuration (Not included in repo)

The project is currently in **Alpha stage**. The following features are planned for the next release:

- [ ] **Authentication System:** JWT-based Login/Register for Artists and Venue Managers.
- [ ] **Booking Logic:** Complete flow for creating and accepting booking requests.
- [ ] **Dashboard:** User interface for managing profile and calendar.
- [ ] **Notification System:** Email/Real-time alerts for booking updates.
- [ ] **Frontend:** React/Vue.js integration (currently using API testing tools).

---