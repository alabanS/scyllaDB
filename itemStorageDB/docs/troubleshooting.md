Конечно! Вот содержимое файлов документации:

## 1. `docs/schema_diagram.md`

```markdown
# Диаграмма схемы данных Ecommerce

## 🗃️ Обзор схемы базы данных

### Keyspace: `ecommerce`
**Стратегия репликации:** SimpleStrategy  
**Фактор репликации:** 3

---

## 📊 Таблицы и их назначение

### 1. `product_by_id` - Основная таблица продуктов
**Первичный ключ:** `product_id` (UUID)

| Колонка      | Тип      | Описание                |
|-------------|----------|-------------------------|
| product_id  | uuid     | Уникальный ID продукта  |
| sku         | text     | Артикул продукта        |
| title       | text     | Название продукта       |
| category    | text     | Категория               |
| price       | decimal  | Цена                    |
| brand       | text     | Бренд                   |
| rating      | decimal  | Рейтинг (0.0-5.0)       |

**Назначение:** Основное хранение данных о продуктах, быстрый поиск по ID.

---

### 2. `products_by_brand` - Поиск по брендам  
**Первичный ключ:** `(brand, product_id)` - составной ключ

| Колонка      | Тип      | Описание                |
|-------------|----------|-------------------------|
| brand       | text     | Бренд (партиционный ключ) |
| product_id  | uuid     | ID продукта (clustering key) |
| title       | text     | Название продукта       |
| price       | decimal  | Цена                    |
| category    | text     | Категория               |
| rating      | decimal  | Рейтинг                 |
| sku         | text     | Артикул                 |

**Назначение:** Эффективный поиск всех продуктов определенного бренда.

---

### 3. `products_by_category` - Поиск по категориям
**Первичный ключ:** `(category, product_id)` - составной ключ

| Колонка      | Тип      | Описание                |
|-------------|----------|-------------------------|
| category    | text     | Категория (партиционный ключ) |
| product_id  | uuid     | ID продукта (clustering key) |
| title       | text     | Название продукта       |
| price       | decimal  | Цена                    |
| brand       | text     | Бренд                   |
| rating      | decimal  | Рейтинг                 |
| sku         | text     | Артикул                 |

**Назначение:** Быстрый поиск продуктов по категориям.


## 🎯 Паттерны доступа к данным

### 1. Поиск по ID продукта
```sql
SELECT * FROM product_by_id WHERE product_id = uuid;
```

### 2. Поиск продуктов по бренду
```sql
SELECT * FROM products_by_brand WHERE brand = 'Apple';
```

### 3. Поиск продуктов по категории  
```sql
SELECT * FROM products_by_category WHERE category = 'electronics';
```

### 4. Агрегации и аналитика
```sql
-- Средняя цена по категориям
SELECT category, AVG(price) as avg_price 
FROM product_by_id 
GROUP BY category;

-- Топ товаров по рейтингу
SELECT title, rating FROM product_by_id 
WHERE rating > 4.5 ALLOW FILTERING;
```

---

## 📈 Примеры данных

### Категории продуктов:
- `electronics` - Электроника
- `clothing` - Одежда  
- `books` - Книги
- `home` - Дом и кухня
- `sports` - Спортивные товары

### Популярные бренды:
- `Apple`, `Samsung`, `Sony` - Электроника
- `Nike`, `Adidas`, `Zara` - Одежда
- `Penguin`, `Bloomsbury`, `Harper` - Книги
- `IKEA`, `KitchenAid`, `Philips` - Дом

---

## 💡 Рекомендации по использованию

1. **Для поиска по ID** - используйте `product_by_id`
2. **Для фильтрации по бренду** - используйте `products_by_brand`  
3. **Для фильтрации по категории** - используйте `products_by_category`
4. **Для аналитических запросов** - используйте `product_by_id` с `ALLOW FILTERING`
5. **Избегайте полных сканирований** - всегда используйте партиционные ключи в WHERE

---

## 🔄 Миграции и изменения схемы

Все изменения схемы выполняются через миграционные файлы в папке `migrations/`:
- `00_drop_tables.cql` - очистка старых таблиц
- `01_create_tables.cql` - создание новой схемы
- `03_insert_data.cql` - наполнение тестовыми данными
```

## 2. `docs/troubleshooting.md`

```markdown
# Расширенное устранение неполадок ScyllaDB

## 🚨 Распространенные проблемы и решения

### 1. Проблемы с запуском кластера

#### ❌ Ошибка: "AIO max-nr"
**Симптомы:** Контейнеры не запускаются, ошибки в логах про AIO
```bash
ERROR: unable to create new AIO context: Resource temporarily unavailable
```

**Решение:**
```bash
# Для WSL2
wsl --shutdown
wsl -u root -e bash -c "echo 262144 > /proc/sys/fs/aio-max-nr"

# Для постоянного решения
echo "fs.aio-max-nr = 262144" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

#### ❌ Ошибка: Порт уже занят
**Решение:** Измените порты в `docker-compose.yml` или освободите порты:
```bash
# Поиск процессов использующих порты
sudo lsof -i :9042
sudo lsof -i :9043  
sudo lsof -i :9044

# Убить процесс (осторожно!)
sudo kill -9 <PID>
```

---

### 2. Проблемы с сетью

