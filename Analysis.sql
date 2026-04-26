USE Final_Project

Select * From Customers
Select * From Locations
Select * From Orders
Select * From Products
Select * From Order_Details

ALTER TABLE Orders
ADD CONSTRAINT FK_Orders_Customers
FOREIGN KEY (Customer_ID)
REFERENCES Customers(Customer_ID)

ALTER TABLE Orders
ADD CONSTRAINT FK_Orders_Locations
FOREIGN KEY (location_location_id)
REFERENCES Locations(location_id)

ALTER TABLE Order_Details
ADD CONSTRAINT FK_OrderDetails_Products
FOREIGN KEY (Products_Product_ID)
REFERENCES Products(Product_ID)

ALTER TABLE Order_Details
ADD CONSTRAINT FK_OrderDetails_Orders
FOREIGN KEY (Order_ID)
REFERENCES Orders(Order_ID)

SELECT *
FROM Order_Details od
LEFT JOIN Products p
ON od.products_product_id = p.Product_ID
WHERE p.Product_ID IS NULL

--Customers Analysis--

--Total Number of Customers
SELECT COUNT(DISTINCT Customer_ID) AS Total_Customers
FROM Customers


--Total Sales
SELECT SUM(total_sales) AS Total_Sales
FROM Order_Details

-- Top 10 Customers by Sales
SELECT TOP 10
c.Customer_ID,c.Customer_Name,SUM(od.total_sales) AS Total_Sales
FROM Customers c
JOIN Orders o
ON c.Customer_ID = o.Customer_ID
JOIN Order_Details od
ON o.Order_ID = od.Order_ID
GROUP BY c.Customer_ID, c.Customer_Name
ORDER BY Total_Sales DESC

--Top 10 Customers by Profit
SELECT TOP 10
c.Customer_ID,c.Customer_Name,
SUM(od.total_profit) AS Total_Profit
FROM Customers c
JOIN Orders o
ON c.Customer_ID = o.Customer_ID
JOIN Order_Details od 
ON o.Order_ID = od.Order_ID
GROUP BY c.Customer_ID, c.Customer_Name
ORDER BY Total_Profit DESC

-- Most Frequent Customers
SELECT TOP 10
c.Customer_ID,
c.Customer_Name,
COUNT(o.Order_ID) AS Orders_Count
FROM Customers c
JOIN Orders o
ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name
ORDER BY Orders_Count DESC


-- Customers Buying a Lot but Losing Money
SELECT c.Customer_ID,c.Customer_Name,
COUNT(DISTINCT (o.Order_ID)) AS Orders_Count,
SUM(od.total_sales) AS Total_Sales,
SUM(od.total_profit) AS Total_Profit
FROM Customers c
JOIN Orders o
ON c.Customer_ID = o.Customer_ID
JOIN Order_Details od
ON o.Order_ID = od.Order_ID
GROUP BY c.Customer_ID, c.Customer_Name
HAVING COUNT(DISTINCT o.Order_ID) > 10
AND SUM(od.total_profit) < 0
ORDER BY Orders_Count DESC, Total_Profit ASC

--  Segment Performance by Sales, Profit
SELECT c.Segment,
SUM(od.total_sales) AS Total_Sales,
SUM(od.total_profit) AS Total_Profit
FROM Customers c
JOIN Orders o
ON c.Customer_ID = o.Customer_ID
JOIN Order_Details od
ON o.Order_ID = od.Order_ID
GROUP BY c.Segment
ORDER BY Total_Sales DESC


--------------------------------------------------
--Product Analysis


-- Total Number of Products
SELECT COUNT(DISTINCT Product_ID) AS Total_Products
FROM Products


-- Top 10 Products by Total Sales
SELECT TOP 10
p.Product_ID,
p.Product_Name,
SUM(od.total_sales) AS Total_Sales
FROM Products p
JOIN Order_Details od
ON p.Product_ID = od.products_product_id
GROUP BY p.Product_ID, p.Product_Name
ORDER BY Total_Sales DESC


