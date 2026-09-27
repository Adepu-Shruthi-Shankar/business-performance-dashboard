-- ============================================================
-- Business Performance Dashboard - MySQL Setup Script
-- ============================================================

CREATE DATABASE IF NOT EXISTS business_performance;
USE business_performance;

DROP TABLE IF EXISTS sales_operations;

CREATE TABLE sales_operations (
    order_id        VARCHAR(20)     PRIMARY KEY,
    order_date      DATE            NOT NULL,
    region          VARCHAR(50)     NOT NULL,
    country         VARCHAR(50)     NOT NULL,
    product_line    VARCHAR(50)     NOT NULL,
    product         VARCHAR(100)    NOT NULL,
    sales_rep       VARCHAR(20)     NOT NULL,
    customer_segment VARCHAR(20)    NOT NULL,
    sales_channel   VARCHAR(30)     NOT NULL,
    units_sold      INT             NOT NULL,
    unit_price      DECIMAL(10,2)   NOT NULL,
    discount_pct    DECIMAL(5,2)    NOT NULL,
    revenue         DECIMAL(12,2)   NOT NULL,
    cost            DECIMAL(12,2)   NOT NULL,
    profit          DECIMAL(12,2)   NOT NULL,
    order_status    VARCHAR(20)     NOT NULL,
    delivery_days   INT             NULL,

    INDEX idx_order_date (order_date),
    INDEX idx_region (region),
    INDEX idx_product_line (product_line)
);

-- ============================================================
-- Load the CSV (adjust path to wherever you saved the file)
-- Run this from the MySQL CLI, or use the Table Data Import
-- Wizard in MySQL Workbench if local_infile is disabled.
-- ============================================================

-- On the server / CLI, enable local file loading first if needed:
-- SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE '/absolute/path/to/sales_operations_data.csv'
INTO TABLE sales_operations
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_id, order_date, region, country, product_line, product, sales_rep,
 customer_segment, sales_channel, units_sold, unit_price, discount_pct,
 revenue, cost, profit, order_status, @delivery_days)
SET delivery_days = NULLIF(@delivery_days, '');

-- Sanity checks
SELECT COUNT(*) AS total_rows FROM sales_operations;
SELECT region, COUNT(*) AS orders, SUM(revenue) AS total_revenue
FROM sales_operations
GROUP BY region
ORDER BY total_revenue DESC;