#### ❌ Ошибка: "Network not found"
```bash
ERROR: Network scylla-net not found
```

**Решение:**
```bash
# Создать сеть вручную
docker network create --driver=bridge --subnet=10.5.0.0/16 scylla-net

# Или пересоздать полностью
docker-compose down
docker network rm scylla-net
docker-compose up -d
```

#### ❌ Ошибка: Узлы не видят друг друга
**Симптомы:** `nodetool status` показывает только один узел

**Решение:**
```bash
# Проверить сетевые настройки
docker network inspect scylla-net

# Перезапустить кластер
docker-compose restart

# Проверить логи на предмет сетевых ошибок
docker logs scylla-node1
```

---

### 3. Проблемы с производительностью

#### ❌ Медленные запросы
**Решение:**
- Увеличьте ресурсы в `docker-compose.yml`:
```yaml
command: >
  --smp 4                # Увеличить ядра
  --memory 4G            # Увеличить память
```

- Проверьте индексы и запросы:
```sql
-- Используйте EXPLAIN для анализа запросов
EXPLAIN SELECT * FROM products_by_brand WHERE brand = 'Apple';
```

#### ❌ Ошибка: "Read timeout"
**Решение:** Увеличьте таймауты:
```bash
# В CQLSH
cqlsh --request-timeout=600

# В драйверах приложений - увеличьте timeout settings
```

---

### 4. Проблемы с данными

#### ❌ Ошибка: "Keyspace does not exist"
```bash
InvalidRequest: Error from server: code=2200 [Invalid query] 
message="Keyspace 'ecommerce' does not exist"
```

**Решение:** Выполните миграции:
```bash
./scripts/run_migrations.sh
```

#### ❌ Ошибка: "Unconfigured table"
**Решение:** Проверьте репликацию:
```sql
-- Проверить настройки keyspace
DESC KEYSPACE ecommerce;

-- Если репликация не настроена
ALTER KEYSPACE ecommerce WITH replication = {
    'class': 'SimpleStrategy', 
    'replication_factor': 3
};
```

---

### 5. Проблемы с подключением

#### ❌ CQLSH не подключается
**Решение:**
```bash
# Проверить доступность узла
docker exec scylla-node1 nodetool status

# Подключиться с явным указанием IP
cqlsh 10.5.0.2 9042

# Проверить firewall
sudo ufw status
```

#### ❌ Ошибка: "Unable to connect to any servers"
**Решение:**
```bash
# Проверить логи узла
docker logs scylla-node1

# Проверить сеть
docker exec scylla-node1 ping 10.5.0.3
```

---

## 🔧 Команды для диагностики

### Проверка состояния кластера
```bash
# Статус всех узлов
docker exec scylla-node1 nodetool status

# Информация о кластере
docker exec scylla-node1 nodetool describecluster

# Статистика использования
docker exec scylla-node1 nodetool cfstats
```

### Мониторинг производительности
```bash
# Топ ключей пространств
docker exec scylla-node1 nodetool tablestats

# Статус компактификации
docker exec scylla-node1 nodetool compactionstats

# Мониторинг в реальном времени
docker exec scylla-node1 nodetool tpstats
```

### Работа с данными
```bash
# Проверка целостности данных
docker exec scylla-node1 nodetool verify

# Ремонт узла
docker exec scylla-node1 nodetool repair

# Очистка кэша
docker exec scylla-node1 nodetool flush
```

---

## 📊 Логи и отладка

### Просмотр логов
```bash
# Логи в реальном времени
docker-compose logs -f

# Логи конкретного узла
docker logs scylla-node1 --tail 100 -f

# Логи с фильтром по ошибкам
docker logs scylla-node1 2>&1 | grep -i error
```

### Уровни логирования
```bash
# Изменить уровень логирования (внутри контейнера)
nodetool setlogginglevel org.apache.cassandra DEBUG

# Проверить текущие уровни
nodetool getlogginglevels
```

---

## 🆘 Экстренные ситуации

### Полный сброс кластера
```bash
# Остановить и удалить все
docker-compose down -v
docker network rm scylla-net

# Очистить данные на хосте (осторожно!)
sudo rm -rf /var/lib/docker/volumes/scylla-cluster_*

# Запустить заново
./scripts/init_cluster.sh
./scripts/run_migrations.sh
```

### Восстановление после сбоя
```bash
# Перезапустить узел
docker restart scylla-node1

# Проверить восстановление
docker exec scylla-node1 nodetool repair

# Принудительное восстановление
docker exec scylla-node1 nodetool rebuild
```

---

## 📞 Полезные ресурсы

- [Документация ScyllaDB](https://docs.scylladb.com/)
- [ScyllaDB University](https://university.scylladb.com/)
- [Community Forum](https://forum.scylladb.com/)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/scylla)

---

## 🎯 Быстрые команды для копирования

```bash
# Проверить здоровье кластера
./scripts/health_check.sh

# Перезапустить один узел
docker restart scylla-node1

# Просмотреть использование диска
docker exec scylla-node1 nodetool cfstats ecommerce

# Проверить подключение
cqlsh localhost 9042 -e "DESC KEYSPACES"
```

Сохраните этот файл для быстрого доступа к решениям常见 проблем! 🛠️
```

Теперь у вас есть полная документация с диаграммами схемы данных и расширенным руководством по устранению неполадок! 📚
