-- ============================================================
-- Project: What Drives Purchasing Behaviour in E-Commerce
-- Dataset: Kaggle Superstore (9,994 rows)
-- Database: shopify_project
-- Author: Amrutha K 
-- ============================================================


-- ============================================================
-- Q1: Which Customer Segment Drives the Most Revenue?
-- ============================================================
SELECT Segment, 
       SUM(Sales) AS TotalRevenue, 
       SUM(Profit) AS TotalProfit,
       ROUND(SUM(Profit)/SUM(Sales)*100, 2) AS ProfitMarginPct,
       COUNT(OrderID) AS TotalOrders
FROM superstore
GROUP BY Segment
ORDER BY TotalRevenue DESC;


-- ============================================================
-- Q2: Which Region Performs Best and Worst?
-- ============================================================
SELECT Region, 
       SUM(Sales) AS TotalRevenue, 
       SUM(Profit) AS TotalProfit,
       ROUND(SUM(Profit)/SUM(Sales)*100, 2) AS ProfitMarginPct,
       COUNT(OrderID) AS TotalOrders
FROM superstore
GROUP BY Region
ORDER BY TotalRevenue DESC;


-- ============================================================
-- Q3: Which Product Category Is Most Profitable?
-- ============================================================
SELECT Category, 
       SUM(Sales) AS TotalRevenue, 
       SUM(Profit) AS TotalProfit,
       ROUND(SUM(Profit)/SUM(Sales)*100, 2) AS ProfitMarginPct,
       COUNT(OrderID) AS TotalOrders
FROM superstore
GROUP BY Category
ORDER BY TotalProfit DESC;

-- Drill-down: Furniture sub-category profitability
SELECT SubCategory, 
       SUM(Sales) AS TotalRevenue, 
       SUM(Profit) AS TotalProfit,
       ROUND(SUM(Profit)/SUM(Sales)*100, 2) AS ProfitMarginPct,
       ROUND(AVG(Discount)*100, 2) AS AvgDiscountPct
FROM superstore
WHERE Category = 'Furniture'
GROUP BY SubCategory
ORDER BY TotalProfit ASC;


-- ============================================================
-- Q4: Do Discounts Increase Sales or Kill Profit?
-- ============================================================
SELECT 
    CASE 
        WHEN Discount = 0 THEN 'No Discount'
        WHEN Discount <= 0.2 THEN 'Low Discount (1-20%)'
        WHEN Discount <= 0.4 THEN 'Medium Discount (21-40%)'
        ELSE 'High Discount (40%+)'
    END AS DiscountBand,
    SUM(Sales) AS TotalRevenue,
    SUM(Profit) AS TotalProfit,
    ROUND(SUM(Profit)/SUM(Sales)*100, 2) AS ProfitMarginPct,
    COUNT(OrderID) AS TotalOrders
FROM superstore
GROUP BY DiscountBand
ORDER BY ProfitMarginPct DESC;


-- ============================================================
-- Q5: Who Are Our Top Customers? (Revenue vs Profit)
-- ============================================================
SELECT CustomerName, 
       SUM(Sales) AS TotalRevenue, 
       SUM(Profit) AS TotalProfit,
       COUNT(OrderID) AS TotalOrders
FROM superstore
GROUP BY CustomerName
ORDER BY TotalRevenue DESC
LIMIT 10;

-- Drill-down: Investigating Sean Miller (highest revenue, unprofitable)
SELECT OrderID, Sales, Discount, Profit, Category, SubCategory
FROM superstore
WHERE CustomerName = 'Sean Miller'
ORDER BY Profit ASC;

-- RFM Segmentation
SELECT 
    CustomerName,
    Recency,
    Frequency,
    Monetary,
    CASE 
        WHEN Recency <= 90 AND Frequency >= 15 THEN 'Champions'
        WHEN Recency <= 90 AND Frequency < 15 THEN 'Loyal'
        WHEN Recency BETWEEN 91 AND 200 THEN 'At Risk'
        WHEN Recency > 200 THEN 'Lost'
        ELSE 'Others'
    END AS CustomerSegment
FROM (
    SELECT 
        CustomerName,
        DATEDIFF('2017-12-30', MAX(OrderDate)) AS Recency,
        COUNT(OrderID) AS Frequency,
        ROUND(SUM(Sales), 2) AS Monetary
    FROM superstore
    GROUP BY CustomerName
) AS CustomerRFM
ORDER BY Monetary DESC;

-- RFM Segment Summary
SELECT 
    CustomerSegment,
    COUNT(CustomerName) AS NumberOfCustomers,
    ROUND(SUM(Monetary), 2) AS TotalRevenue,
    ROUND(AVG(Monetary), 2) AS AvgRevenuePerCustomer
FROM (
    SELECT 
        CustomerName,
        Recency,
        Frequency,
        Monetary,
        CASE 
            WHEN Recency <= 90 AND Frequency >= 15 THEN 'Champions'
            WHEN Recency <= 90 AND Frequency < 15 THEN 'Loyal'
            WHEN Recency BETWEEN 91 AND 200 THEN 'At Risk'
            WHEN Recency > 200 THEN 'Lost'
            ELSE 'Others'
        END AS CustomerSegment
    FROM (
        SELECT 
            CustomerName,
            DATEDIFF('2017-12-30', MAX(OrderDate)) AS Recency,
            COUNT(OrderID) AS Frequency,
            ROUND(SUM(Sales), 2) AS Monetary
        FROM superstore
        GROUP BY CustomerName
    ) AS CustomerRFM
) AS SegmentedCustomers
GROUP BY CustomerSegment
ORDER BY TotalRevenue DESC;


-- ============================================================
-- Q6: Which Sub-Categories Are Losing Money?
-- ============================================================
SELECT Category, SubCategory,
       SUM(Sales) AS TotalRevenue,
       SUM(Profit) AS TotalProfit,
       ROUND(SUM(Profit)/SUM(Sales)*100, 2) AS ProfitMarginPct
FROM superstore
GROUP BY Category, SubCategory
ORDER BY TotalProfit ASC
LIMIT 10;


-- ============================================================
-- Q7: What Are the Seasonality Trends?
-- ============================================================
SELECT OrderMonth, 
       SUM(Sales) AS TotalRevenue,
       SUM(Profit) AS TotalProfit,
       COUNT(OrderID) AS TotalOrders
FROM superstore
GROUP BY OrderMonth
ORDER BY TotalRevenue DESC;
