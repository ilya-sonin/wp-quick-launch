#!/bin/bash

# WordPress Docker Quick Start Script
# Автоматическая настройка и запуск WordPress окружения

set -e

ENV_FILE=".env"
ENV_CONFIGURED=".env.configured"

echo "========================================="
echo "WordPress Docker Quick Start"
echo "========================================="
echo ""

# Проверяем наличие WordPress
if [ ! -d "wordpress" ] || [ -z "$(ls -A wordpress 2>/dev/null)" ]; then
    echo "📦 WordPress не найден, ищу архив..."

    # Ищем архив WordPress
    WP_ARCHIVE=$(find . -maxdepth 1 -name "wordpress-*.zip" | head -1)

    if [ -z "$WP_ARCHIVE" ]; then
        echo "❌ Ошибка: WordPress архив не найден!"
        echo ""
        echo "Пожалуйста, скачайте WordPress:"
        echo "https://ru.wordpress.org/download/"
        echo ""
        echo "И поместите архив wordpress-*.zip в эту директорию"
        exit 1
    fi

    echo "✓ Найден архив: $WP_ARCHIVE"
    echo "Распаковка WordPress..."

    mkdir -p wordpress
    unzip -q "$WP_ARCHIVE" -d wordpress

    # Если распаковалось во вложенную папку wordpress/wordpress
    if [ -d "wordpress/wordpress" ]; then
        mv wordpress/wordpress/* wordpress/
        rm -rf wordpress/wordpress
    fi

    echo "✓ WordPress распакован"
    echo ""
fi

# Проверяем, был ли уже настроен .env
if [ -f "$ENV_CONFIGURED" ]; then
    echo "Конфигурация уже выполнена."
    echo "Запуск Docker контейнеров..."
    docker-compose up -d
    
    # Считываем порты из .env для вывода информации
    source .env
    
    echo ""
    echo "========================================="
    echo "Контейнеры успешно запущены!"
    echo "========================================="
    echo "WordPress:   http://localhost:${WORDPRESS_PORT}"
    echo "phpMyAdmin:  http://localhost:${PHPMYADMIN_PORT}"
    echo "MySQL Port:  ${MYSQL_PORT}"
    echo "========================================="
    echo ""
    echo "Для остановки используйте: docker-compose down"
    echo "Для пересоздания конфигурации удалите файл: .env.configured"
    exit 0
fi

# Интерактивная настройка
echo "Первый запуск - необходимо настроить порты"
echo ""

# Функция для проверки занятости порта
check_port() {
    if lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        return 0  # порт занят
    else
        return 1  # порт свободен
    fi
}

# Запрос порта WordPress
while true; do
    read -p "Введите порт для WordPress [по умолчанию: 8082]: " wp_port
    wp_port=${wp_port:-8082}
    
    if check_port $wp_port; then
        echo "⚠️  Порт $wp_port уже занят. Попробуйте другой."
    else
        echo "✓ Порт $wp_port свободен"
        break
    fi
done

# Запрос порта phpMyAdmin
while true; do
    read -p "Введите порт для phpMyAdmin [по умолчанию: 8083]: " pma_port
    pma_port=${pma_port:-8083}
    
    if check_port $pma_port; then
        echo "⚠️  Порт $pma_port уже занят. Попробуйте другой."
    else
        echo "✓ Порт $pma_port свободен"
        break
    fi
done

# Запрос порта MySQL
while true; do
    read -p "Введите порт для MySQL [по умолчанию: 3337]: " mysql_port
    mysql_port=${mysql_port:-3337}
    
    if check_port $mysql_port; then
        echo "⚠️  Порт $mysql_port уже занят. Попробуйте другой."
    else
        echo "✓ Порт $mysql_port свободен"
        break
    fi
done

# Запрос имени проекта
read -p "Введите имя проекта [по умолчанию: wp-my-project]: " project_name
project_name=${project_name:-wp-my-project}

# Генерация случайных паролей
generate_password() {
    LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 16
}

mysql_root_pass=$(generate_password)
mysql_user_pass=$(generate_password)

echo ""
echo "========================================="
echo "Создание конфигурации..."
echo "========================================="

# Создаем .env файл
cat > $ENV_FILE << EOF
# Project Configuration
PROJECT_NAME=$project_name
COMPOSE_PROJECT_NAME=$project_name

# WordPress Configuration
WORDPRESS_DEBUG=1
WORDPRESS_PORT=$wp_port

# MySQL Database Configuration
MYSQL_ROOT_PASSWORD=$mysql_root_pass
MYSQL_DATABASE=wordpress
MYSQL_USER=wordpress
MYSQL_PASSWORD=$mysql_user_pass
MYSQL_PORT=$mysql_port

# PHPMyAdmin Configuration
PHPMYADMIN_PORT=$pma_port

# PHP Configuration
PHP_MEMORY_LIMIT=512M
PHP_UPLOAD_MAX_FILESIZE=256M
PHP_POST_MAX_SIZE=256M
PHP_MAX_EXECUTION_TIME=600
PHP_MAX_INPUT_TIME=600

# Theme Development
THEME_NAME=room-real-estate-theme

# Docker Platform (linux/amd64 for Mac M1/M2, linux/arm64 for other)
DOCKER_PLATFORM=linux/amd64
EOF

echo "✓ Конфигурация создана"

# Создаем маркер, что конфигурация выполнена
touch $ENV_CONFIGURED

echo ""
echo "========================================="
echo "Запуск Docker контейнеров..."
echo "========================================="
docker-compose up -d

echo ""
echo "========================================="
echo "Установка завершена!"
echo "========================================="
echo ""
echo "📋 Сохраните эту информацию:"
echo ""
echo "WordPress:   http://localhost:$wp_port"
echo "phpMyAdmin:  http://localhost:$pma_port"
echo ""
echo "MySQL подключение:"
echo "  Host:      localhost"
echo "  Port:      $mysql_port"
echo "  Database:  wordpress"
echo "  User:      wordpress"
echo "  Password:  $mysql_user_pass"
echo ""
echo "phpMyAdmin вход:"
echo "  User:      root"
echo "  Password:  $mysql_root_pass"
echo ""
echo "========================================="
echo ""
echo "Следующие шаги:"
echo "1. Откройте http://localhost:$wp_port"
echo "2. Выберите язык и нажмите 'Продолжить'"
echo "3. Следуйте инструкциям установки WordPress"
echo ""
echo "Для остановки: docker-compose down"
echo "Для удаления всех данных: docker-compose down -v"
echo ""

