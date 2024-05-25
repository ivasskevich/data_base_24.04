-- Создать базу данных Airport
CREATE DATABASE Airport;
go
-- Переключиться на базу данных Airport
USE Airport;
go
-- Создать таблицу "Самолеты" (Airplanes)
CREATE TABLE Airplanes (
    airplane_id INT identity(1, 1) PRIMARY KEY,
    airplane_model VARCHAR(100),
    capacity_business INT,
    capacity_economy INT
);
go
-- Создать таблицу "Рейсы" (Flights)
CREATE TABLE Flights (
    flight_id INT identity(1, 1) PRIMARY KEY,
    airplane_id INT,
    destination VARCHAR(100),
    departure_time DATETIME,
    arrival_time DATETIME,
    available_business_seats INT,
    available_economy_seats INT,
    FOREIGN KEY (airplane_id) REFERENCES Airplanes(airplane_id)
);
go
-- Создать таблицу "Пассажиры" (Passengers)
CREATE TABLE Passengers (
    passenger_id INT identity(1, 1) PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    passport_number VARCHAR(20)
);
go
-- Создать таблицу "Билеты" (Tickets)
CREATE TABLE Tickets (
    ticket_id INT identity(1, 1) PRIMARY KEY,
    flight_id INT,
    passenger_id INT,
    class VARCHAR(20), -- 'бизнес' или 'эконом'
    price DECIMAL(10, 2),
    sale_date DATE,
    FOREIGN KEY (flight_id) REFERENCES Flights(flight_id),
    FOREIGN KEY (passenger_id) REFERENCES Passengers(passenger_id)
);
go



INSERT INTO Airplanes (airplane_model, capacity_business, capacity_economy)
VALUES 
    ('Boeing 747', 20, 300),
    ('Airbus A320', 15, 150),
    ('Boeing 737', 12, 180);

go
INSERT INTO Flights (airplane_id, destination, departure_time, arrival_time, available_business_seats, available_economy_seats)
VALUES 
    (1, 'New York', '2024-04-25 08:00:00', '2024-04-25 16:00:00', 20, 150),
    (2, 'Los Angeles', '2024-04-26 10:00:00', '2024-04-26 14:00:00', 10, 100),
    (3, 'Chicago', '2024-04-27 12:00:00', '2024-04-27 14:30:00', 10, 140);

go
INSERT INTO Passengers (first_name, last_name, passport_number)
VALUES 
    ('John', 'Doe', 'P123456'),
    ('Jane', 'Smith', 'P654321'),
    ('Michael', 'Johnson', 'P987654');

go
INSERT INTO Tickets (flight_id, passenger_id, class, price, sale_date)
VALUES 
    (1, 1, 'бизнес', 500.00, '2024-04-24'),
    (2, 2, 'эконом', 200.00, '2024-04-24'),
    (3, 3, 'эконом', 150.00, '2024-04-24');
go


CREATE FUNCTION GetFlightsToCityOnDate(@city VARCHAR(100), @date DATE)
RETURNS TABLE
AS
RETURN
(
    SELECT flight_id, airplane_id, destination, departure_time, arrival_time, available_business_seats, available_economy_seats
    FROM Flights
    WHERE destination = @city
    AND CAST(departure_time AS DATE) = @date
    ORDER BY departure_time;
);


CREATE FUNCTION GetLongestFlight()
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 1 *,
        DATEDIFF(MINUTE, departure_time, arrival_time) AS duration
    FROM Flights
    ORDER BY duration DESC
);



CREATE FUNCTION GetLongFlights()
RETURNS TABLE
AS
RETURN
(
    SELECT *
    FROM Flights
    WHERE DATEDIFF(MINUTE, departure_time, arrival_time) > 120
);


CREATE FUNCTION GetFlightCountPerCity()
RETURNS TABLE
AS
RETURN
(
    SELECT destination, COUNT(*) AS flight_count
    FROM Flights
    GROUP BY destination
);


CREATE FUNCTION GetMostFrequentDestination()
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 1 destination, COUNT(*) AS flight_count
    FROM Flights
    GROUP BY destination
    ORDER BY flight_count DESC
);


CREATE FUNCTION GetFlightCountByMonth(@month VARCHAR(7))
RETURNS TABLE
AS
RETURN
(
    SELECT destination, COUNT(*) AS flight_count
    FROM Flights
    WHERE FORMAT(departure_time, 'yyyy-MM') = @month
    GROUP BY destination
);


CREATE FUNCTION GetFlightsTodayWithBusinessSeats()
RETURNS TABLE
AS
RETURN
(
    SELECT *
    FROM Flights
    WHERE CAST(departure_time AS DATE) = CAST(GETDATE() AS DATE)
    AND available_business_seats > 0
);


SELECT *
FROM GetFlightsToCityOnDate('New York', '2024-04-25');

SELECT *
FROM GetLongestFlight();

SELECT *
FROM GetLongFlights();

SELECT *
FROM GetFlightCountPerCity();

SELECT *
FROM GetMostFrequentDestination();

SELECT *
FROM GetFlightCountByMonth('2024-04');

SELECT *
FROM GetFlightsTodayWithBusinessSeats();




CREATE PROCEDURE GetTicketSalesOnDate(@date DATE)
AS
BEGIN
    SELECT
        COUNT(ticket_id) AS total_tickets_sold,
        SUM(price) AS total_amount
    FROM
        Tickets
    WHERE
        sale_date = @date;
END;


CREATE PROCEDURE GetTicketPresalesOnDate(@date DATE)
AS
BEGIN
    SELECT
        f.flight_id,
        f.destination,
        COUNT(t.ticket_id) AS tickets_sold
    FROM
        Flights f
    LEFT JOIN
        Tickets t ON f.flight_id = t.flight_id
    WHERE
        f.departure_time >= @date AND f.departure_time < DATEADD(DAY, 1, @date)
    GROUP BY
        f.flight_id, f.destination;
END;


CREATE PROCEDURE GetAllFlightsAndDestinations()
AS
BEGIN
    SELECT
        flight_id,
        destination
    FROM
        Flights
    GROUP BY
        flight_id, destination;
END;


EXEC GetTicketSalesOnDate('2024-04-24');
EXEC GetTicketPresalesOnDate('2024-04-24');
EXEC GetAllFlightsAndDestinations();
