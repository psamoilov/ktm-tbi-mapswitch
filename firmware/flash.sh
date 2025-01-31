#!/bin/bash

# Функция для очистки экрана и отрисовки рамки
draw_menu() {
    clear
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "$1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Функция проверки наличия файла
check_firmware_file() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo "ОШИБКА: Файл прошивки '$file' не найден!"
        echo "Убедитесь, что файл находится в той же папке, что и скрипт."
        echo
        echo "Нажмите Enter для выхода..."
        read
        exit 1
    fi
}

# Проверка наличия esptool
if [ ! -f "./esptool" ]; then
    echo "ОШИБКА: Файл esptool не найден!"
    echo "Убедитесь, что файл esptool находится в той же папке, что и скрипт."
    echo
    echo "Нажмите Enter для выхода..."
    read
    exit 1
fi

# Выбор версии прошивки
draw_menu "     Выберите ревизию блока:      
1. Версия 1
2. Версия 2"

while true; do
    read -p "Введите номер ревизии (1 или 2): " version_choice
    case $version_choice in
        1) revision="v1"; break;;
        2) revision="v2"; break;;
        *) echo "Пожалуйста, введите 1 или 2";;
    esac
done

# Выбор типа обновления
draw_menu "Выбрана версия: $revision

Выберите тип обновления:
1. Полная прошивка (сброс настроек)
2. Только программа (с сохранением настроек)"

while true; do
    read -p "Выберите тип прошивки (1 или 2): " update_choice
    case $update_choice in
        1) update_type="full"; break;;
        2) update_type="update"; break;;
        *) echo "Пожалуйста, введите 1 или 2";;
    esac
done

# Определение имени файла прошивки и его проверка
if [ "$update_type" = "full" ]; then
    if [ "$revision" = "v1" ]; then
        firmware_file="firmware_full.v1.bin"
    else
        firmware_file="firmware_full.v2.bin"
    fi
else
    if [ "$revision" = "v1" ]; then
        firmware_file="firmware_update.v1.bin"
    else
        firmware_file="firmware_update.v2.bin"
    fi
fi

# Проверка наличия файла прошивки
check_firmware_file "$firmware_file"

# Отображение информации о выбранных параметрах
draw_menu "Начинаем обновление прошивки ESP32
Версия: $revision
Тип обновления: $update_type
Файл прошивки: $firmware_file"

# Выполнение прошивки
chmod +x esptool

if [ "$update_type" = "full" ]; then
    if [ "$revision" = "v1" ]; then
        echo "Запуск полного обновления ревизии V1..."
        if ./esptool write_flash 0x0 "$firmware_file"; then
            echo "Прошивка успешно завершена!"
        else
            echo "ОШИБКА: Не удалось выполнить прошивку!"
            exit 1
        fi
    else
        echo "Запуск полного обновления ревизии V2..."
        if ./esptool write_flash 0x0 "$firmware_file"; then
            echo "Прошивка успешно завершена!"
        else
            echo "ОШИБКА: Не удалось выполнить прошивку!"
            exit 1
        fi
    fi
else
    if [ "$revision" = "v1" ]; then
        echo "Запуск частичного обновления ревизии V1..."
        if ./esptool write_flash 0x10000 "$firmware_file"; then
            echo "Прошивка успешно завершена!"
        else
            echo "ОШИБКА: Не удалось выполнить прошивку!"
            exit 1
        fi
    else
        echo "Запуск частичного обновления ревизии V2..."
        if ./esptool write_flash 0x10000 "$firmware_file"; then
            echo "Прошивка успешно завершена!"
        else
            echo "ОШИБКА: Не удалось выполнить прошивку!"
            exit 1
        fi
    fi
fi

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Обновление завершено!"
echo "Нажмите Enter для выхода..."
read