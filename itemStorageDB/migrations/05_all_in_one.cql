-- Создаем keyspace если нужно (раскомментируйте если нужно)
-- CREATE KEYSPACE IF NOT EXISTS ecommerce WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

-- USE ecommerce;

-- Удаляем старые таблицы
DROP TABLE IF EXISTS product_by_id;
DROP TABLE IF EXISTS products_by_brand;
DROP TABLE IF EXISTS products_by_category;
DROP TABLE IF EXISTS product_count_by_category;

-- Создаем таблицы
CREATE TABLE product_by_id (
    product_id uuid PRIMARY KEY,
    sku text,
    title text,
    category text,
    price decimal,
    brand text,
    rating decimal
);

CREATE TABLE products_by_brand (
    brand text,
    product_id uuid,
    title text,
    price decimal,
    category text,
    rating decimal,
    sku text,
    PRIMARY KEY (brand, product_id)
);

CREATE TABLE products_by_category (
    category text,
    product_id uuid,
    title text,
    price decimal,
    brand text,
    rating decimal,
    sku text,
    PRIMARY KEY (category, product_id)
);

CREATE TABLE product_count_by_category (
    category text PRIMARY KEY,
    count counter
);

-- Вставляем данные (только несколько примеров для краткости)
BEGIN BATCH
INSERT INTO product_by_id (product_id, sku, title, category, price, brand, rating) VALUES (now(), 'IPHONE13', 'iPhone 13', 'electronics', 999.99, 'Apple', 4.8);
INSERT INTO products_by_brand (brand, product_id, title, price, category, rating, sku) VALUES ('Apple', now(), 'iPhone 13', 999.99, 'electronics', 4.8, 'IPHONE13');
INSERT INTO products_by_category (category, product_id, title, price, brand, rating, sku) VALUES ('electronics', now(), 'iPhone 13', 999.99, 'Apple', 4.8, 'IPHONE13');

INSERT INTO product_by_id (product_id, sku, title, category, price, brand, rating) VALUES (now(), 'SGS23', 'Galaxy S23', 'electronics', 899.99, 'Samsung', 4.7);
INSERT INTO products_by_brand (brand, product_id, title, price, category, rating, sku) VALUES ('Samsung', now(), 'Galaxy S23', 899.99, 'electronics', 4.7, 'SGS23');
INSERT INTO products_by_category (category, product_id, title, price, brand, rating, sku) VALUES ('electronics', now(), 'Galaxy S23', 899.99, 'Samsung', 4.7, 'SGS23');

INSERT INTO product_by_id (product_id, sku, title, category, price, brand, rating) VALUES (now(), 'NIKEAIR', 'Nike Air Force 1', 'clothing', 119.99, 'Nike', 4.5);
INSERT INTO products_by_brand (brand, product_id, title, price, category, rating, sku) VALUES ('Nike', now(), 'Nike Air Force 1', 119.99, 'clothing', 4.5, 'NIKEAIR');
INSERT INTO products_by_category (category, product_id, title, price, brand, rating, sku) VALUES ('clothing', now(), 'Nike Air Force 1', 119.99, 'Nike', 4.5, 'NIKEAIR');
APPLY BATCH;

-- Тестовые запросы
SELECT '=== Все продукты (5 штук) ===' as info;
SELECT * FROM product_by_id LIMIT 5;

SELECT '=== Электроника ===' as info;
SELECT * FROM products_by_category WHERE category = 'electronics';

SELECT '=== Продукты Apple ===' as info;
SELECT * FROM products_by_brand WHERE brand = 'Apple';

SELECT '=== Структура таблиц ===' as info;
DESC TABLES;