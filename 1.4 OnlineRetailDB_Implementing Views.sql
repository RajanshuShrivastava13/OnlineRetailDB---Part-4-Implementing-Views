-- ==================================================================================
-- PROJECT: OnlineRetailDB - Part 4: Implementing Views & Complex Analysis
-- AUTHOR: Rajanshu Shrivastava
-- DESCRIPTION: Creation of virtual layers (Views) for data security, abstraction,
--              and solving analytical queries (Query 31 to 44).
-- ==================================================================================

-- [CLEANUP] Drop older versions for fresh batch execution
DROP VIEW IF EXISTS vw_RecentOrders;
DROP VIEW IF EXISTS vw_CustomerOrders;
DROP VIEW IF EXISTS vw_ProductDetails;
DROP TABLE IF EXISTS OrderItems;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Categories;
DROP TABLE IF EXISTS Customers;
GO

-- ==================================================================================
-- SECTION 1: BASE SCHEMA & MOCK DATA (For Analysis Context)
-- ==================================================================================
CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL
);

CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    CategoryID INT NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    Stock INT NOT NULL,
    CONSTRAINT FK_Prod_Cat FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL
);

CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate DATETIME NOT NULL,
    TotalAmount DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_Ord_Cust FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

CREATE TABLE OrderItems (
    OrderItemID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_Items_Ord FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    CONSTRAINT FK_Items_Prod FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- SEEDING DATA (Rich dataset to fulfill all 14 query conditions)
INSERT INTO Categories VALUES ('Electronics'), ('Apparel'), ('Home Decor');
INSERT INTO Products VALUES 
('Laptop', 1, 45000.00, 15), ('Smartphone', 1, 15000.00, 8), ('Headphones', 1, 2500.00, 5),
('T-Shirt', 2, 800.00, 50), ('Jeans', 2, 1800.00, 3), ('Wall Clock', 3, 1200.00, 12);

INSERT INTO Customers VALUES 
('Rajanshu', 'Shrivastava', 'rajanshu@example.com'),
('Amit', 'Sharma', 'amit@example.com'),
('Vijay', 'Verma', 'vijay@example.com');

-- Simulating normal and past 30 days timeframes for vw_RecentOrders
INSERT INTO Orders VALUES 
(1, GETDATE(), 47500.00),     -- Recent Order (Rajanshu)
(1, GETDATE() - 2, 800.00),   -- Recent Order (Rajanshu)
(1, GETDATE() - 5, 15000.00), -- Recent Order (Rajanshu)
(1, GETDATE() - 10, 2500.00), -- Recent Order (Rajanshu)
(1, GETDATE() - 12, 1800.00), -- Recent Order (Rajanshu)
(1, GETDATE() - 15, 1200.00), -- Recent Order (Rajanshu: total 6 orders)
(2, GETDATE() - 3, 16800.00), -- Recent Order (Amit)
(2, GETDATE() - 40, 5000.00), -- Older than 30 Days Order (Amit)
(3, GETDATE() - 1, 800.00);    -- Recent Order (Vijay)

INSERT INTO OrderItems VALUES 
(1, 1, 1, 45000.00), (1, 3, 1, 2500.00),
(2, 4, 1, 800.00), (3, 2, 1, 15000.00), (4, 3, 1, 2500.00), (5, 5, 1, 1800.00), (6, 6, 1, 1200.00),
(7, 2, 1, 15000.00), (7, 5, 1, 1800.00), (8, 1, 1, 45000.00), (9, 4, 1, 800.00);

-- ==================================================================================
-- SECTION 2: VIEWS CREATION VIA DYNAMIC SQL (Bypassing OneCompiler Batch Error)
-- ==================================================================================

-- 1. View for Product Details: Combines product details with category names
EXEC('CREATE VIEW vw_ProductDetails AS 
      SELECT p.ProductID, p.ProductName, p.Price, p.Stock, c.CategoryID, c.CategoryName 
      FROM Products p 
      INNER JOIN Categories c ON p.CategoryID = c.CategoryID;');

-- 2. View for Customer Orders: Summary of orders placed by each customer
EXEC('CREATE VIEW vw_CustomerOrders AS 
      SELECT c.CustomerID, c.FirstName, c.LastName, c.Email, 
             COUNT(o.OrderID) AS TotalOrders, SUM(o.TotalAmount) AS TotalSpent
      FROM Customers c
      LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
      GROUP BY c.CustomerID, c.FirstName, c.LastName, c.Email;');

-- 3. View for Recent Orders: Display orders placed in the last 30 days
EXEC('CREATE VIEW vw_RecentOrders AS 
      SELECT o.OrderID, o.CustomerID, o.OrderDate, o.TotalAmount,
             oi.ProductID, oi.Quantity, oi.UnitPrice
      FROM Orders o
      INNER JOIN OrderItems oi ON o.OrderID = oi.OrderID
      WHERE o.OrderDate >= DATEADD(day, -30, GETDATE());');

-- ==================================================================================
-- SECTION 3: EXECUTING IMAGED QUERIES (31 TO 44)
-- ==================================================================================

PRINT '--- Query 31: Retrieve All Products with Category Names ---';
SELECT ProductName, CategoryName FROM vw_ProductDetails;

PRINT '--- Query 32: Retrieve Products within a Specific Price Range ($100 to $500 / INR equivalent) ---';
SELECT ProductName, Price FROM vw_ProductDetails WHERE Price BETWEEN 1000 AND 20000;

PRINT '--- Query 33: Count the Number of Products in Each Category ---';
SELECT CategoryName, COUNT(ProductID) AS ProductCount FROM vw_ProductDetails GROUP BY CategoryName;

PRINT '--- Query 34: Retrieve Customers with More Than 5 Orders ---';
SELECT FirstName, LastName, TotalOrders FROM vw_CustomerOrders WHERE TotalOrders > 5;

PRINT '--- Query 35: Retrieve the Total Amount Spent by Each Customer ---';
SELECT FirstName, LastName, TotalSpent FROM vw_CustomerOrders;

PRINT '--- Query 36: Retrieve Recent Orders Above a Certain Amount ($1000 threshold) ---';
SELECT DISTINCT OrderID, TotalAmount, OrderDate FROM vw_RecentOrders WHERE TotalAmount > 10000;

PRINT '--- Query 37: Retrieve the Latest Order for Each Customer ---';
-- Evaluated dynamically using base context over structural views
SELECT CustomerID, MAX(OrderDate) AS LatestOrderDate FROM vw_RecentOrders GROUP BY CustomerID;

PRINT '--- Query 38: Retrieve Products in a Specific Category (e.g., Electronics) ---';
SELECT ProductName, Price FROM vw_ProductDetails WHERE CategoryName = 'Electronics';

PRINT '--- Query 39: Retrieve Total Sales for Each Category ---';
SELECT pd.CategoryName, SUM(ro.Quantity * ro.UnitPrice) AS TotalSales
FROM vw_RecentOrders ro
INNER JOIN vw_ProductDetails pd ON ro.ProductID = pd.ProductID
GROUP BY pd.CategoryName;

PRINT '--- Query 40: Retrieve Customer Orders with Product Details ---';
SELECT co.FirstName, co.LastName, pd.ProductName, ro.Quantity, ro.UnitPrice
FROM vw_RecentOrders ro
INNER JOIN vw_CustomerOrders co ON ro.CustomerID = co.CustomerID
INNER JOIN vw_ProductDetails pd ON ro.ProductID = pd.ProductID;

PRINT '--- Query 41: Retrieve Top 5 Customers by Total Spending ---';
SELECT TOP 5 FirstName, LastName, TotalSpent FROM vw_CustomerOrders ORDER BY TotalSpent DESC;

PRINT '--- Query 42: Retrieve Products with Low Stock (Below 10 units) ---';
SELECT ProductName, Stock FROM vw_ProductDetails WHERE Stock < 10;

PRINT '--- Query 43: Retrieve Orders Placed in the Last 7 Days ---';
SELECT DISTINCT OrderID, OrderDate, TotalAmount FROM vw_RecentOrders WHERE OrderDate >= DATEADD(day, -7, GETDATE());

PRINT '--- Query 44: Retrieve Products Sold in the Last Month ---';
SELECT DISTINCT pd.ProductName FROM vw_RecentOrders ro
INNER JOIN vw_ProductDetails pd ON ro.ProductID = pd.ProductID;