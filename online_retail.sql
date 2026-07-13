use ecommerce_project;

-- Retail Customer Insights Project

-- 1. Top countries by revenue
SELECT Country,
       ROUND(SUM(Quantity * UnitPrice), 2) AS total_revenue
FROM online_retail_full
GROUP BY Country
ORDER BY total_revenue DESC
LIMIT 10;


-- 2. Top products by quantity sold
SELECT Description,
       SUM(Quantity) AS total_quantity
FROM online_retail_full
GROUP BY Description
ORDER BY total_quantity DESC
LIMIT 10;


-- 3. Top products by revenue
SELECT Description,
       ROUND(SUM(Quantity*UnitPrice), 2) AS total_revenue
FROM online_retail_full
GROUP BY Description
ORDER BY total_revenue DESC
LIMIT 10;


-- 4. Average order value
SELECT ROUND(
           SUM(Quantity*UnitPrice) / COUNT(DISTINCT InvoiceNo),
           2
       ) AS average_order_value
FROM online_retail_full
WHERE Quantity >0
AND UnitPrice >0;


-- 5. Monthly revenue trend
SELECT
    DATE_FORMAT(InvoiceDate, '%Y-%m') AS sales_month,
    ROUND(SUM(Quantity * UnitPrice), 2) AS monthly_revenue
FROM online_retail_full
WHERE Quantity > 0
  AND UnitPrice > 0
GROUP BY DATE_FORMAT(InvoiceDate, '%Y-%m')
ORDER BY sales_month;




-- 6. Customer Revenue Ranking using Window Function
WITH customer_revenue AS (
    SELECT CustomerID,
           ROUND(SUM(Quantity * UnitPrice), 2) AS Total_Revenue
    FROM online_retail_full
    WHERE CustomerID IS NOT NULL
      AND CustomerID <> ''
    GROUP BY CustomerID
)

SELECT CustomerID,
       Total_Revenue,
       RANK() OVER (
           ORDER BY Total_Revenue DESC
       ) AS Revenue_Rank
FROM customer_revenue
ORDER BY Revenue_Rank
LIMIT 10;


-- 7.Customer Order Ranking using DENSE_RANK() Window Function
WITH Customer_orders AS (
    SELECT CustomerID,
           COUNT(DISTINCT InvoiceNo) AS Total_Orders
    FROM online_retail_full
    WHERE CustomerID IS NOT NULL
      AND CustomerID <> ''
    GROUP BY CustomerID
)

SELECT CustomerID,
       Total_Orders,
       DENSE_RANK() OVER (
           ORDER BY Total_Orders DESC
       ) AS Order_Rank
FROM Customer_orders
ORDER BY Order_Rank
LIMIT 10;


-- 8. Top Customer in Each Country using ROW_NUMBER()
WITH customer_country_revenue AS (
    SELECT Country,
           CustomerID,
           ROUND(SUM(Quantity * UnitPrice), 2) AS Total_Revenue
    FROM online_retail_full
    WHERE CustomerID IS NOT NULL
      AND CustomerID <> ''
    GROUP BY Country, CustomerID
),

ranked_customers AS (
    SELECT Country,
           CustomerID,
           Total_Revenue,
           ROW_NUMBER() OVER (
               PARTITION BY Country
               ORDER BY Total_Revenue DESC
           ) AS Customer_Rank
    FROM customer_country_revenue
)

SELECT Country,
       CustomerID,
       Total_Revenue
FROM ranked_customers
WHERE Customer_Rank = 1
ORDER BY Total_Revenue DESC;


-- 9. Running Total of Monthly Revenue using SUM() OVER()
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(InvoiceDate, '%Y-%m') AS Sales_Month,
        ROUND(SUM(Quantity * UnitPrice), 2) AS Monthly_Revenue
    FROM online_retail_full
    WHERE Quantity > 0
      AND UnitPrice > 0
    GROUP BY DATE_FORMAT(InvoiceDate, '%Y-%m')
)

SELECT
    Sales_Month,
    Monthly_Revenue,
    ROUND(
        SUM(Monthly_Revenue) OVER (
            ORDER BY Sales_Month
        ),
        2
    ) AS Running_Total_Revenue
FROM monthly_revenue
ORDER BY Sales_Month;


-- 10. Customer Contribution to Total Revenue
WITH customer_revenue AS (
    SELECT CustomerID,
        ROUND(SUM(Quantity * UnitPrice), 2) AS Total_Revenue
    FROM online_retail_full
    WHERE CustomerID IS NOT NULL
    AND CustomerID <>0
    GROUP BY CustomerID
)

SELECT CustomerID,
    Total_Revenue,
    ROUND(Total_Revenue * 100 /SUM(Total_Revenue) OVER (),2) AS Revenue_Percentage
FROM customer_revenue
ORDER BY Total_Revenue DESC
LIMIT 10;
