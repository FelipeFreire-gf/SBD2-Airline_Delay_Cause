-- ============================================================================
-- GOLD LAYER: CONSULTAS ANALÍTICAS PARA POWER BI
-- Queries otimizadas para análise de performance e atrasos de voos
-- Dataset: Airline Delay and Cancellation Data (2013-2023)
-- Total: 10 consultas estratégicas
-- ============================================================================

-- ============================================================================
-- 1. VERIFICAÇÃO DO SCHEMA DW
-- ============================================================================
SELECT 'dim_carrier' AS tabela, COUNT(*) AS linhas FROM dw.dim_carrier
UNION ALL
SELECT 'dim_airport' AS tabela, COUNT(*) AS linhas FROM dw.dim_airport
UNION ALL
SELECT 'dim_time' AS tabela, COUNT(*) AS linhas FROM dw.dim_time
UNION ALL
SELECT 'fact_flight_delays' AS tabela, COUNT(*) AS linhas FROM dw.fact_flight_delays
ORDER BY tabela;

-- ============================================================================
-- 2. DASHBOARD SUMMARY - MÉTRICAS GLOBAIS (KPIs PRINCIPAIS)
-- ============================================================================
-- Objetivo: KPIs principais para cards do Power BI
SELECT
    SUM(arr_flights) AS total_voos,
    SUM(arr_del15) AS total_atrasos,
    ROUND(AVG(delay_rate), 2) AS taxa_atraso_media,
    ROUND(AVG(on_time_rate), 2) AS taxa_pontualidade_media,
    ROUND(AVG(avg_delay_minutes), 2) AS atraso_medio,
    SUM(arr_cancelled) AS total_cancelamentos,
    SUM(arr_diverted) AS total_desvios,
    ROUND(AVG(cancellation_rate), 2) AS taxa_cancelamento_media,
    COUNT(DISTINCT srk_carrier) AS total_carriers,
    COUNT(DISTINCT srk_airport) AS total_airports
FROM dw.fact_flight_delays;

-- ============================================================================
-- 3. RANKING DE COMPANHIAS AÉREAS POR PONTUALIDADE
-- ============================================================================
-- Objetivo: Identificar melhores e piores companhias (para gráfico de barras)
WITH carrier_stats AS (
    SELECT
        c.carrier_code,
        c.carrier_name,
        SUM(f.arr_flights) AS total_voos,
        SUM(f.arr_del15) AS total_atrasos,
        ROUND(AVG(f.delay_rate), 2) AS taxa_atraso_pct,
        ROUND(AVG(f.on_time_rate), 2) AS taxa_pontualidade_pct,
        ROUND(AVG(f.avg_delay_minutes), 2) AS atraso_medio_minutos,
        SUM(f.arr_cancelled) AS total_cancelamentos,
        ROUND(AVG(f.cancellation_rate), 2) AS taxa_cancelamento_pct
    FROM dw.fact_flight_delays f
    JOIN dw.dim_carrier c ON f.srk_carrier = c.srk_carrier
    GROUP BY c.carrier_code, c.carrier_name
    HAVING SUM(f.arr_flights) >= 1000
)
SELECT *
FROM carrier_stats
ORDER BY taxa_pontualidade_pct DESC;

-- ============================================================================
-- 4. TOP 20 AEROPORTOS MAIS PROBLEMÁTICOS
-- ============================================================================
-- Objetivo: Identificar aeroportos com maiores problemas (para matriz de performance)
WITH airport_stats AS (
    SELECT
        a.airport_code,
        a.airport_name,
        SUM(f.arr_flights) AS total_voos,
        SUM(f.arr_del15) AS total_atrasos,
        ROUND(AVG(f.delay_rate), 2) AS taxa_atraso_pct,
        ROUND(AVG(f.avg_delay_minutes), 2) AS atraso_medio_minutos,
        SUM(f.arr_cancelled) AS total_cancelamentos,
        ROUND(AVG(f.cancellation_rate), 2) AS taxa_cancelamento_pct,
        SUM(f.arr_diverted) AS total_desvios,
        ROUND(AVG(f.diversion_rate), 2) AS taxa_desvio_pct
    FROM dw.fact_flight_delays f
    JOIN dw.dim_airport a ON f.srk_airport = a.srk_airport
    GROUP BY a.airport_code, a.airport_name
    HAVING SUM(f.arr_flights) >= 500
)
SELECT *
FROM airport_stats
ORDER BY taxa_atraso_pct DESC
LIMIT 20;

