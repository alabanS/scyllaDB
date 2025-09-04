# ScyllaDB Article and Examples

Этот репозиторий содержит материалы и примеры для изучения ScyllaDB.

## Быстрый запуск с помощью Docker

Это самый простой способ запустить ScyllaDB для экспериментов с кодом из этого репозитория.

### Предварительные требования
*   Установленный [Docker](https://www.docker.com/get-started)
*   Установленный [Docker Compose](https://docs.docker.com/compose/install/) (обычно идет в комплекте с Docker Desktop)

### Запуск кластера

1.  Клонируйте этот репозиторий:
    ```bash
    git clone https://github.com/alabanS/scyllaDB.git
    cd scyllaDB
    ```

2.  Запустите ScyllaDB в Docker:
    ```bash
    docker-compose up -d
    ```

3.  Проверьте, что контейнер запустился:
    ```bash
    docker ps
    ```

4.  (Опционально) Посмотрите логи контейнера для диагностики:
    ```bash
    docker-compose logs scylla
    ```

### Подключение к ScyllaDB

После запуска вы можете подключиться к ноде с помощью CQLSH:

```bash
docker exec -it my_scylla_db cqlsh
```

Или подключиться из вашего приложения на localhost порт `9042`.

### Остановка кластера

Чтобы остановить и удалить контейнеры:
```bash
docker-compose down
```

Чтобы остановить и удалить контейнеры **вместе с данными** (будьте осторожны!):
```bash
docker-compose down -v
```
