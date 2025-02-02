@echo off
chcp
chcp 1251 > nul
chcp

:: �������� ������� esptool.exe
if not exist esptool.exe (
    echo ===============================================
    echo ������: ���� 'esptool.exe' �� ������!
    echo ���������, ��� ���� ��������� � ��� �� �����,
    echo ��� � ������.
    echo ===============================================
    pause
    exit /b
)

:select_revision
cls
echo ===============================================
echo     �������� ������� �����:        
echo ===============================================
echo 1. ������� 1                       
echo 2. ������� 2                       
echo ===============================================
choice /C 12 /N /M "������� ����� ������� (1 ��� 2): "
if errorlevel 2 (
    set "revision=v2"
) else (
    set "revision=v1"
)

:select_update_type
cls
echo ������� ������: %revision%
echo.
echo ===============================================
echo           �������� ��� ����������:                 
echo ===============================================
echo 1. ������ �������� (����� ��������)               
echo 2. ������ ��������� (� ����������� ��������)       
echo ===============================================
choice /C 12 /N /M "�������� ��� ���������� (1 ��� 2): "
if errorlevel 2 (
    set "update_type=update"
) else (
    set "update_type=full"
)

:: ����������� ����� ����� �������� � ��� ��������
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

:: �������� ������� ����� ��������
if not exist %firmware_file% (
    echo ===============================================
    echo ������: ���� '%firmware_file%' �� ������!
    echo ���������, ��� ���� ��������� � ��� �� �����,
    echo ��� � ������.
    echo ===============================================
    pause
    exit /b
)

cls
echo ===============================================
echo �������� ���������� �������� ESP32
echo ������: %revision%
echo ��� ����������: %update_type%
echo ���� ��������: %firmware_file%
echo ===============================================
echo.

:: ���������� �������� � ��������� ����������
if "%update_type%"=="full" (
    if "%revision%"=="v1" (
        echo ������ ������� ���������� ������� V1...
        esptool.exe write_flash 0x0 %firmware_file%
    ) else (
        echo ������ ������� ���������� ������� V2...
        esptool.exe write_flash 0x0 %firmware_file%
    )
) else (
    if "%revision%"=="v1" (
        echo ������ ���������� ���������� ������� V1...
        esptool.exe write_flash 0x10000 %firmware_file%
    ) else (
        echo ������ ���������� ���������� ������� V2...
        esptool.exe write_flash 0x10000 %firmware_file%
    )
)

:: �������� ���������� ���������� esptool
if errorlevel 1 (
    echo.
    echo ===============================================
    echo ������: �� ������� ��������� ��������!
    echo ===============================================
    pause
    exit /b
)

echo.
echo ===============================================
echo ���������� ������� ���������!
echo ������� ����� ������� ��� ������...
echo ===============================================
pause > nul