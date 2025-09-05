# ScyllaDB 3-Node Cluster with Docker Compose

Проект разворачивает полнофункциональный 3-узловой кластер ScyllaDB с тестовыми данными для e-commerce сценариев.

## 🚀 Особенности

- **3-узловой кластер** ScyllaDB с репликацией данных
- **Готовые схемы данных** для e-commerce приложений
- **Автоматическая инициализация** базы данных
- **Тестовые данные** для демонстрации работы
- **Доступ ко всем узлам** через разные порты
- **Оптимизированная конфигурация** для разработки

## 📋 Предварительные требования

- Docker Desktop с WSL2 backend
- Windows 10/11 или Linux/macOS
- 4+ GB RAM
- 2+ CPU cores

## 🛠 Установка и запуск

### 1. Клонирование репозитория

```bash
git clone <your-repo-url>
cd scylla-cluster
```

### 2. Настройка WSL2 (только для Windows)

```bash
# Закройте все WSL окна
wsl --shutdown

# Запустите WSL2 от администратора
wsl -u root

# Увеличьте лимит AIO
echo 262144 > /proc/sys/fs/aio-max-nr
echo "fs.aio-max-nr = 262144" >> /etc/sysctl.conf
sysctl -p

# Проверьте
cat /proc/sys/fs/aio-max-nr
# Должно показать 262144
exit
```

### 3. Запуск кластера

```bash
# Создаем сеть
docker network create --driver=bridge --subnet=10.5.0.0/16 scylla-net

# Запускаем кластер
docker-compose up -d

# Ждем инициализации (2-3 минуты)
timeout 180
```

### 4. Проверка статуса кластера

```bash
docker exec -it scylla-node1 nodetool status
```

## 📊 Структура данных

### Keyspace: `ecommerce`

**Таблицы:**
- `product_by_id` - Основная таблица для поиска по ID продукта
- `products_by_category` - Оптимизирована для поиска по категориям
- `products_by_brand` - Оптимизирована для поиска по брендам

### Схема репликации
- **Strategy**: SimpleStrategy
- **Replication Factor**: 3

## 🗄 Инициализация базы данных

```bash
# Копируем и выполняем скрипт инициализации
docker cp init.cql scylla-node1:/tmp/
docker exec -it scylla-node1 cqlsh -f /tmp/init.cql

# Наполняем тестовыми данными
docker cp insert_data.cql scylla-node1:/tmp/
docker exec -it scylla-node1 cqlsh -f /tmp/insert_data.cql
```

## 🔌 Доступ к узлам

| Узел | CQL порт | API порт | Команда доступа |
|------|----------|----------|-----------------|
| Node 1 | 9042 | 19042 | `cqlsh localhost 9042` |
| Node 2 | 9043 | 19043 | `cqlsh localhost 9043` |
| Node 3 | 9044 | 19044 | `cqlsh localhost 9044` |

## 📝 Примеры запросов

```sql
-- Подсчет продуктов
SELECT COUNT(*) FROM ecommerce.product_by_id;

-- Продукты по категориям
SELECT category, COUNT(*) as count 
FROM ecommerce.product_by_id 
GROUP BY category;

-- Поиск по категории
SELECT * FROM ecommerce.products_by_category 
WHERE category = 'electronics';
```

## 🧹 Управление кластером

### Остановка и очистка

```bash
# Остановка кластера
docker-compose down

# Полная очистка
docker stop $(docker ps -aq --filter "name=scylla") 2>/dev/null
docker rm $(docker ps -aq --filter "name=scylla") 2>/dev/null
```

### Мониторинг

```bash
# Просмотр логов
docker-compose logs
docker logs scylla-node1

# Статистика кластера
docker exec -it scylla-node1 nodetool cfstats ecommerce

# Информация о таблицах
docker exec -it scylla-node1 nodetool tablestats
```

## ⚙️ Конфигурация

### Параметры запуска:
- `--smp 1` - Один процессорный core на узел
- `--developer-mode=1` - Режим разработки
- `--overprovisioned 1` - Оптимизация для виртуализации
- `SimpleSnitch` - Простая стратегия для разработки

### Ресурсы:
- 1 CPU core на узел
- 1GB RAM на узел
- Сеть: 10.5.0.0/16

## 🐛 Решение проблем

### Ошибка AIO в WSL2:
```bash
wsl --shutdown
wsl -u root
echo 262144 > /proc/sys/fs/aio-max-nr
exit
```

### Конфликты портов:
Измените порты в `docker-compose.yml` если необходимо

### Проблемы с сетью:
```bash
docker network rm scylla-net
docker network create --driver=bridge --subnet=10.5.0.0/16 scylla-net
```

## 📈 Производительность

Кластер настроен для разработки с минимальными требованиями. Для production использования:

1. Увеличьте ресурсы CPU и RAM
2. Используйте `NetworkTopologyStrategy` вместо `SimpleStrategy`
3. Настройте `smp` параметры в соответствии с ядрами CPU
4. Уберите `--developer-mode=1`

## 🤝 Contributing

Приветствуются улучшения и исправления! Пожалуйста:

1. Форкните репозиторий
2. Создайте feature branch
3. Commit ваши изменения
4. Push в branch
5. Создайте Pull Request

## 📄 Лицензия

Этот проект распространяется под MIT License.

## 🔗 Полезные ссылки

- [ScyllaDB Documentation](https://docs.scylladb.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [CQL Reference](https://cassandra.apache.org/doc/latest/cql/)

---

**Примечание**: Этот кластер предназначен для разработки и тестирования. Для production использования требуется дополнительная настройка и оптимизация.


