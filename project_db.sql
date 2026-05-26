CREATE DATABASE project_db;
use project_db;
USE project_db;

-- Now this works ✅
SELECT SUM(sales) AS total_sales FROM orders;
SELECT SUM(profit) AS total_profit FROM orders;

-- Revenue by region
SELECT region,
       ROUND(SUM(sales), 2)  AS total_sales,
       ROUND(SUM(profit), 2) AS total_profit
FROM orders
GROUP BY region
ORDER BY total_sales DESC;

-- Top categories
SELECT category,
       ROUND(SUM(sales), 2) AS sales
FROM orders
GROUP BY category
ORDER BY sales DESC;

SELECT year,
       ROUND(SUM(sales), 2) AS total_sales,
       LAG(ROUND(SUM(sales), 2)) OVER (ORDER BY year) AS prev_year_sales,
       ROUND(SUM(sales) - LAG(SUM(sales)) OVER (ORDER BY year), 2) AS growth
FROM orders
GROUP BY year;

SELECT year,
       month,
       ROUND(SUM(sales), 2) AS monthly_sales,
       ROUND(SUM(SUM(sales)) OVER (PARTITION BY year ORDER BY month), 2) AS running_total
FROM orders
GROUP BY year, month
ORDER BY year, month;


WITH avg_profit AS (
    SELECT AVG(profit) AS avg_p FROM orders
),
sub_profit AS (
    SELECT sub_category,
           ROUND(SUM(profit), 2) AS total_profit
    FROM orders
    GROUP BY sub_category
)
SELECT s.sub_category,
       s.total_profit,
       ROUND(a.avg_p, 2) AS avg_profit
FROM sub_profit s, avg_profit a
WHERE s.total_profit > a.avg_p
ORDER BY s.total_profit DESC;

WITH monthly AS (
    SELECT year,
           month,
           ROUND(SUM(sales), 2) AS sales
    FROM orders
    GROUP BY year, month
),
growth AS (
    SELECT year,
           month,
           sales,
           LAG(sales) OVER (ORDER BY year, month) AS prev_month,
           ROUND((sales - LAG(sales) OVER (ORDER BY year, month))
                 / LAG(sales) OVER (ORDER BY year, month) * 100, 1) AS growth_pct
    FROM monthly
)
SELECT * FROM growth
WHERE prev_month IS NOT NULL
ORDER BY year, month;