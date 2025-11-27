@echo off
setlocal enabledelayedexpansion

REM Скрипт установки и настройки автосортировки 3D-файлов для Windows

echo ==========================================
echo Установка автосортировки 3D-файлов
echo ==========================================
echo.

set "SCRIPT_DIR=%~dp0"
set "SCRIPT_NAME=sort_3d.bat"
set "CONFIG_NAME=config.bat"

REM Проверяем наличие основного скрипта
if not exist "%SCRIPT_DIR%%SCRIPT_NAME%" (
    echo ОШИБКА: Не найден файл %SCRIPT_NAME%
    exit /b 1
)

REM Загружаем конфигурацию для получения путей
if exist "%SCRIPT_DIR%%CONFIG_NAME%" (
    call "%SCRIPT_DIR%%CONFIG_NAME%"
) else (
    echo ПРЕДУПРЕЖДЕНИЕ: Файл %CONFIG_NAME% не найден, используются значения по умолчанию
    set "TARGET_DIR=%USERPROFILE%\Documents\3D_Models"
)

REM Шаг 1: Создаем целевую папку
echo Шаг 1: Создание целевой папки...
if not exist "%TARGET_DIR%" (
    mkdir "%TARGET_DIR%"
    echo ✓ Папка создана: %TARGET_DIR%
) else (
    echo ✓ Папка уже существует: %TARGET_DIR%
)
echo.

REM Шаг 2: Настройка Планировщика заданий
echo Шаг 2: Настройка Планировщика заданий...
echo.

REM Создаем XML файл для задачи планировщика
set "TASK_NAME=AutoSort3DFiles"
set "XML_FILE=%TEMP%\sort_3d_task.xml"

(
echo ^<?xml version="1.0" encoding="UTF-16"?^>
echo ^<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task"^>
echo   ^<Triggers^>
echo     ^<CalendarTrigger^>
echo       ^<Repetition^>
echo         ^<Interval^>PT5M^</Interval^>
echo         ^<StopAtDurationEnd^>false^</StopAtDurationEnd^>
echo       ^</Repetition^>
echo       ^<StartBoundary^>%date%T%time:~0,5%^</StartBoundary^>
echo       ^<ExecutionTimeLimit^>PT10M^</ExecutionTimeLimit^>
echo       ^<Enabled^>true^</Enabled^>
echo       ^<ScheduleByDay^>
echo         ^<DaysInterval^>1^</DaysInterval^>
echo       ^</ScheduleByDay^>
echo     ^</CalendarTrigger^>
echo   ^</Triggers^>
echo   ^<Actions^>
echo     ^<Exec^>
echo       ^<Command^>"%SCRIPT_DIR%%SCRIPT_NAME%"^</Command^>
echo       ^<WorkingDirectory^>%SCRIPT_DIR%^</WorkingDirectory^>
echo     ^</Exec^>
echo   ^</Actions^>
echo ^</Task^>
) > "%XML_FILE%"

REM Проверяем, существует ли уже задача
schtasks /query /tn "%TASK_NAME%" >nul 2>&1
if %errorlevel% equ 0 (
    echo Найдена существующая задача планировщика: %TASK_NAME%
    set /p REPLACE="Заменить существующую задачу? (y/n): "
    if /i "!REPLACE!"=="y" (
        schtasks /delete /tn "%TASK_NAME%" /f >nul 2>&1
        schtasks /create /tn "%TASK_NAME%" /xml "%XML_FILE%" /f
        if !errorlevel! equ 0 (
            echo ✓ Задача планировщика обновлена
        ) else (
            echo ✗ Ошибка при создании задачи. Создайте задачу вручную через Планировщик заданий.
        )
    ) else (
        echo Задача планировщика не изменена
    )
) else (
    schtasks /create /tn "%TASK_NAME%" /xml "%XML_FILE%" /f
    if !errorlevel! equ 0 (
        echo ✓ Задача планировщика добавлена
    ) else (
        echo ✗ Ошибка при создании задачи. Создайте задачу вручную:
        echo   1. Откройте Планировщик заданий
        echo   2. Создайте простую задачу
        echo   3. Триггер: каждые 5 минут
        echo   4. Действие: запустить программу "%SCRIPT_DIR%%SCRIPT_NAME%"
    )
)

del "%XML_FILE%" >nul 2>&1
echo Расписание: каждые 5 минут
echo Лог файл: %TEMP%\sort_3d.log
echo.

REM Шаг 3: Тестирование
echo ==========================================
echo Тестирование
echo ==========================================
echo.
set /p TEST="Запустить тестовый прогон скрипта сейчас? (y/n): "
if /i "%TEST%"=="y" (
    echo Запуск тестового прогона...
    call "%SCRIPT_DIR%%SCRIPT_NAME%"
    echo.
    echo Проверьте лог файл: %TEMP%\sort_3d.log
    echo Проверьте целевую папку: %TARGET_DIR%
)

echo.
echo ==========================================
echo Установка завершена!
echo ==========================================
echo.
echo Скрипт будет запускаться автоматически каждые 5 минут
echo Для просмотра логов: type %TEMP%\sort_3d.log
echo Для редактирования настроек: notepad %SCRIPT_DIR%%CONFIG_NAME%
echo.

endlocal

