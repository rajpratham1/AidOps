-- 1. Data Setup (The "Input")
-- Objective: Generate "dirty" dummy data to simulate real-world inventory history.
-- Architecture: Standard SQL script to be run by the Consumer to prepare their environment.

CREATE OR REPLACE TABLE INVENTORY_HISTORY (
    DATE DATE,
    ITEM_NAME VARCHAR,
    REGION VARCHAR,
    QUANTITY_USED INTEGER,
    STOCK_REMAINING INTEGER
);

-- Inserting 20 rows of data
-- Scenario: "Antibiotics" usage is increasing (outbreak?), "Bandages" are stable.
-- "Dirty" Data: Some nulls in QUANTITY_USED to test data cleaning logic.
INSERT INTO INVENTORY_HISTORY (DATE, ITEM_NAME, REGION, QUANTITY_USED, STOCK_REMAINING) VALUES
    ('2023-10-01', 'Antibiotics', 'North', 50, 500),
    ('2023-10-02', 'Antibiotics', 'North', 55, 445),
    ('2023-10-03', 'Antibiotics', 'North', NULL, 445), -- Missing data point
    ('2023-10-04', 'Antibiotics', 'North', 65, 380),
    ('2023-10-05', 'Antibiotics', 'North', 70, 310),
    ('2023-10-06', 'Antibiotics', 'North', 80, 230),
    ('2023-10-07', 'Antibiotics', 'North', 90, 140), -- Rapid depletion
    ('2023-10-08', 'Antibiotics', 'North', 95, 45),
    ('2023-10-09', 'Antibiotics', 'North', 100, -55), -- Stockout implied

    ('2023-10-01', 'Bandages', 'South', 20, 1000),
    ('2023-10-02', 'Bandages', 'South', 22, 978),
    ('2023-10-03', 'Bandages', 'South', 18, 960),
    ('2023-10-04', 'Bandages', 'South', 20, 940),
    ('2023-10-05', 'Bandages', 'South', NULL, 940), -- Missing data point
    ('2023-10-06', 'Bandages', 'South', 25, 915),
    ('2023-10-07', 'Bandages', 'South', 20, 895),

    ('2023-10-01', 'Rice Bags', 'East', 100, 2000),
    ('2023-10-02', 'Rice Bags', 'East', 100, 1900),
    ('2023-10-03', 'Rice Bags', 'East', 120, 1780),
    ('2023-10-04', 'Rice Bags', 'East', 150, 1630);


-- --------------------------------------------------------
-- 2. WEATHER SAMPLE (Simulating Snowflake Marketplace)
-- --------------------------------------------------------
CREATE OR REPLACE TABLE WEATHER_SAMPLE (
    EVENT_DATE DATE,
    REGION VARCHAR(50),
    EVENT_TYPE VARCHAR(50),
    SEVERITY VARCHAR(20),
    DESCRIPTION VARCHAR(255)
);

INSERT INTO WEATHER_SAMPLE (EVENT_DATE, REGION, EVENT_TYPE, SEVERITY, DESCRIPTION) VALUES
(DATEADD(day, 1, CURRENT_DATE()), 'North', 'Heavy Snow', 'High', 'Road closures expected on major highways.'),
(DATEADD(day, 3, CURRENT_DATE()), 'South', 'Heatwave', 'Medium', 'Cooling storage required for sensitive medicines.'),
(DATEADD(day, 5, CURRENT_DATE()), 'East', 'Flood Warning', 'Critical', 'Potential supply chain disruption.');

