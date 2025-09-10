Понял! Уберу код миграций, docker-compose и GUI, оставлю только ссылки. Вот очищенная версия статьи:

# ScyllaDB 3-Node Cluster - Полное руководство по установке и использованию

## 📋 Оглавление
1. [Предварительные требования](#-предварительные-требования)
2. [Установка и настройка](#-установка-и-настройка)
3. [Запуск кластера](#-запуск-кластера)
4. [Работа с данными](#-работа-с-данными)
5. [Примеры запросов](#-примеры-запросов)
6. [Мониторинг и управление](#-мониторинг-и-управление)
7. [Устранение неполадок](#-устранение-неполадок)
8. [Дополнительные инструменты](#-дополнительные-инструменты)

## 🛠 Предварительные требования

### Для Windows:
- **Docker Desktop** с включенным WSL2 backend
- **WSL2** (Windows Subsystem for Linux)
- Минимум **8GB RAM** (рекомендуется 16GB)
- **4+ ядра CPU**

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

### 1. Создаем рабочую директорию
```bash
mkdir scylla-cluster
cd scylla-cluster
```

### 2. Настройка WSL2 (только для Windows)
```bash
# Запустите WSL2 от администратора
wsl -u root

# Увеличьте лимит ДО запуска контейнеров
echo 262144 > /proc/sys/fs/aio-max-nr

# Для постоянного решения
echo "fs.aio-max-nr = 262144" >> /etc/sysctl.conf
sysctl -p

# Проверьте
cat /proc/sys/fs/aio-max-nr
# Должно показать 262144
exit
```

### 3. Конфигурация Docker Compose
Файл `docker-compose.yml` для развертывания кластера доступен в репозитории проекта:

[📁 docker-compose.yml на GitHub](https://github.com/alabanS/scyllaDB/blob/main/itemStorageDB/docker-compose.yml)

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

### 2. Миграции базы данных
Файлы миграций CQL для создания схемы базы данных и наполнения тестовыми данными доступны в репозитории:

[📁 Миграции на GitHub](https://github.com/alabanS/scyllaDB/tree/main/itemStorageDB/migrations)

## 📊 Работа с данными

### Подключение к разным узлам:
```bash
# К узлу 1 (порт 9042)
docker exec -it scylla-node1 cqlsh 10.5.0.2

# К узлу 2 (порт 9043)
docker exec -it scylla-node2 cqlsh 10.5.0.3

# К узлу 3 (порт 9044)  
docker exec -it scylla-node3 cqlsh 10.5.0.4

# Или напрямую с хоста
cqlsh localhost 9042 -e "USE ecommerce; SELECT * FROM product_by_id LIMIT 5;"
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

-- Товары Apple
SELECT * FROM products_by_brand 
WHERE brand = 'Apple';

-- Товары Samsung
SELECT * FROM products_by_brand 
WHERE brand = 'Samsung';
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

-- Товары дороже 100$
SELECT title, price FROM product_by_id 
WHERE price > 100 ALLOW FILTERING;
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

## 🛠 Дополнительные инструменты

### GUI для работы с данными
Для удобной работы с данными через графический интерфейс доступно Python GUI приложение:

[🐍 Scylla GUI на GitHub](https://github.com/your-username/scylla-cluster/blob/main/scylla_gui.py)

### Утилиты управления
Дополнительные скрипты для управления кластером и миграциями:

[📂 Утилиты на GitHub](https://github.com/your-username/scylla-cluster/tree/main/scripts)

---

## 🔗 Дополнительные ресурсы

- [Документация ScyllaDB](https://docs.scylladb.com/)
- [CQL Reference Guide](https://cassandra.apache.org/doc/latest/cql/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

Теперь у вас есть полностью функционирующий 3-узловой кластер ScyllaDB! 🎉