-- ============================================================================
-- 5. EVOLUÇÃO ANUAL DA PERFORMANCE (TENDÊNCIA TEMPORAL)
-- ============================================================================
-- Objetivo: Série temporal anual 2013-2023 (para gráfico de linha)
WITH yearly_performance AS (
    SELECT
        t.year,
        SUM(f.arr_flights) AS total_voos,
        SUM(f.arr_del15) AS total_atrasos,
        ROUND(AVG(f.delay_rate), 2) AS taxa_atraso_pct,
        ROUND(AVG(f.on_time_rate), 2) AS taxa_pontualidade_pct,
        ROUND(AVG(f.avg_delay_minutes), 2) AS atraso_medio_minutos,
        SUM(f.arr_cancelled) AS total_cancelamentos,
        SUM(f.arr_diverted) AS total_desvios
    FROM dw.fact_flight_delays f
    JOIN dw.dim_time t ON f.srk_time = t.srk_time
    GROUP BY t.year
)
SELECT *
FROM yearly_performance
ORDER BY year;

-- ============================================================================
-- 6. SAZONALIDADE MENSAL (PADRÕES RECORRENTES)
-- ============================================================================
-- Objetivo: Identificar meses críticos (para análise sazonal)
WITH monthly_aggregation AS (
    SELECT
        t.month,
        t.mes_nome,
        SUM(f.arr_flights) AS total_voos,
        SUM(f.arr_del15) AS total_atrasos,
        ROUND(AVG(f.delay_rate), 2) AS taxa_atraso_media,
        ROUND(AVG(f.avg_delay_minutes), 2) AS atraso_medio_minutos,
        SUM(f.arr_cancelled) AS total_cancelamentos,
        SUM(f.weather_ct) AS incidentes_meteorologicos,
        SUM(f.carrier_ct) AS incidentes_companhia,
        SUM(f.nas_ct) AS incidentes_nas
    FROM dw.fact_flight_delays f
    JOIN dw.dim_time t ON f.srk_time = t.srk_time
    GROUP BY t.month, t.mes_nome
)
SELECT *
FROM monthly_aggregation
ORDER BY month;

-- ============================================================================
-- 7. ANÁLISE DE CAUSAS DE ATRASOS - BREAKDOWN PERCENTUAL
-- ============================================================================
-- Objetivo: Contribuição de cada causa (para gráfico de pizza/donut)
WITH causa_totais AS (
    SELECT
        SUM(carrier_delay) AS carrier_delay_total,
        SUM(weather_delay) AS weather_delay_total,
        SUM(nas_delay) AS nas_delay_total,
        SUM(security_delay) AS security_delay_total,
        SUM(late_aircraft_delay) AS late_aircraft_delay_total,
        SUM(carrier_ct) AS carrier_ct_total,
        SUM(weather_ct) AS weather_ct_total,
        SUM(nas_ct) AS nas_ct_total,
        SUM(security_ct) AS security_ct_total,
        SUM(late_aircraft_ct) AS late_aircraft_ct_total
    FROM dw.fact_flight_delays
),
total_geral AS (
    SELECT 
        carrier_delay_total + weather_delay_total + nas_delay_total + 
        security_delay_total + late_aircraft_delay_total AS total_minutos
    FROM causa_totais
)
SELECT
    'Companhia Aérea' AS causa,
    ct.carrier_delay_total AS tempo_total_minutos,
    ct.carrier_ct_total AS contagem_incidentes,
    ROUND(100.0 * ct.carrier_delay_total / NULLIF(tg.total_minutos, 0), 2) AS percentual_contribuicao
FROM causa_totais ct, total_geral tg
UNION ALL
SELECT
    'Condições Meteorológicas' AS causa,
    ct.weather_delay_total,
    ct.weather_ct_total,
    ROUND(100.0 * ct.weather_delay_total / NULLIF(tg.total_minutos, 0), 2)
FROM causa_totais ct, total_geral tg
UNION ALL
SELECT
    'Sistema Nacional (NAS)' AS causa,
    ct.nas_delay_total,
    ct.nas_ct_total,
    ROUND(100.0 * ct.nas_delay_total / NULLIF(tg.total_minutos, 0), 2)
FROM causa_totais ct, total_geral tg
UNION ALL
SELECT
    'Segurança' AS causa,
    ct.security_delay_total,
    ct.security_ct_total,
    ROUND(100.0 * ct.security_delay_total / NULLIF(tg.total_minutos, 0), 2)
FROM causa_totais ct, total_geral tg
UNION ALL
SELECT
    'Aeronave Atrasada' AS causa,
    ct.late_aircraft_delay_total,
    ct.late_aircraft_ct_total,
    ROUND(100.0 * ct.late_aircraft_delay_total / NULLIF(tg.total_minutos, 0), 2)
