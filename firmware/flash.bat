@echo off
chcp 1251 > nul

:: Функция проверки наличия файла
:check_file
if not exist %~1 (
    echo ═══════════════════════════════════════════════
    echo ОШИБКА: Файл '%~1' не найден!
    echo Убедитесь, что файл находится в той же папке,
    echo что и скрипт.
    echo ═══════════════════════════════════════════════
    pause
    exit /b 1
)
exit /b 0

:: Проверка наличия esptool.exe
if not exist esptool.exe (
    echo ═══════════════════════════════════════════════
    echo ОШИБКА: Файл 'esptool.exe' не найден!
    echo Убедитесь, что файл находится в той же папке,
    echo что и скрипт.
    echo ═══════════════════════════════════════════════
    pause
    exit /b 1
)

:select_revision
cls
echo ╔════════════════════════════════════╗
echo ║     Выберите ревизию блока:        ║
echo ╠════════════════════════════════════╣
echo ║ 1. Ревизия 1                       ║
echo ║ 2. Ревизия 2                       ║
echo ╚════════════════════════════════════╝
choice /C 12 /N /M "Введите номер ревизии (1 или 2): "
if errorlevel 2 (
    set "revision=v2"
) else (
    set "revision=v1"
)

:select_update_type
cls
echo Выбрана версия: %revision%
echo.
echo ╔════════════════════════════════════════════════════╗
echo ║           Выберите тип обновления:                 ║
echo ╠════════════════════════════════════════════════════╣
echo ║ 1. Полная прошивка (сброс настроек)               ║
echo ║ 2. Только программа (с сохранением настроек)       ║
echo ╚════════════════════════════════════════════════════╝
choice /C 12 /N /M "Выберите тип обновления (1 или 2): "
if errorlevel 2 (
    set "update_type=update"
) else (
    set "update_type=full"
)

:: Определение имени файла прошивки и его проверка
if "%update_type%"=="full" (
    if "%revision%"=="v1" (
        set "firmware_file=firmware_full.v1.bin"
    ) else (
        set "firmware_file=firmware_full.v2.bin"
    )
) else (
    if "%revision%"=="v1" (
        set "firmware_file=firmware_update.v1.bin"
    ) else (
        set "firmware_file=firmware_update.v2.bin"
    )
)

:: Проверка наличия файла прошивки
call :check_file %firmware_file%
if errorlevel 1 exit /b

cls
echo ═══════════════════════════════════════════════
echo Начинаем обновление прошивки ESP32
echo Версия: %revision%
echo Тип обновления: %update_type%
echo Файл прошивки: %firmware_file%
echo ═══════════════════════════════════════════════
echo.

:: Выполнение прошивки с проверкой результата
if "%update_type%"=="full" (
    if "%revision%"=="v1" (
        echo Запуск полного обновления ревизии V1...
        esptool.exe write_flash 0x0 %firmware_file%
    ) else (
        echo Запуск полного обновления ревизии V2...
        esptool.exe write_flash 0x0 %firmware_file%
    )
) else (
    if "%revision%"=="v1" (
        echo Запуск частичного обновления ревизии V1...
        esptool.exe write_flash 0x10000 %firmware_file%
    ) else (
        echo Запуск частичного обновления ревизии V2...
        esptool.exe write_flash 0x10000 %firmware_file%
    )
)

:: Проверка результата выполнения esptool
if errorlevel 1 (
    echo.
    echo ═══════════════════════════════════════════════
    echo ОШИБКА: Не удалось выполнить прошивку!
    echo ═══════════════════════════════════════════════
    pause
    exit /b 1
)

echo.
echo ═══════════════════════════════════════════════
echo Обновление успешно завершено!
echo Нажмите любую клавишу для выхода...
echo ═══════════════════════════════════════════════
pause > nul