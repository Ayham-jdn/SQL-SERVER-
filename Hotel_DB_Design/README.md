🏨 Hotel Reservation Database




📌 Overview

A relational database schema for a luxury hotel chain to manage:

Hotels & Rooms

Guests & Reservations

Payments & Services

Hotel Staff

Supports realistic business rules: many-to-many relationships, composite keys, and referential integrity.

⚡ Features

Hotels with unique IDs, managers, and contact info

Rooms unique per hotel, with type, capacity, daily rate, and amenities

Guests with multiple reservations and contact details

Reservations linked to guests and rooms

Payments supporting multiple installments

Services linked to staff and reservations

🚀 Usage

Open HotelReservation.sql in SQL Server Management Studio (SSMS)

Execute the script to create the database and tables

Optionally, add sample data for testing

📂 Repository Structure
HotelReservation-DB/
├─ HotelReservation.sql
├─ README.md
└─ Documents/ (optional)

📜 License

Open source, free for educational and demonstration purposes.

```mermaid
erDiagram

    HOTELS {
        int Id PK
        string Name
        int StarRating
        string Address
        string City
        string ContactNumber
        int ManagerId FK
    }

    STAFF {
        int Id PK
        string FullName
        string Position
        decimal Salary
        int HotelId FK
    }

    ROOMS {
        int RoomNumber PK
        string RoomType
        int Capacity
        decimal DailyRate
        string AvailabilityStatus
        int HotelId FK
    }

    AMENITIES {
        string AmenityName PK
        int RoomNumber FK
    }

    GUESTS {
        int Id PK
        string FullName
        date DateOfBirth
        string Nationality
        string PassportNumber
    }

    RESERVATIONS {
        int Id PK
        date BookingDate
        date CheckInDate
        date CheckOutDate
        int NumberOfAdults
        int NumberOfChildren
        decimal TotalPrice
        string ReservationStatus
    }

    PAYMENTS {
        int Id PK
        date PaymentDate
        decimal Amount
        string PaymentMethod
        string ConfirmationNumber
    }

    SERVICES {
        int Id PK
        string ServiceName
        date RequestDate
        decimal Charge
        int StaffId FK
    }

    HOTELS ||--o{ STAFF : employs
    HOTELS ||--o{ ROOMS : contains
    ROOMS ||--o{ AMENITIES : has

    GUESTS }o--o{ RESERVATIONS : books
    RESERVATIONS }o--o{ ROOMS : includes
    RESERVATIONS }o--o{ PAYMENTS : paid_by
    RESERVATIONS }o--o{ SERVICES : requests
    STAFF ||--o{ SERVICES : provides
