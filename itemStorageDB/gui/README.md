Конечно! Вот содержимое файла `gui/README.md`:

# 🐍 ScyllaDB GUI - Графический интерфейс для работы с данными

## 📋 Оглавление
1. [Обзор](#-обзор)
2. [Требования](#-требования)
3. [Установка](#-установка)
4. [Запуск](#-запуск)
5. [Возможности](#-возможности)
6. [Горячие клавиши](#-горячие-клавиши)
7. [Примеры запросов](#-примеры-запросов)
8. [Устранение неполадок](#-устранение-неполадок)

## 🎯 Обзор

ScyllaDB GUI - это графическое приложение на Python для удобной работы с кластером ScyllaDB. Приложение предоставляет интуитивно понятный интерфейс для выполнения CQL-запросов, просмотра результатов и управления данными.

![GUI Interface](https://img.shields.io/badge/Interface-Tkinter-blue)
![Python](https://img.shields.io/badge/Python-3.8%2B-green)
![ScyllaDB](https://img.shields.io/badge/ScyllaDB-5.4%2B-purple)

## ⚙️ Требования

### Обязательные компоненты:
- **Python 3.8+**
- **Установленный кластер ScyllaDB** (через `./scripts/init_cluster.sh`)
- **Выполненные миграции** (через `./scripts/run_migrations.sh`)

### Поддерживаемые ОС:
- ✅ Windows 10/11
- ✅ macOS 10.15+
- ✅ Linux (Ubuntu 18.04+, CentOS 7+)

## 📦 Установка

### 1. Установите зависимости:
```bash
# Перейдите в папку gui
cd gui

# Установите необходимые пакеты
pip install -r requirements.txt
```

### 2. Проверьте установку:
```bash
python --version
pip list | grep cassandra-driver
```

### Содержимое `requirements.txt`:
```
cassandra-driver==3.28.0
pandas==2.0.3
```

## 🚀 Запуск

### Быстрый запуск:
```bash
# Из корневой директории проекта
python gui/scylla_gui.py

# Или из папки gui
cd gui
python scylla_gui.py
```

### Запуск с параметрами:
```bash
# С указанием другого порта
python scylla_gui.py --port 9043

# С указанием IP адреса
python scylla_gui.py --host 10.5.0.3
```

## 💡 Возможности

### ✨ Основные функции:
- **📝 Выполнение CQL-заросов** - интерактивный редактор с подсветкой
- **📊 Табличный просмотр результатов** - автоматическое форматирование данных
- **⚡ Быстрые кнопки** - предустановленные запросы для быстрого доступа
- **📋 История выполнения** - лог всех выполненных операций
- **📤 Экспорт данных** - копирование в буфер обмена

### 🎨 Интерфейс:
- **Вкладка запросов** - редактор CQL с возможностью выполнения (Ctrl+Enter)
- **Вкладка результатов** - табличное представление данных с сортировкой
- **Быстрые кнопки** - категоризированные предустановленные запросы
- **Статус бар** - информация о подключении и результатах запросов

## ⌨️ Горячие клавиши

### Редактор запросов:
| Комбинация | Действие |
|------------|----------|
| `Ctrl + Enter` | Выполнить запрос |
| `Ctrl + C` | Копировать выделенный текст |
| `Ctrl + V` | Вставить из буфера обмена |
| `Ctrl + X` | Вырезать выделенный текст |
| `Ctrl + A` | Выделить весь текст |

### Таблица результатов:
| Комбинация | Действие |
|------------|----------|
| `Ctrl + C` | Копировать выделенные данные |
| `Ctrl + A` | Выделить все данные |
| `Double Click` | Просмотреть полное содержимое ячейки |

## 📝 Примеры запросов

### Базовые операции:
```sql
-- Просмотр всех товаров (ограничение 10)
SELECT * FROM product_by_id LIMIT 10;

-- Количество товаров в базе
SELECT COUNT(*) FROM product_by_id;

-- Список всех таблиц
SELECT table_name FROM system_schema.tables 
WHERE keyspace_name = 'ecommerce';
```

### Поиск по категориям:
```sql
-- Все электронные товары
SELECT * FROM products_by_category 
WHERE category = 'electronics';

-- Товары для дома
SELECT * FROM products_by_category 
WHERE category = 'home';

-- Одежда и аксессуары
SELECT * FROM products_by_category 
WHERE category = 'clothing';
```

### Поиск по брендам:
```sql
-- Все товары Apple
SELECT * FROM products_by_brand 
WHERE brand = 'Apple';

-- Товары Samsung
SELECT * FROM products_by_brand 
WHERE brand = 'Samsung';

-- Товары Nike
SELECT * FROM products_by_brand 
WHERE brand = 'Nike';
```

### Аналитические запросы:
```sql
-- Средняя цена по категориям
SELECT category, AVG(price) as avg_price 
FROM product_by_id 
GROUP BY category;

-- Товары с высоким рейтингом
SELECT title, rating, price 
FROM product_by_id 
WHERE rating > 4.5 
ALLOW FILTERING;

-- Самые дорогие товары
SELECT title, price, brand 
FROM product_by_id 
ORDER BY price DESC 
LIMIT 10;
```

## 🔧 Устранение неполадок

### ❌ Ошибка: "Unable to connect to cluster"
**Причина:** Кластер ScyllaDB не запущен
**Решение:**
```bash
# Запустите кластер
./scripts/init_cluster.sh

# Проверьте статус
./scripts/health_check.sh
```

### ❌ Ошибка: "Keyspace does not exist"
**Причина:** Миграции не выполнены
**Решение:**
```bash
# Выполните миграции
./scripts/run_migrations.sh
```

### ❌ Ошибка: "No module named 'cassandra'"
**Причина:** Не установлен драйвер Cassandra
**Решение:**
```bash
# Установите зависимости
pip install -r requirements.txt

# Или установите вручную
pip install cassandra-driver pandas
```

### ❌ Ошибка: "Connection timeout"
**Причина:** Проблемы с сетью или неправильный порт
**Решение:**
- Проверьте, что кластер запущен на портах 9042-9044
- Убедитесь, что нет блокировки firewall

## 🎯 Быстрые кнопки интерфейса

Приложение содержит предустановленные кнопки для быстрого доступа:

| Кнопка | Запрос | Описание |
|--------|--------|----------|
| 📊 Все | `SELECT * FROM product_by_id LIMIT 10` | 10 случайных товаров |
| 📱 Электроника | `SELECT * FROM products_by_category WHERE category = 'electronics'` | Вся электроника |
| 🍎 Apple | `SELECT * FROM products_by_brand WHERE brand = 'Apple'` | Товары Apple |
| 👕 Одежда | `SELECT * FROM products_by_category WHERE category = 'clothing'` | Вся одежда |
| 📚 Книги | `SELECT * FROM products_by_category WHERE category = 'books'` | Все книги |
| 🏠 Дом | `SELECT * FROM products_by_category WHERE category = 'home'` | Товары для дома |
| ⚽ Спорт | `SELECT * FROM products_by_category WHERE category = 'sports'` | Спортивные товары |
| 🔢 Count | `SELECT COUNT(*) FROM product_by_id` | Общее количество товаров |
| 📋 Таблицы | `SELECT table_name FROM system_schema.tables WHERE keyspace_name = 'ecommerce'` | Список таблиц |
| 🗑️ Очистить | `TRUNCATE product_by_id; TRUNCATE products_by_brand; TRUNCATE products_by_category` | Очистка всех данных |
| 🗂️ DESC | `DESC TABLES` | Описание таблиц |

## 📊 Особенности работы

### Автоматическое форматирование:
- Результаты запросов автоматически форматируются в таблицу
- Ширина колонок подстраивается под содержимое
- Поддержка прокрутки для больших результатов

### Безопасность:
- Приложение не modifies данные без явного запроса
- Все деструктивные операции требуют подтверждения
- Логирование всех выполненных операций

### Производительность:
- Асинхронное выполнение запросов
- Пагинация результатов для больших выборок
- Кэширование метаданных схемы

## 🤝 Contributing

Для внесения улучшений в GUI:

1. Форкните репозиторий
2. Создайте feature branch: `git checkout -b feature/new-feature`
3. Сделайте коммит изменений: `git commit -am 'Add new feature'`
4. Запушьте ветку: `git push origin feature/new-feature`
5. Создайте Pull Request

## 📄 Лицензия

Этот проект распространяется под лицензией MIT. См. файл `LICENSE` для подробностей.

## 🆘 Поддержка

Если у вас возникли проблемы:
1. Проверьте [документацию по устранению неполадок](../docs/troubleshooting.md)
2. Создайте Issue в репозитории GitHub
3. Напишите на почту: [your-email@example.com]

---

**Happy Querying!** 🎉
