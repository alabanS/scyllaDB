# ScyllaDB 3-Node Cluster - Полное руководство по установке и использованию

## 📋 Оглавление
1. [Предварительные требования](#-предварительные-требования)
2. [Установка и настройка](#-установка-и-настройка)
3. [Запуск кластера](#-запуск-кластера)
4. [Работа с данными](#-работа-с-данными)
5. [Примеры запросов](#-примеры-запросов)
6. [Мониторинг и управление](#-мониторинг-и-управление)
7. [Устранение неполадок](#-устранение-неполадок)

## 🛠 Предварительные требования

### Для Windows:
- **Docker Desktop** с включенным WSL2 backend
- **WSL2** (Windows Subsystem for Linux)
- Минимум **4GB RAM**
- **2+ ядра CPU**

### Для Linux/macOS:
- **Docker Engine** версии 20.10+
- **Docker Compose** версии 2.0+

### Проверка установки:
```bash
# Проверяем Docker
docker --version
docker-compose --version

# Проверяем WSL2 (для Windows)
wsl --list --verbose
```

## 📦 Установка и настройка

### 1. Клонируем и настраиваем проект

```bash
# Создаем рабочую директорию
mkdir scylla-cluster
cd scylla-cluster

# Создаем необходимые файлы
touch docker-compose.yml init.cql insert_data.cql queries.cql
```

### 2. Настройка WSL2 (только для Windows)

```bash
# Открываем PowerShell от имени администратора и выполняем:
wsl --shutdown
wsl -u root -e bash -c "echo 262144 > /proc/sys/fs/aio-max-nr && echo 'fs.aio-max-nr = 262144' >> /etc/sysctl.conf && sysctl -p"
```

### 3. Создаем docker-compose.yml

```yaml
version: '3.8'

services:
  scylla-node1:
    image: scylladb/scylla:5.4.0
    container_name: scylla-node1
    networks:
      scylla-net:
        ipv4_address: 10.5.0.2
    ports:
      - "9042:9042"
      - "19042:19042"
    command: >
      --seeds=10.5.0.2
      --listen-address=10.5.0.2
      --broadcast-address=10.5.0.2
      --broadcast-rpc-address=10.5.0.2
      --endpoint-snitch=SimpleSnitch
      --smp 1
      --developer-mode=1

  scylla-node2:
    image: scylladb/scylla:5.4.0
    container_name: scylla-node2
    networks:
      scylla-net:
        ipv4_address: 10.5.0.3
    command: >
      --seeds=10.5.0.2
      --listen-address=10.5.0.3
      --broadcast-address=10.5.0.3
      --broadcast-rpc-address=10.5.0.3
      --endpoint-snitch=SimpleSnitch
      --smp 1
      --developer-mode=1

  scylla-node3:
    image: scylladb/scylla:5.4.0
    container_name: scylla-node3
    networks:
      scylla-net:
        ipv4_address: 10.5.0.4
    command: >
      --seeds=10.5.0.2
      --listen-address=10.5.0.4
      --broadcast-address=10.5.0.4
      --broadcast-rpc-address=10.5.0.4
      --endpoint-snitch=SimpleSnitch
      --smp 1
      --developer-mode=1

networks:
  scylla-net:
    driver: bridge
    ipam:
      config:
        - subnet: 10.5.0.0/16
          gateway: 10.5.0.1
```

### 4. Создаем init.cql

```sql
-- Создаем keyspace с репликацией RF=3
CREATE KEYSPACE IF NOT EXISTS ecommerce WITH replication = {
    'class': 'SimpleStrategy',
    'replication_factor': 3
};

USE ecommerce;

-- Основная таблица для поиска по ID
CREATE TABLE IF NOT EXISTS product_by_id (
    product_id uuid,
    sku text,
    title text,
    category text,
    description text,
    price decimal,
    old_price decimal,
    attributes map<text, text>,
    specifications map<text, text>,
    images list<text>,
    in_stock boolean,
    stock_quantity int,
    weight_kg decimal,
    brand text,
    manufacturer text,
    country_origin text,
    rating decimal,
    review_count int,
    is_active boolean,
    is_featured boolean,
    created_at timestamp,
    updated_at timestamp,
    published_at timestamp,
    PRIMARY KEY ((product_id))
);

-- Таблица для поиска по категориям
CREATE TABLE IF NOT EXISTS products_by_category (
    category text,
    bucket int,
    product_id uuid,
    sku text,
    title text,
    price decimal,
    brand text,
    rating decimal,
    in_stock boolean,
    created_at timestamp,
    PRIMARY KEY ((category, bucket), product_id)
) WITH CLUSTERING ORDER BY (product_id ASC);

-- Таблица для поиска по брендам
CREATE TABLE IF NOT EXISTS products_by_brand (
    brand text,
    bucket int,
    product_id uuid,
    sku text,
    title text,
    category text,
    price decimal,
    rating decimal,
    created_at timestamp,
    PRIMARY KEY ((brand, bucket), product_id)
) WITH CLUSTERING ORDER BY (product_id ASC);

-- Таблица для поиска по наличию на складе
CREATE TABLE IF NOT EXISTS products_in_stock (
    in_stock boolean,
    bucket int,
    product_id uuid,
    sku text,
    title text,
    category text,
    price decimal,
    brand text,
    created_at timestamp,
    PRIMARY KEY ((in_stock, bucket), product_id)
) WITH CLUSTERING ORDER BY (product_id ASC);
```

### 5. Создаем insert_data.cql

```sql
USE ecommerce;

-- Очищаем существующие данные (опционально)
TRUNCATE product_by_id;
TRUNCATE products_by_category;
TRUNCATE products_by_brand;
TRUNCATE products_in_stock;

-- Вставляем тестовые данные в product_by_id
INSERT INTO product_by_id (product_id, sku, title, category, description, price, old_price, attributes, brand, in_stock, stock_quantity, rating, review_count, created_at) 
VALUES (uuid(), 'SKU100001', 'Смартфон Samsung Galaxy S23 Ultra', 'electronics', 'Флагманский смартфон с лучшей камерой', 89999.99, 94999.99, {'color': 'black', 'storage': '256GB', 'ram': '12GB'}, 'Samsung', true, 25, 4.8, 124, toTimestamp(now()));

INSERT INTO product_by_id (product_id, sku, title, category, description, price, attributes, brand, in_stock, stock_quantity, rating, created_at) 
VALUES (uuid(), 'SKU100002', 'Ноутбук Apple MacBook Pro 16"', 'electronics', 'Профессиональный ноутбук', 199999.99, {'color': 'space gray', 'storage': '1TB', 'ram': '32GB'}, 'Apple', true, 12, 4.9, toTimestamp(now()));

INSERT INTO product_by_id (product_id, sku, title, category, description, price, attributes, brand, in_stock, stock_quantity, created_at) 
VALUES (uuid(), 'SKU100003', 'Наушники Sony WH-1000XM5', 'electronics', 'Беспроводные шумоподавляющие наушники', 29999.99, {'color': 'black', 'battery': '30h'}, 'Sony', true, 18, toTimestamp(now()));

INSERT INTO product_by_id (product_id, sku, title, category, description, price, attributes, brand, in_stock, stock_quantity, created_at) 
VALUES (uuid(), 'SKU200001', 'Джинсы Levi''s 501 Original', 'clothing', 'Классические прямые джинсы', 5999.99, {'color': 'blue', 'size': '32/32', 'material': 'denim'}, 'Levi''s', true, 45, toTimestamp(now()));

INSERT INTO product_by_id (product_id, sku, title, category, description, price, attributes, brand, in_stock, stock_quantity, created_at) 
VALUES (uuid(), 'SKU200002', 'Футболка Nike Dri-FIT', 'clothing', 'Спортивная футболка', 2999.99, {'color': 'black', 'size': 'L', 'material': 'polyester'}, 'Nike', true, 120, toTimestamp(now()));

INSERT INTO product_by_id (product_id, sku, title, category, description, price, attributes, in_stock, stock_quantity, created_at) 
VALUES (uuid(), 'SKU300001', 'Книга "Чистый код" Роберт Мартин', 'books', 'Руководство по написанию кода', 2999.99, {'author': 'Роберт Мартин', 'pages': '464', 'cover': 'soft'}, true, 34, toTimestamp(now()));

INSERT INTO product_by_id (product_id, sku, title, category, description, price, attributes, in_stock, stock_quantity, created_at) 
VALUES (uuid(), 'SKU300002', 'Книга "Искусство программирования"', 'books', 'Фундаментальный труд по программированию', 4999.99, {'author': 'Дональд Кнут', 'pages': '672', 'cover': 'hard'}, true, 8, toTimestamp(now()));

-- Вставляем данные в таблицы-индексы
INSERT INTO products_by_category (category, bucket, product_id, sku, title, price, brand, in_stock, created_at) 
SELECT 'electronics', 1, product_id, sku, title, price, brand, in_stock, created_at 
FROM product_by_id WHERE category = 'electronics';

INSERT INTO products_by_category (category, bucket, product_id, sku, title, price, brand, in_stock, created_at) 
SELECT 'clothing', 1, product_id, sku, title, price, brand, in_stock, created_at 
FROM product_by_id WHERE category = 'clothing';

INSERT INTO products_by_category (category, bucket, product_id, sku, title, price, brand, in_stock, created_at) 
SELECT 'books', 1, product_id, sku, title, price, brand, in_stock, created_at 
FROM product_by_id WHERE category = 'books';

INSERT INTO products_by_brand (brand, bucket, product_id, sku, title, category, price, created_at) 
SELECT brand, 1, product_id, sku, title, category, price, created_at 
FROM product_by_id WHERE brand IS NOT NULL;

INSERT INTO products_in_stock (in_stock, bucket, product_id, sku, title, category, price, brand, created_at) 
SELECT in_stock, 1, product_id, sku, title, category, price, brand, created_at 
FROM product_by_id;
```

### 6. Создаем queries.cql

```sql
-- Примеры запросов для тестирования

USE ecommerce;

-- 1. Получить все продукты
SELECT * FROM product_by_id;

-- 2. Получить продукты по категории
SELECT * FROM products_by_category WHERE category = 'electronics';

-- 3. Получить продукты по бренду
SELECT * FROM products_by_brand WHERE brand = 'Samsung';

-- 4. Получить товары в наличии
SELECT * FROM products_in_stock WHERE in_stock = true;

-- 5. Получить товары конкретной категории и бренда
SELECT * FROM products_by_category 
WHERE category = 'electronics' 
AND bucket = 1;

-- 6. Подсчет товаров по категориям
SELECT category, COUNT(*) as product_count 
FROM product_by_id 
GROUP BY category;

-- 7. Поиск товаров по цене (диапазон)
SELECT * FROM product_by_id 
WHERE price > 10000 AND price < 50000 
ALLOW FILTERING;

-- 8. Обновление количества на складе
UPDATE product_by_id 
SET stock_quantity = 30 
WHERE product_id = ?;

-- 9. Добавление отзыва (увеличение счетчика)
UPDATE product_by_id 
SET review_count = review_count + 1 
WHERE product_id = ?;

-- 10. Поиск по атрибутам
SELECT * FROM product_by_id 
WHERE attributes CONTAINS KEY 'color' 
AND attributes['color'] = 'black' 
ALLOW FILTERING;
```

## 🚀 Запуск кластера

### 1. Запуск Docker сети и контейнеров

```bash
# Создаем сеть (если не создана автоматически)
docker network create --driver=bridge --subnet=10.5.0.0/16 scylla-net

# Запускаем кластер
docker-compose up -d

# Ждем инициализации (2-3 минуты)
sleep 180

# Проверяем статус
docker exec -it scylla-node1 nodetool status
```

### 2. Инициализация базы данных

```bash
# Копируем файлы в контейнер
docker cp init.cql scylla-node1:/tmp/
docker cp insert_data.cql scylla-node1:/tmp/
docker cp queries.cql scylla-node1:/tmp/

# Выполняем инициализацию
docker exec -it scylla-node1 cqlsh -f /tmp/init.cql
docker exec -it scylla-node1 cqlsh -f /tmp/insert_data.cql
```

## 📊 Работа с данными

### Подключение к разным узлам:

```bash
# К узлу 1 (порт 9042)
docker exec -it scylla-node1 cqlsh 10.5.0.2
docker exec -it scylla-node2 cqlsh 10.5.0.3
docker exec -it scylla-node3 cqlsh 10.5.0.4

# Или напрямую с хоста
cqlsh localhost 9042 -e "USE ecommerce; SELECT * FROM product_by_id;"

# К узлу 2 (порт 9043)
cqlsh localhost 9043

# К узлу 3 (порт 9044)  
cqlsh localhost 9044
```

### Выполнение тестовых запросов:

```bash
# Выполняем примеры запросов
docker exec -it scylla-node1 cqlsh -f /tmp/queries.cql

# Или выполняем запросы вручную
docker exec -it scylla-node1 cqlsh -e "
USE ecommerce;
SELECT category, COUNT(*) as count FROM product_by_id GROUP BY category;
"
```

## 📝 Примеры запросов для тестирования

### 1. Базовые запросы
```sql
-- Количество товаров
SELECT COUNT(*) FROM product_by_id;

-- Товары по категориям
SELECT category, COUNT(*) as count 
FROM product_by_id 
GROUP BY category;

-- Самые дорогие товары
SELECT title, price FROM product_by_id 
ORDER BY price DESC LIMIT 5;
```

### 2. Запросы к индексам
```sql
-- Все электронные товары
SELECT * FROM products_by_category 
WHERE category = 'electronics';

-- Товары Samsung
SELECT * FROM products_by_brand 
WHERE brand = 'Samsung';

-- Товары в наличии
SELECT * FROM products_in_stock 
WHERE in_stock = true;
```

### 3. Агрегации и фильтрации
```sql
-- Средняя цена по категориям
SELECT category, AVG(price) as avg_price 
FROM product_by_id 
GROUP BY category;

-- Товары с рейтингом выше 4.5
SELECT title, rating FROM product_by_id 
WHERE rating > 4.5 ALLOW FILTERING;

-- Поиск по атрибутам
SELECT title, attributes FROM product_by_id 
WHERE attributes CONTAINS KEY 'color' 
ALLOW FILTERING;
```

## 📈 Мониторинг и управление

### Команды мониторинга:
```bash
# Статус кластера
docker exec -it scylla-node1 nodetool status

# Статистика использования
docker exec -it scylla-node1 nodetool cfstats ecommerce

# Информация о таблицах
docker exec -it scylla-node1 nodetool tablestats

# Просмотр логов
docker logs scylla-node1
docker-compose logs
```

### Управление кластером:
```bash
# Остановка кластера
docker-compose down

# Перезапуск
docker-compose restart

# Полная очистка
docker-compose down -v
docker network rm scylla-net
```

## 🐛 Устранение неполадок

### Распространенные проблемы:

1. **Ошибка AIO в WSL2**:
```bash
wsl --shutdown
wsl -u root -e bash -c "echo 262144 > /proc/sys/fs/aio-max-nr"
```

2. **Проблемы с сетью**:
```bash
docker network rm scylla-net
docker network create --driver=bridge --subnet=10.5.0.0/16 scylla-net
```

3. **Конфликты портов**:
Измените порты в `docker-compose.yml`

4. **Низкая производительность**:
Увеличьте ресурсы в `docker-compose.yml`

### Проверка работоспособности:

```bash
# Проверяем доступность узлов
curl http://localhost:19042/storage_service/host_ids
curl http://localhost:19043/storage_service/host_ids  
curl http://localhost:19044/storage_service/host_ids

# Проверяем данные на всех узлах
cqlsh localhost 9042 -e "SELECT COUNT(*) FROM ecommerce.product_by_id;"
cqlsh localhost 9043 -e "SELECT COUNT(*) FROM ecommerce.product_by_id;"
cqlsh localhost 9044 -e "SELECT COUNT(*) FROM ecommerce.product_by_id;"
```

## 🔗 Дополнительные ресурсы

- [Документация ScyllaDB](https://docs.scylladb.com/)
- [CQL Reference Guide](https://cassandra.apache.org/doc/latest/cql/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

---

Теперь у вас есть полностью функционирующий 3-узловой кластер ScyllaDB с тестовыми данными! 🎉