-- Top 10 Products by Total Profit
SELECT TOP 10
p.Product_ID,
p.Product_Name,
SUM(od.total_profit) AS Total_Profit
FROM Products p
JOIN Order_Details od
ON p.Product_ID = od.products_product_id
GROUP BY p.Product_ID, p.Product_Name
ORDER BY Total_Profit DESC


-- Top 10 Most Sold Products by Quantity
SELECT TOP 10
p.Product_ID,
p.Product_Name,
SUM(od.total_quantity) AS Total_Qty
FROM Products p
JOIN Order_Details od
ON p.Product_ID = od.products_product_id
GROUP BY p.Product_ID, p.Product_Name
ORDER BY Total_Qty DESC



-- Products Generating Loss
SELECT p.Product_ID,p.Product_Name,
SUM(od.total_sales) AS Total_Sales,
SUM(od.total_profit) AS Total_Profit
FROM Products p
JOIN Order_Details od
ON p.Product_ID = od.products_product_id
GROUP BY p.Product_ID, p.Product_Name
HAVING SUM(od.total_profit) < 0
ORDER BY Total_Profit ASC

--Products with High Sales but Negative Profit
SELECT p.Product_ID,p.Product_Name,
SUM(od.Total_Sales) AS Total_Sales,
SUM(od.Total_Profit) AS Total_Profit
FROM Products p
JOIN Order_Details od
ON p.Product_ID = od.products_product_id
GROUP BY p.Product_ID, p.Product_Name
HAVING SUM(od.Total_Profit) < 0
ORDER BY SUM(od.Total_Sales) DESC


-- Category Performance by Sales and Profit
SELECT p.Category,
SUM(od.total_sales) AS Total_Sales,
SUM(od.total_profit) AS Total_Profit,
SUM(od.margin) AS Profit_Margin
FROM Products p
JOIN Order_Details od
ON p.Product_ID = od.products_product_id
GROUP BY p.Category
ORDER BY Total_Profit DESC


--Sub_Categories by Sales and profit
SELECT 
p.Sub_Category,p.category,
SUM(od.total_sales) AS Total_Sales,
SUM(od.total_profit) AS Total_Profit
FROM Products p
JOIN Order_Details od
ON p.Product_ID = od.products_product_id
GROUP BY p.Sub_Category,p.category
ORDER BY Total_Sales DESC


------------------------------------------
-- Orders Analysis

-- Total Number of Orders
SELECT COUNT(DISTINCT Order_ID) AS Total_Orders
FROM Orders


--  Average Sales per Order
SELECT
AVG(Order_Sales) AS AOV
FROM (
    SELECT
    o.Order_ID,
    SUM(od.total_sales) AS Order_Sales
    FROM Orders o
    JOIN Order_Details od
    ON o.Order_ID = od.Order_ID
    GROUP BY o.Order_ID
) t
------
SELECT AVG(Order_Sales) AS AOV
FROM (
    SELECT SUM(total_sales) AS Order_Sales
    FROM Order_Details
    GROUP BY Order_ID
) t



--Top 10 Sales Orders
SELECT TOP 10 Order_ID,
SUM(Total_Sales) AS Total_Sales
FROM Order_Details
GROUP BY Order_ID
ORDER BY Total_Sales DESC

--Min Sales Order
SELECT TOP 10 Order_ID,
SUM(Total_Sales) AS Total_Sales
FROM Order_Details
GROUP BY Order_ID
ORDER BY Total_Sales ASC

-- Number of Loss-Making Orders

SELECT COUNT(*) AS Loss_Making_Orders
FROM (
    SELECT 
    Order_ID,
    SUM(Total_Profit) AS Order_Profit
    FROM Order_Details
    GROUP BY Order_ID
    HAVING SUM(Total_Profit) < 0
) t

-- Orders with Biggest Loss
SELECT TOP 10 o.Order_ID,
SUM(od.total_sales) AS Order_Sales,
SUM(od.total_profit) AS Order_Profit
FROM Orders o
JOIN Order_Details od
ON o.Order_ID = od.Order_ID
GROUP BY o.Order_ID
HAVING SUM(od.total_profit) < 0
ORDER BY Order_Profit ASC


