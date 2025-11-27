@echo off
REM Конфигурационный файл для скрипта автосортировки 3D-файлов (Windows)

REM --- ПУТИ ---
REM Папка, которую нужно отслеживать (откуда брать файлы)
set "SOURCE_DIR=%USERPROFILE%\Downloads"

REM Папка назначения (куда перемещать 3D-файлы)
set "TARGET_DIR=%USERPROFILE%\Documents\3D_Models"

REM --- ФОРМАТЫ ФАЙЛОВ ---
REM Расширения файлов для поиска (через пробел)
REM Можно добавить свои форматы, например: "stl obj 3mf gcode lys ctb ply amf"
set "EXTS=stl obj 3mf gcode lys ctb"

REM --- ФИЛЬТРАЦИЯ ПО ИСТОЧНИКУ ---
REM Включить фильтрацию по источнику скачивания (true/false)
REM Если false, будут перемещаться все 3D-файлы независимо от источника
REM ВНИМАНИЕ: В Windows проверка источника ограничена (используется Zone.Identifier)
set "ENABLE_SOURCE_FILTER=false"

REM --- ЛОГИРОВАНИЕ ---
REM Путь к файлу лога
set "LOG_FILE=%TEMP%\sort_3d.log"

REM --- ПЛАНИРОВЩИК ЗАДАЧ ---
REM Для Windows используйте Планировщик заданий (Task Scheduler)
REM Создайте задачу, которая запускает sort_3d.bat каждые 5 минут
REM Или используйте setup.bat для автоматической настройки