FROM causa_totais ct, total_geral tg
ORDER BY tempo_total_minutos DESC;

-- ============================================================================
-- 8. IMPACTO METEOROLÓGICO POR MÊS (PADRÃO CLIMÁTICO)
-- ============================================================================
-- Objetivo: Identificar períodos com maiores problemas climáticos
WITH weather_impact_monthly AS (
    SELECT
        t.month,
        t.mes_nome,
        SUM(f.weather_ct) AS total_incidentes_clima,
        SUM(f.weather_delay) AS total_minutos_clima,
        ROUND(AVG(f.weather_delay), 2) AS media_minutos_clima,
        SUM(f.arr_flights) AS total_voos,
        ROUND(100.0 * SUM(f.weather_ct) / NULLIF(SUM(f.arr_flights), 0), 2) AS pct_voos_afetados
    FROM dw.fact_flight_delays f
    JOIN dw.dim_time t ON f.srk_time = t.srk_time
    WHERE f.weather_ct > 0
    GROUP BY t.month, t.mes_nome
)
SELECT *
FROM weather_impact_monthly
ORDER BY total_minutos_clima DESC;

-- ============================================================================
-- 9. MATRIZ CARRIER × AEROPORTO (TOP 10×10)
-- ============================================================================
-- Objetivo: Heatmap de performance das principais combinações
WITH top_carriers AS (
    SELECT srk_carrier
    FROM dw.fact_flight_delays
    GROUP BY srk_carrier
    ORDER BY SUM(arr_flights) DESC
    LIMIT 10
),
top_airports AS (
    SELECT srk_airport
    FROM dw.fact_flight_delays
    GROUP BY srk_airport
    ORDER BY SUM(arr_flights) DESC
    LIMIT 10
)
SELECT
    c.carrier_code,
    c.carrier_name,
    a.airport_code,
    a.airport_name,
    SUM(f.arr_flights) AS total_voos,
    ROUND(AVG(f.delay_rate), 2) AS taxa_atraso_pct,
    ROUND(AVG(f.avg_delay_minutes), 2) AS atraso_medio_minutos,
    ROUND(AVG(f.on_time_rate), 2) AS taxa_pontualidade_pct
FROM dw.fact_flight_delays f
JOIN dw.dim_carrier c ON f.srk_carrier = c.srk_carrier
JOIN dw.dim_airport a ON f.srk_airport = a.srk_airport
WHERE f.srk_carrier IN (SELECT srk_carrier FROM top_carriers)
  AND f.srk_airport IN (SELECT srk_airport FROM top_airports)
GROUP BY c.carrier_code, c.carrier_name, a.airport_code, a.airport_name
ORDER BY c.carrier_name, a.airport_name;

-- ============================================================================
-- 10. COMPARAÇÃO PANDEMIA (PRÉ/DURANTE/PÓS COVID-19)
-- ============================================================================
-- Objetivo: Medir impacto da COVID-19 na operação (análise comparativa)
WITH pandemic_periods AS (
    SELECT
        CASE 
            WHEN t.year < 2020 THEN 'Pré-Pandemia (2013-2019)'
            WHEN t.year = 2020 THEN 'Durante Pandemia (2020)'
            ELSE 'Pós-Pandemia (2021-2023)'
        END AS periodo,
        SUM(f.arr_flights) AS total_voos,
        ROUND(AVG(f.delay_rate), 2) AS taxa_atraso_media,
        ROUND(AVG(f.on_time_rate), 2) AS taxa_pontualidade_media,
        ROUND(AVG(f.avg_delay_minutes), 2) AS atraso_medio_minutos,
        SUM(f.arr_cancelled) AS total_cancelamentos,
        ROUND(AVG(f.cancellation_rate), 2) AS taxa_cancelamento_media
    FROM dw.fact_flight_delays f
    JOIN dw.dim_time t ON f.srk_time = t.srk_time
    GROUP BY 
        CASE 
            WHEN t.year < 2020 THEN 'Pré-Pandemia (2013-2019)'
            WHEN t.year = 2020 THEN 'Durante Pandemia (2020)'
            ELSE 'Pós-Pandemia (2021-2023)'
        END
)
SELECT *
FROM pandemic_periods
ORDER BY 
    CASE 
        WHEN periodo = 'Pré-Pandemia (2013-2019)' THEN 1
        WHEN periodo = 'Durante Pandemia (2020)' THEN 2
        ELSE 3
    END;

-- ============================================================================
-- FIM DAS CONSULTAS ANALÍTICAS
-- ============================================================================
