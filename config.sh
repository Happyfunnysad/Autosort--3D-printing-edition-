#!/bin/bash

# Конфигурационный файл для скрипта автосортировки 3D-файлов

# --- ПУТИ ---
# Папка, которую нужно отслеживать (откуда брать файлы)
SOURCE_DIR="$HOME/Downloads"

# Папка назначения (куда перемещать 3D-файлы)
TARGET_DIR="$HOME/Downloads/3D_Models"

# --- ФОРМАТЫ ФАЙЛОВ ---
# Расширения файлов для поиска (через вертикальную черту |)
# Можно добавить свои форматы, например: "stl|obj|3mf|gcode|lys|ctb|ply|amf"
EXTS="stl|obj|3mf|gcode|lys|ctb"

# --- ФИЛЬТРАЦИЯ ПО ИСТОЧНИКУ ---
# Включить фильтрацию по источнику скачивания (true/false)
# Если false, будут перемещаться все 3D-файлы независимо от источника
ENABLE_SOURCE_FILTER=true

# Список доменов для фильтрации (укажите сайты, с которых скачиваете файлы)
# Примеры: "printables.com", "thingiverse.com", "myminifactory.com"
# Если ENABLE_SOURCE_FILTER=false, этот список игнорируется
SOURCE_DOMAINS=(
    # --- ТОП-5 Самых популярных (Маст-хэв) ---
    "printables.com"       # Prusa (бывший prusaprinters)
    "thingiverse.com"      # Самый старый и большой
    "makerworld.com"       # Bambu Lab (сейчас очень популярен)
    "cults3d.com"          # Огромная база (много платного)
    "myminifactory.com"    # Качественные модели (D&D, фигурки)
    "thangs.com"           # Поисковик с геометрическим поиском

    # --- Маркетплейсы 3D-моделей (есть раздел для печати) ---
    "cgtrader.com"
    "turbosquid.com"
    "sketchfab.com"
    "gambody.com"          # Высокодетализированные фигурки (платно)
    "3dexport.com"
    "renderhub.com"

    # --- Инженерные и CAD (детали, механизмы) ---
    "grabcad.com"          # Инженерная база
    "youmagine.com"        # Ultimaker
    "3dcontentcentral.com"
    "tinkercad.com"        # Часто скачивают свои проекты
    "autodesk.com"         # Fusion 360 web links

    # --- Платформы производителей принтеров ---
    "crealitycloud.com"    # Creality
    "prusaprinters.org"    # Старый домен Printables (лучше оставить)
    "anycubic.com"
    "elegoo.com"
    "xyzprinting.com"

    # --- Другие популярные репозитории ---
    "pinshape.com"
    "redpah.com"
    "libre3d.com"
    "nasa.gov"             # У NASA огромная база 3D моделей космоса
    "smithsonian3d.si.edu" # Музейные экспонаты (Смитсоновский институт)
    "yeggi.com"            # Агрегатор (иногда источник прописывается так)
    "stlfinder.com"        # Агрегатор
)

# --- ЛОГИРОВАНИЕ ---
# Путь к файлу лога
LOG_FILE="/tmp/sort_3d.log"

# --- CRON НАСТРОЙКИ ---
# Интервал запуска скрипта через cron
# Формат: "*/5" = каждые 5 минут, "*/10" = каждые 10 минут, "0 * * * *" = каждый час
CRON_INTERVAL="*/5"

