CREATE DATABASE HotelReservation;
GO

USE HotelReservation;
GO

-- Stores hotel information
CREATE TABLE Hotels
(
    Id INT IDENTITY PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    StarRating INT CHECK (StarRating BETWEEN 1 AND 5),
    Address VARCHAR(150),
    City VARCHAR(100),
    ContactNumber VARCHAR(20),
    ManagerId INT UNIQUE  -- Circular FK added later
);

-- Stores hotel employees
CREATE TABLE Staff
(
    Id INT IDENTITY PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Position VARCHAR(100) NOT NULL,
    Salary DECIMAL(10,2) CHECK (Salary >= 0),
    HotelId INT NOT NULL 
        REFERENCES Hotels(Id)
        ON DELETE CASCADE
);

-- Hotel → Manager (Manager is a staff member)
ALTER TABLE Hotels
ADD CONSTRAINT FK_Hotel_Manager
FOREIGN KEY (ManagerId)
REFERENCES Staff(Id)
ON DELETE SET NULL;
GO

ALTER TABLE Staff
DROP CONSTRAINT FK__Staff__HotelId__3C69FB99;

-- Hotel rooms
CREATE TABLE Rooms
(
    RoomNumber INT PRIMARY KEY IDENTITY ,
    RoomType VARCHAR(50) NOT NULL,
    Capacity INT NOT NULL,
    DailyRate DECIMAL(10,2),
    AvailabilityStatus VARCHAR(20) NOT NULL,
    HotelId INT NOT NULL
        REFERENCES Hotels(Id)
        ON DELETE CASCADE
);

-- Amenities available per room
CREATE TABLE Amenities
(
    AmenityName VARCHAR(100) NOT NULL,
    RoomNumber INT REFERENCES Rooms(RoomNumber)
        ON DELETE CASCADE,
    PRIMARY KEY (AmenityName, RoomNumber)
);

-- Stores guest personal information
CREATE TABLE Guests
(
    Id INT IDENTITY PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    DateOfBirth DATE,
    Nationality VARCHAR(100),
    PassportNumber VARCHAR(50) UNIQUE
);

-- Stores multiple contact details per guest 
CREATE TABLE Guest_Contact_Details
(
    ContactDetail VARCHAR(100) NOT NULL,
    GuestId INT NOT NULL  
        REFERENCES Guests(Id)
        ON DELETE CASCADE,
    PRIMARY KEY (ContactDetail, GuestId)
);

-- Stores booking and stay details for reservations
CREATE TABLE Reservations
(
    Id INT IDENTITY PRIMARY KEY,
    BookingDate DATE NOT NULL,
    CheckInDate DATE,
    CheckOutDate DATE,
    NumberOfAdults INT,
    NumberOfChildren INT ,
    TotalPrice DECIMAL(10,2) NOT NULL,
    ReservationStatus VARCHAR(30) NOT NULL
);

-- RESERVATION ↔ GUEST
CREATE TABLE Reservation_Guest
(
    ReservationId INT NOT NULL 
        REFERENCES Reservations(Id)
        ON DELETE CASCADE,
    GuestId INT NOT NULL     
        REFERENCES Guests(Id)
        ON DELETE NO ACTION,
    PRIMARY KEY (ReservationId, GuestId)
);

-- RESERVATION ↔ ROOM 
CREATE TABLE Reservation_Room
(
    ReservationId INT NOT NULL        
        REFERENCES Reservations(Id)
        ON DELETE CASCADE,
    RoomNumber INT NOT NULL    
        REFERENCES Rooms(RoomNumber)
        ON DELETE NO ACTION,
    PRIMARY KEY (ReservationId, RoomNumber)
);

-- Stores payment transactions
CREATE TABLE Payments
(
    Id INT IDENTITY PRIMARY KEY,
    PaymentDate DATE NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    PaymentMethod VARCHAR(30) NOT NULL,
    ConfirmationNumber VARCHAR(50) UNIQUE NOT NULL
);

--   RESERVATION ↔ PAYMENT
CREATE TABLE Reservation_Payment
(
    ReservationId INT NOT NULL
        REFERENCES Reservations(Id)
        ON DELETE CASCADE,
    PaymentId INT NOT NULL
        REFERENCES Payments(Id)
        ON DELETE NO ACTION,
    PRIMARY KEY (ReservationId, PaymentId)
);

-- Additional services provided during a reservation
CREATE TABLE Services
(
    Id INT IDENTITY PRIMARY KEY,
    ServiceName VARCHAR(100) NOT NULL,
    RequestDate DATE NOT NULL,
    Charge DECIMAL(10,2) NOT NULL,
    StaffId INT NOT NULL     
        REFERENCES Staff(Id)
        ON DELETE NO ACTION
);


-- RESERVATION ↔ SERVICE
CREATE TABLE Reservation_Service
(
    ReservationId INT NOT NULL
        REFERENCES Reservations(Id)
        ON DELETE CASCADE,
    ServiceId INT NOT NULL
        REFERENCES Services(Id)
        ON DELETE CASCADE,
    PRIMARY KEY (ReservationId, ServiceId)
);

