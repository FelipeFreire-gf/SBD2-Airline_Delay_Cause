-- ============================================================================
-- GOLD LAYER: STAR SCHEMA - DDL
-- Business Objective: Airline Operations Manager - Flight Delay Analysis
-- Dataset: Airline Delay and Cancellation Data (2013-2023)
-- ============================================================================

DROP SCHEMA IF EXISTS dw CASCADE;
CREATE SCHEMA dw;

-- ============================================================================
-- DIMENSION 1: COMPANHIA AÉREA (CARRIER)
-- ============================================================================
CREATE TABLE dw.dim_carrier (
    carrier_srk SERIAL PRIMARY KEY,
    carrier_code VARCHAR(10) UNIQUE NOT NULL,
    carrier_name VARCHAR(200),
    data_atualizacao TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- DIMENSION 2: AEROPORTO
-- ============================================================================
CREATE TABLE dw.dim_airport (
    airport_srk SERIAL PRIMARY KEY,
    airport_code VARCHAR(10) UNIQUE NOT NULL,
    airport_name VARCHAR(200),
    data_atualizacao TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- DIMENSION 3: TEMPO
-- ============================================================================
CREATE TABLE dw.dim_time (
    time_srk SERIAL PRIMARY KEY,
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    trimestre INTEGER,
    semestre INTEGER,
    mes_nome VARCHAR(20),
    mes_ano VARCHAR(7),
    ano_trimestre VARCHAR(7),
    UNIQUE(year, month)
);

-- ============================================================================
-- DIMENSION 4: CAUSA DE ATRASO
-- ============================================================================
CREATE TABLE dw.dim_delay_cause (
    delay_cause_srk SERIAL PRIMARY KEY,
    delay_cause_code VARCHAR(20) UNIQUE NOT NULL,
    delay_cause_name VARCHAR(100) NOT NULL,
    delay_cause_description VARCHAR(500)
);

-- ============================================================================
-- FACT TABLE: ATRASOS DE VOOS
-- ============================================================================
CREATE TABLE dw.fact_flight_delays (
    carrier_srk INTEGER NOT NULL REFERENCES dw.dim_carrier(carrier_srk),
    airport_srk INTEGER NOT NULL REFERENCES dw.dim_airport(airport_srk),
    time_srk INTEGER NOT NULL REFERENCES dw.dim_time(time_srk),
    delay_cause_srk INTEGER NOT NULL REFERENCES dw.dim_delay_cause(delay_cause_srk),
    arr_flights DECIMAL(10,2),
    arr_del15 DECIMAL(10,2),
    arr_cancelled DECIMAL(10,2),
    arr_diverted DECIMAL(10,2),
    delay_count DECIMAL(10,2),
    delay_minutes DECIMAL(10,2),
    arr_delay DECIMAL(10,2),
    delay_rate DECIMAL(5,2),
    cancellation_rate DECIMAL(5,2),
    diversion_rate DECIMAL(5,2),
    avg_delay_minutes DECIMAL(10,2),
    on_time_rate DECIMAL(5,2),
    PRIMARY KEY (carrier_srk, airport_srk, time_srk, delay_cause_srk)
);

-- ============================================================================
-- FIM DO DDL
-- ============================================================================
