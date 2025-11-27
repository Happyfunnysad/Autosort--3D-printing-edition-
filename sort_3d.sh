#!/bin/bash

# Скрипт автоматической сортировки файлов для 3D-печати
# Проверяет расширения файлов и метаданные источника скачивания

# Загружаем конфигурацию
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/config.sh" ]; then
    source "$SCRIPT_DIR/config.sh"
else
    # Значения по умолчанию, если config.sh отсутствует
    SOURCE_DIR="$HOME/Downloads"
    TARGET_DIR="$HOME/Documents/3D_Models"
    EXTS="stl|obj|3mf|gcode|lys|ctb"
    LOG_FILE="/tmp/sort_3d.log"
    ENABLE_SOURCE_FILTER=false
    SOURCE_DOMAINS=()
fi

# Функция логирования
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Функция для установки цветной метки через AppleScript
# Красный = 2, Оранжевый = 1, Желтый = 3, Синий = 4, Зеленый = 6, Фиолетовый = 5
set_label() {
    local file_path="$1"
    local label_color="${2:-2}"  # По умолчанию красный
    
    osascript -e "tell application \"Finder\" to set label index of (POSIX file \"$file_path\" as alias) to $label_color" 2>/dev/null
}

# Функция проверки источника файла
check_source() {
    local file_path="$1"
    
    if [ "$ENABLE_SOURCE_FILTER" = false ] || [ ${#SOURCE_DOMAINS[@]} -eq 0 ]; then
        return 0  # Если фильтр по источнику отключен, считаем что проверка пройдена
    fi
    
    # Получаем метаданные источника
    local where_from=$(mdls -name kMDItemWhereFroms "$file_path" 2>/dev/null)
    
    if [ -z "$where_from" ] || [ "$where_from" = "kMDItemWhereFroms = (null)" ]; then
        return 1  # Метаданные источника отсутствуют
    fi
    
    # Проверяем наличие любого из указанных доменов
    for domain in "${SOURCE_DOMAINS[@]}"; do
        if echo "$where_from" | grep -qi "$domain"; then
            return 0  # Домен найден
        fi
    done
    
    return 1  # Ни один домен не найден
}

# Функция проверки расширения файла
is_3d_file() {
    local file_path="$1"
    local filename=$(basename "$file_path")
    
    # Проверяем расширение (регистронезависимо)
    if echo "$filename" | grep -iE "\.($EXTS)$" > /dev/null; then
        return 0
    fi
    
    return 1
}

# Функция проверки папки на наличие 3D-файлов
folder_contains_3d() {
    local folder_path="$1"
    
    # Ищем файлы с нужными расширениями (рекурсивно)
    # Используем -print -quit для остановки после первого найденного файла (для скорости)
    IFS='|' read -ra EXT_ARRAY <<< "$EXTS"
    for ext in "${EXT_ARRAY[@]}"; do
        if find "$folder_path" -type f -iname "*.${ext}" -print -quit 2>/dev/null | grep -q .; then
            return 0
        fi
    done
    
    return 1
}

# Создаем целевую папку, если её нет
mkdir -p "$TARGET_DIR"

# Переходим в папку загрузок
if [ ! -d "$SOURCE_DIR" ]; then
    log "ОШИБКА: Исходная папка не существует: $SOURCE_DIR"
    exit 1
fi

cd "$SOURCE_DIR" || exit 1

log "Начало проверки папки: $SOURCE_DIR"

# Проходимся по всем файлам и папкам в Загрузках
for item in *; do
    # Пропускаем скрытые файлы и системные файлы
    [[ "$item" == .* ]] && continue
    [[ "$item" == "sort_3d.sh" ]] && continue
    [[ "$item" == "config.sh" ]] && continue
    [[ "$item" == "setup.sh" ]] && continue
    
    # Пропускаем пустые итерации
    [ -z "$item" ] && continue
    
    item_path="$SOURCE_DIR/$item"
    MOVE_IT=false
    REASON=""
    
    # ЛОГИКА 1: Если это ПАПКА
    if [ -d "$item_path" ]; then
        # Проверяем, содержит ли папка 3D-файлы
        if folder_contains_3d "$item_path"; then
            # Если включена фильтрация по источнику, проверяем источник
            if [ "$ENABLE_SOURCE_FILTER" = true ]; then
                if check_source "$item_path"; then
                    MOVE_IT=true
                    REASON="папка содержит 3D-файлы и соответствует фильтру источника"
                else
                    log "Пропуск папки '$item': содержит 3D-файлы, но не соответствует фильтру источника"
                fi
            else
                MOVE_IT=true
                REASON="папка содержит 3D-файлы"
            fi
        fi
    
    # ЛОГИКА 2: Если это ФАЙЛ
    elif [ -f "$item_path" ]; then
        # Проверяем расширение файла
        if is_3d_file "$item_path"; then
            # Если включена фильтрация по источнику, проверяем источник
            if [ "$ENABLE_SOURCE_FILTER" = true ]; then
                if check_source "$item_path"; then
                    MOVE_IT=true
                    REASON="3D-файл соответствует фильтру источника"
                else
                    log "Пропуск файла '$item': 3D-файл, но не соответствует фильтру источника"
                fi
            else
                MOVE_IT=true
                REASON="3D-файл"
            fi
        fi
    fi
    
    # ВЫПОЛНЕНИЕ: Если условие совпало
    if [ "$MOVE_IT" = true ]; then
        log "Обработка: $item ($REASON)"
        
        # 1. Ставим цветную метку (красный = 2)
        set_label "$item_path" 2
        
        # 2. Перемещаем
        # mv -n означает "не перезаписывать, если файл с таким именем уже есть"
        if mv -n "$item_path" "$TARGET_DIR/" 2>/dev/null; then
            log "Успешно перемещен: $item -> $TARGET_DIR"
        else
            log "ОШИБКА при перемещении: $item"
        fi
    fi
done

log "Проверка завершена"

