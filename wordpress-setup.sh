#!/bin/bash

# Скрипт для подготовки архива WordPress для git репозитория

echo "Этот скрипт создаст архив wordpress-6.9-ru_RU.zip из текущей папки wordpress/"
echo ""

if [ ! -d "wordpress" ]; then
    echo "❌ Папка wordpress/ не найдена"
    exit 1
fi

read -p "Создать архив? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Отменено"
    exit 0
fi

echo "Создание архива..."
cd wordpress
zip -q -r ../wordpress-6.9-ru_RU.zip .
cd ..

echo "✓ Архив создан: wordpress-6.9-ru_RU.zip"
echo ""
echo "Теперь можно закоммитить этот архив в git"