-- Ship Mode Performance
SELECT  o.Ship_Mode,
AVG(DATEDIFF(DAY, o.Order_Date, o.Ship_Date)) AS Avg_Ship_Days,
SUM(od.total_profit) AS Total_Profit
FROM Orders o
JOIN Order_Details od
ON o.Order_ID = od.Order_ID
GROUP BY o.Ship_Mode
ORDER BY Avg_Ship_Days


---------------------------------------------------
-- Location Analysis


-- Highest Region by Sales and Profit
SELECT l.Region,
SUM(od.total_sales) AS Total_Sales,
SUM(od.total_profit) AS Total_Profit
FROM Locations l
JOIN Orders o 
ON l.Location_ID = o.location_location_id
JOIN Order_Details od 
ON o.Order_ID = od.Order_ID
GROUP BY l.Region
ORDER BY Total_Profit DESC


--Top 10 Cities by sales and profit
SELECT Top 10 l.City,
SUM(od.total_sales) AS Total_Sales,
SUM(od.total_profit) AS Total_Profit
FROM Orders o
JOIN Order_Details od
ON o.Order_ID = od.Order_ID
JOIN Locations l
ON o.location_location_id = l.Location_ID
GROUP BY l.City
ORDER BY Total_Sales DESC

-- Products profitability across regions
SELECT p.Product_Name,

SUM(CASE WHEN l.Region = 'East' THEN od.total_sales ELSE 0 END) AS East_Sales,
SUM(CASE WHEN l.Region = 'West' THEN od.total_sales ELSE 0 END) AS West_Sales,
SUM(CASE WHEN l.Region = 'South' THEN od.total_sales ELSE 0 END) AS South_Sales,
SUM(CASE WHEN l.Region = 'Central' THEN od.total_sales ELSE 0 END) AS Central_Sales,

SUM(od.total_profit) AS Total_Profit
FROM Products p
JOIN Order_Details od 
ON p.Product_ID = od.products_product_id
JOIN Orders o 
ON od.Order_ID = o.Order_ID
JOIN Locations l 
ON o.location_location_id = l.Location_ID

GROUP BY p.Product_Name
ORDER BY Total_Profit DESC


-------------------------------------------
-- Discount Analysis

-- Checking the impact of discount on sales and profit.
SELECT
od.total_discount,
SUM(od.total_sales) AS Total_Sales,
SUM(od.total_profit) AS Total_Profit,
AVG(od.total_profit) AS Avg_Profit
FROM Order_Details od
GROUP BY od.total_discount
ORDER BY od.total_discount


-- First Discount Level Where Average Profit Becomes Negative
SELECT TOP 1
od.total_discount,
AVG(od.total_profit) AS Avg_Profit
FROM Order_Details od
GROUP BY od.total_discount
HAVING AVG(od.total_profit) < 0
ORDER BY od.total_discount ASC
----------------------------------------
--Sales Trend Analysis:

--The trend of sales over time (monthly/year)
SELECT 
YEAR(o.Order_Date) AS Year,
DATENAME(MONTH, o.Order_Date) AS Month_Name,
MONTH(o.Order_Date) AS Month_Number,
SUM(od.total_sales) AS Total_Sales,
SUM(od.total_profit) AS Total_profit
FROM Orders o
JOIN Order_Details od
ON o.Order_ID = od.Order_ID
GROUP BY YEAR(o.Order_Date), MONTH(o.Order_Date), DATENAME(MONTH, o.Order_Date)
ORDER BY Year, Month_Number

--Best year in sales
SELECT TOP 1
YEAR(o.Order_Date) AS Year,
SUM(od.total_sales) AS Total_Sales
FROM Orders o
JOIN Order_Details od
ON o.Order_ID = od.Order_ID
GROUP BY YEAR(o.Order_Date)
ORDER BY Total_Sales DESC



























