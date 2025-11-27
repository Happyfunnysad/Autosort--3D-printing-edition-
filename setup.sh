#!/bin/bash

# Скрипт установки и настройки автосортировки 3D-файлов

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="sort_3d.sh"
CONFIG_NAME="config.sh"
CRON_LOG="/tmp/sort_3d.log"

echo "=========================================="
echo "Установка автосортировки 3D-файлов"
echo "=========================================="
echo ""

# Проверяем наличие основного скрипта
if [ ! -f "$SCRIPT_DIR/$SCRIPT_NAME" ]; then
    echo "ОШИБКА: Не найден файл $SCRIPT_NAME"
    exit 1
fi

# Загружаем конфигурацию для получения путей
if [ -f "$SCRIPT_DIR/$CONFIG_NAME" ]; then
    source "$SCRIPT_DIR/$CONFIG_NAME"
else
    echo "ПРЕДУПРЕЖДЕНИЕ: Файл $CONFIG_NAME не найден, используются значения по умолчанию"
    TARGET_DIR="$HOME/Documents/3D_Models"
    CRON_INTERVAL="*/5"
fi

# Шаг 1: Делаем скрипты исполняемыми
echo "Шаг 1: Установка прав доступа..."
chmod +x "$SCRIPT_DIR/$SCRIPT_NAME"
chmod +x "$SCRIPT_DIR/setup.sh"
if [ -f "$SCRIPT_DIR/$CONFIG_NAME" ]; then
    chmod +x "$SCRIPT_DIR/$CONFIG_NAME"
fi
echo "✓ Права доступа установлены"
echo ""

# Шаг 2: Создаем целевую папку
echo "Шаг 2: Создание целевой папки..."
mkdir -p "$TARGET_DIR"
echo "✓ Папка создана: $TARGET_DIR"
echo ""

# Шаг 3: Настройка cron
echo "Шаг 3: Настройка cron..."
echo ""

# Проверяем, есть ли уже задача в crontab
CRON_CMD="$SCRIPT_DIR/$SCRIPT_NAME"
CRON_ENTRY="$CRON_INTERVAL * * * * $CRON_CMD >> $CRON_LOG 2>&1"

if crontab -l 2>/dev/null | grep -q "$SCRIPT_NAME"; then
    echo "Найдена существующая задача cron для $SCRIPT_NAME"
    read -p "Заменить существующую задачу? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Удаляем старую задачу
        crontab -l 2>/dev/null | grep -v "$SCRIPT_NAME" | crontab -
        # Добавляем новую
        (crontab -l 2>/dev/null; echo "$CRON_ENTRY") | crontab -
        echo "✓ Задача cron обновлена"
    else
        echo "Задача cron не изменена"
    fi
else
    # Добавляем новую задачу
    (crontab -l 2>/dev/null; echo "$CRON_ENTRY") | crontab -
    echo "✓ Задача cron добавлена"
fi

echo "Расписание: каждые $CRON_INTERVAL минут"
echo "Лог файл: $CRON_LOG"
echo ""

# Шаг 4: Инструкции по правам доступа
echo "=========================================="
echo "ВАЖНО: Настройка прав доступа"
echo "=========================================="
echo ""
echo "Для работы скрипта через cron необходимо предоставить доступ:"
echo ""
echo "1. Откройте: Системные настройки → Конфиденциальность и безопасность"
echo "2. Перейдите в раздел 'Управление доступом к диску' (Full Disk Access)"
echo "3. Нажмите кнопку '+' (замок должен быть разблокирован)"
echo "4. Нажмите Cmd + Shift + G и введите: /usr/sbin/cron"
echo "5. Выберите файл 'cron' и нажмите 'Открыть'"
echo "6. Убедитесь, что переключатель включен"
echo ""
echo "БЕЗ ЭТОГО ШАГА СКРИПТ НЕ СМОЖЕТ ЧИТАТЬ ФАЙЛЫ ИЗ ЗАГРУЗОК!"
echo ""

# Шаг 5: Тестирование
echo "=========================================="
echo "Тестирование"
echo "=========================================="
echo ""
read -p "Запустить тестовый прогон скрипта сейчас? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Запуск тестового прогона..."
    bash "$SCRIPT_DIR/$SCRIPT_NAME"
    echo ""
    echo "Проверьте лог файл: $CRON_LOG"
    echo "Проверьте целевую папку: $TARGET_DIR"
fi

echo ""
echo "=========================================="
echo "Установка завершена!"
echo "=========================================="
echo ""
echo "Скрипт будет запускаться автоматически каждые $CRON_INTERVAL минут"
echo "Для просмотра логов: tail -f $CRON_LOG"
echo "Для редактирования настроек: nano $SCRIPT_DIR/$CONFIG_NAME"
echo ""

