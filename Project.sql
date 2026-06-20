CREATE DATABASE SalesProject;

USE SalesProject;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    city VARCHAR(50)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    quantity INT,
    order_date DATE,

    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO customers VALUES
(1, 'Ahmed', 'Cairo'),
(2, 'Sara', 'Giza'),
(3, 'Omar', 'Alex');

INSERT INTO products VALUES
(1, 'Laptop', 'Electronics', 15000),
(2, 'Phone', 'Electronics', 8000),
(3, 'Headphones', 'Accessories', 1200);

INSERT INTO orders VALUES
(1, 1, 1, 1, '2026-01-10'),
(2, 1, 3, 2, '2026-01-15'),
(3, 2, 2, 1, '2026-02-05'),
(4, 3, 1, 1, '2026-02-12'),
(5, 2, 3, 3, '2026-03-01');

--أول Task ليك (مهم جدًا)

--اعمل Query تطلع:

--اسم العميل
--اسم المنتج
--الكمية
--سعر المنتج
--إجمالي سعر الأوردر (quantity * price)

WITH OrderDetails AS (
    SELECT 
        c.customer_name,
        p.product_name,
        o.quantity,
        p.price,
        o.quantity * p.price AS total_price
    FROM orders o
    INNER JOIN customers c
        ON o.customer_id = c.customer_id
    INNER JOIN products p
        ON o.product_id = p.product_id
)

SELECT 
    customer_name,
    product_name,
    quantity,
    price,
    total_price
FROM OrderDetails;


--🎯 Task 2

--عايزين نطلع:

--customer_name
--total_spent (إجمالي اللي دفعه)
--ترتيب العملاء من الأعلى للأقل


WITH CustomerSpending AS (
    SELECT 
        c.customer_name,
        SUM(o.quantity * p.price) AS total_spent
    FROM orders o
    INNER JOIN customers c
        ON o.customer_id = c.customer_id
    INNER JOIN products p
        ON o.product_id = p.product_id
    GROUP BY c.customer_name
)

SELECT 
    customer_name,
    total_spent,
    RANK() OVER (ORDER BY total_spent DESC) AS customer_rank
FROM CustomerSpending;



--المطلوب:

--طلع:

--product_name
--total_quantity_sold
--total_revenue
--ترتيب المنتجات حسب الإيراد


WITH ProductSales AS (
    SELECT 
        p.product_name,
        SUM(o.quantity) AS total_quantity_sold,
        SUM(o.quantity * p.price) AS total_revenue
    FROM orders o
    INNER JOIN products p
        ON o.product_id = p.product_id
    GROUP BY p.product_name
)

SELECT 
    product_name,
    total_quantity_sold,
    total_revenue,
    RANK() OVER (ORDER BY total_revenue DESC) AS product_rank
FROM ProductSales;



------Monthly Sales Trend Analysis

------وفيه:

------DATEPART
------Aggregation by month
------Running Total
------Window Functions بشكل أقوى

WITH MonthlySales AS (
    SELECT 
        DATEPART(MONTH, o.order_date) AS month_number,
        DATENAME(MONTH, o.order_date) AS month_name,
        SUM(o.quantity * p.price) AS monthly_sales
    FROM orders o
    INNER JOIN products p
        ON o.product_id = p.product_id
    GROUP BY 
        DATEPART(MONTH, o.order_date),
        DATENAME(MONTH, o.order_date)
)

SELECT 
    month_number,
    month_name,
    monthly_sales,

    SUM(monthly_sales) OVER (
        ORDER BY month_number
    ) AS running_total

FROM MonthlySales
ORDER BY month_number;