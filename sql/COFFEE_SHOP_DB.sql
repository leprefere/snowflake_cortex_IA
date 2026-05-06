CREATE DATABASE IF NOT EXISTS COFFEE_SHOP_DB;
USE DATABASE COFFEE_SHOP_DB;


CREATE OR REPLACE TABLE categories (
    category_id INT AUTOINCREMENT,
    category_name STRING
);
CREATE OR REPLACE TABLE products (
    product_id INT AUTOINCREMENT,
    name STRING,
    category_id INT,
    price FLOAT,
    is_available BOOLEAN
);

CREATE OR REPLACE TABLE orders (
    order_id INT AUTOINCREMENT,
    customer_id INT,
    order_date DATE
);

CREATE OR REPLACE TABLE order_items (
    order_item_id INT AUTOINCREMENT,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price FLOAT
);
CREATE OR REPLACE TABLE customers (
    customer_id INT AUTOINCREMENT,
    full_name STRING,
    city STRING,
    created_at DATE
);


INSERT INTO categories (category_name) VALUES
('Hot Drinks'),
('Cold Drinks'),
('Desserts'),
('Cakes'),
('Snacks');

INSERT INTO products (name, category_id, price, is_available)
VALUES
('Espresso', 1, 2.5, TRUE),
('Americano', 1, 3.0, TRUE),
('Cappuccino', 1, 3.5, TRUE),
('Latte', 1, 4.0, TRUE);

INSERT INTO products (name, category_id, price, is_available)
VALUES
('Iced Latte', 2, 4.5, TRUE),
('Iced Americano', 2, 3.5, TRUE),
('Mojito Coffee', 2, 5.0, TRUE);

INSERT INTO products (name, category_id, price, is_available)
VALUES
('Cheesecake', 3, 5.5, TRUE),
('Brownie', 3, 4.5, TRUE),
('Tiramisu', 3, 6.0, TRUE);

INSERT INTO products (name, category_id, price, is_available)
VALUES
('Chocolate Cake', 4, 6.5, TRUE),
('Vanilla Cake', 4, 6.0, TRUE),
('Red Velvet Cake', 4, 7.0, TRUE);

INSERT INTO products (name, category_id, price, is_available)
VALUES
('Croissant', 5, 2.0, TRUE),
('Muffin', 5, 2.5, TRUE),
('Cookies', 5, 1.5, TRUE);

INSERT INTO customers (full_name, city, created_at) VALUES
('Alice Martin', 'Paris', '2024-01-10'),
('Karim Benali', 'Paris', '2024-02-12'),
('Sophie Laurent', 'Lyon', '2024-03-05'),
('Mehdi Cherif', 'Marseille', '2024-03-20');


INSERT INTO orders (customer_id, order_date) VALUES
(1, '2024-04-01'),
(2, '2024-04-01'),
(3, '2024-04-02'),
(1, '2024-04-03'),
(4, '2024-04-03');


INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 2, 2.5),
(1, 8, 1, 5.5);


INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(2, 4, 1, 4.0),
(2, 12, 2, 2.0);


INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(3, 5, 2, 4.5),
(3, 9, 1, 4.5);



INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(4, 2, 1, 3.0),
(4, 10, 1, 6.0);

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(5, 11, 1, 6.5),
(5, 6, 2, 3.5);

GRANT USAGE ON DATABASE COFFEE_SHOP_DB TO ROLE PUBLIC;
GRANT USAGE ON SCHEMA COFFEE_SHOP_DB.PUBLIC TO ROLE PUBLIC;

GRANT SELECT ON ALL TABLES IN SCHEMA COFFEE_SHOP_DB.PUBLIC TO ROLE PUBLIC;


ALTER TABLE products ADD COLUMN description STRING;
SELECT name, description
FROM COFFEE_SHOP_DB.PUBLIC.products
ORDER BY product_id;

USE DATABASE COFFEE_SHOP_DB;

UPDATE products SET description = 'Strong and bold espresso shot, pure coffee intensity' WHERE name = 'Espresso';
UPDATE products SET description = 'Espresso diluted with hot water, smooth and light' WHERE name = 'Americano';
UPDATE products SET description = 'Espresso topped with steamed milk and thick foam' WHERE name = 'Cappuccino';
UPDATE products SET description = 'Smooth milk coffee with a shot of espresso' WHERE name = 'Latte';

UPDATE products SET description = 'Chilled latte served over ice, creamy and refreshing' WHERE name = 'Iced Latte';
UPDATE products SET description = 'Cold espresso with water poured over ice' WHERE name = 'Iced Americano';
UPDATE products SET description = 'Refreshing coffee mojito with mint and lime flavors' WHERE name = 'Mojito Coffee';

UPDATE products SET description = 'Creamy New York style cheesecake with a buttery crust' WHERE name = 'Cheesecake';
UPDATE products SET description = 'Rich and fudgy dark chocolate brownie' WHERE name = 'Brownie';
UPDATE products SET description = 'Classic Italian dessert with mascarpone and coffee' WHERE name = 'Tiramisu';

UPDATE products SET description = 'Decadent chocolate layer cake with ganache frosting' WHERE name = 'Chocolate Cake';
UPDATE products SET description = 'Light and fluffy vanilla sponge cake with cream' WHERE name = 'Vanilla Cake';
UPDATE products SET description = 'Moist red velvet cake with cream cheese frosting' WHERE name = 'Red Velvet Cake';

UPDATE products SET description = 'Flaky buttery French croissant, freshly baked' WHERE name = 'Croissant';
UPDATE products SET description = 'Soft and moist muffin available in seasonal flavors' WHERE name = 'Muffin';
UPDATE products SET description = 'Crunchy homemade cookies with chocolate chips' WHERE name = 'Cookies';


CREATE OR REPLACE TABLE evaluation_dataset (
    question STRING,
    expected_sql STRING
);

TRUNCATE TABLE evaluation_dataset;

INSERT INTO evaluation_dataset VALUES
(
'Top selling products',
'SELECT p.name, SUM(oi.quantity * oi.unit_price)
 FROM products p
 JOIN order_items oi ON p.product_id = oi.product_id
 GROUP BY p.name
 ORDER BY SUM(oi.quantity * oi.unit_price) DESC'
),

(
'Revenue by category',
'SELECT c.category_name, SUM(oi.quantity * oi.unit_price)
 FROM categories c
 JOIN products p ON c.category_id = p.category_id
 JOIN order_items oi ON p.product_id = oi.product_id
 GROUP BY c.category_name'
);
