-- 1. Базовые SELECT запросы
SELECT * FROM product_by_id LIMIT 5;
SELECT product_id, title, price, brand FROM product_by_id LIMIT 3;

-- 2. Запросы по категориям
SELECT * FROM products_by_category WHERE category = 'electronics' LIMIT 5;
SELECT * FROM products_by_category WHERE category = 'clothing';
SELECT * FROM products_by_category WHERE category = 'books';

-- 3. Запросы по брендам
SELECT * FROM products_by_brand WHERE brand = 'Apple';
SELECT * FROM products_by_brand WHERE brand = 'Samsung' LIMIT 3;
SELECT * FROM products_by_brand WHERE brand = 'Nike';

-- 4. Запросы с условиями (только для тестирования)
SELECT * FROM product_by_id WHERE price > 100 ALLOW FILTERING LIMIT 5;
SELECT * FROM product_by_id WHERE rating > 4.5 ALLOW FILTERING LIMIT 5;

-- 5. Проверка структуры таблиц
DESC TABLES;
DESC TABLE product_by_id;
DESC TABLE products_by_brand;

-- 6. Подсчет записей (примерно)
SELECT COUNT(*) FROM product_by_id LIMIT 1000;