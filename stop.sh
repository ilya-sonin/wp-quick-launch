#!/bin/bash

# WordPress Docker Stop Script

echo "========================================="
echo "WordPress Docker Stop"
echo "========================================="
echo ""
echo "Выберите действие:"
echo "1) Остановить контейнеры (данные сохранятся)"
echo "2) Остановить и удалить все данные (включая БД)"
echo "3) Сбросить конфигурацию (для повторной настройки портов)"
echo "4) Отмена"
echo ""
read -p "Ваш выбор [1-4]: " choice

case $choice in
    1)
        echo "Остановка контейнеров..."
        docker-compose down
        echo "✓ Контейнеры остановлены"
        ;;
    2)
        echo "⚠️  ВНИМАНИЕ: Все данные WordPress и БД будут удалены!"
        read -p "Вы уверены? (yes/no): " confirm
        if [ "$confirm" == "yes" ]; then
            echo "Удаление контейнеров и данных..."
            docker-compose down -v
            rm -f wordpress/wp-config.php
            echo "✓ Все данные удалены"
        else
            echo "Отменено"
        fi
        ;;
    3)
        echo "Сброс конфигурации..."
        rm -f .env.configured
        echo "✓ Конфигурация сброшена"
        echo "При следующем запуске start.sh будет выполнена повторная настройка"
        ;;
    4)
        echo "Отменено"
        ;;
    *)
        echo "Неверный выбор"
        exit 1
        ;;
esac

