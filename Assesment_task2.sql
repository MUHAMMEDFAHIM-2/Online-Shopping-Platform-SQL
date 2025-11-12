CREATE DATABASE OnlineShoppingDB;
GO
USE OnlineShoppingDB;
GO

-- Customers table
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    country VARCHAR(50)
);

-- Products table
CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2)
);

-- Orders table
CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- Order_items table
CREATE TABLE Order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    price_each DECIMAL(10,2),
    total_price DECIMAL(10,2),
    total_amount DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- Payments table
CREATE TABLE Payments (
    payment_id INT PRIMARY KEY,
    order_id INT,
    payment_date DATE,
    payment_method VARCHAR(50),
    Amount_paid DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

SELECT * FROM Customers;
SELECT * FROM Products;
SELECT * FROM Orders;
SELECT * FROM Order_items;
SELECT * FROM Payments;


SELECT DISTINCT C.name, C.country
FROM Customers C
JOIN Orders O ON C.customer_id = O.customer_id
JOIN Order_items OI ON O.order_id = OI.order_id
GROUP BY C.name, C.country, O.order_id
HAVING SUM(OI.total_amount) BETWEEN 500 AND 1000;


 

SELECT TOP 2 
    ROUND(Amount_paid * 1.122, 0) AS AmountWithVAT
FROM Payments P
JOIN Orders O ON P.order_id = O.order_id
JOIN Customers C ON O.customer_id = C.customer_id
WHERE C.country IN ('UK', 'Australia')
ORDER BY AmountWithVAT DESC;


SELECT P.product_name, SUM(OI.quantity) AS total_quantity
FROM Products P
JOIN Order_items OI ON P.product_id = OI.product_id
GROUP BY P.product_name
ORDER BY total_quantity DESC;

CREATE PROCEDURE ApplyDiscount
AS
BEGIN
    UPDATE P
    SET Amount_paid = Amount_paid * 0.95
    FROM Payments P
    JOIN Orders O ON P.order_id = O.order_id
    JOIN Order_items OI ON O.order_id = OI.order_id
    JOIN Products PR ON OI.product_id = PR.product_id
    WHERE (PR.product_name LIKE '%laptop%' OR PR.product_name LIKE '%smartphone%')
      AND P.Amount_paid >= 17000;
END;

EXEC ApplyDiscount;

-- List customers who made payments using 'Credit Card'
SELECT DISTINCT C.name, C.email, P.payment_method
FROM Customers C
JOIN Orders O ON C.customer_id = O.customer_id
JOIN Payments P ON O.order_id = P.order_id
WHERE P.payment_method = 'Credit Card';


--Get products purchased more than 50 times
SELECT P.product_name, SUM(OI.quantity) AS TotalQty
FROM Products P
JOIN Order_items OI ON P.product_id = OI.product_id
GROUP BY P.product_name
HAVING SUM(OI.quantity) > 50
ORDER BY TotalQty DESC;

--Nested Query – Customers who made an order that included 'Smartphone'
SELECT DISTINCT C.name, C.country
FROM Customers C
WHERE C.customer_id IN (
    SELECT O.customer_id
    FROM Orders O
    JOIN Order_items OI ON O.order_id = OI.order_id
    JOIN Products P ON OI.product_id = P.product_id
    WHERE P.product_name LIKE '%Smartphone%'
);

--Use of GETDATE() – Orders placed in the last 7 days
SELECT O.order_id, C.name, O.order_date
FROM Orders O
JOIN Customers C ON O.customer_id = C.customer_id
WHERE O.order_date >= DATEADD(DAY, -7, GETDATE());

--Total amount paid per customer, sorted highest to lowest
SELECT C.name, SUM(P.Amount_paid) AS TotalPaid
FROM Customers C
JOIN Orders O ON C.customer_id = O.customer_id
JOIN Payments P ON O.order_id = P.order_id
GROUP BY C.name
ORDER BY TotalPaid DESC;
