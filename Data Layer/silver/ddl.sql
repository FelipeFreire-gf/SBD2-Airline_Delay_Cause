CREATE SCHEMA IF NOT EXISTS silver;

DROP TABLE IF EXISTS silver.airline_delays CASCADE;

CREATE TABLE silver.airline_delays (
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    carrier VARCHAR(10) NOT NULL,
    carrier_name VARCHAR(200),
    airport VARCHAR(10) NOT NULL,
    airport_name VARCHAR(200),
    
    arr_flights DECIMAL(10,2),
    arr_del15 DECIMAL(10,2),
    
    carrier_ct DECIMAL(10,2),
    weather_ct DECIMAL(10,2),
    nas_ct DECIMAL(10,2),
    security_ct DECIMAL(10,2),
    late_aircraft_ct DECIMAL(10,2),
    
    arr_cancelled DECIMAL(10,2),
    arr_diverted DECIMAL(10,2),
    
    arr_delay DECIMAL(10,2),
    carrier_delay DECIMAL(10,2),
    weather_delay DECIMAL(10,2),
    nas_delay DECIMAL(10,2),
    security_delay DECIMAL(10,2),
    late_aircraft_delay DECIMAL(10,2),
    
    PRIMARY KEY (year, month, carrier, airport)
);

