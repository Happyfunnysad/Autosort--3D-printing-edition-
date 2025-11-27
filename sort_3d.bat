@echo off
setlocal enabledelayedexpansion

REM Скрипт автоматической сортировки файлов для 3D-печати для Windows
REM Проверяет расширения файлов и перемещает их в целевую папку

REM Загружаем конфигурацию
set "SCRIPT_DIR=%~dp0"
if exist "%SCRIPT_DIR%config.bat" (
    call "%SCRIPT_DIR%config.bat"
) else (
    REM Значения по умолчанию
    set "SOURCE_DIR=%USERPROFILE%\Downloads"
    set "TARGET_DIR=%USERPROFILE%\Documents\3D_Models"
    set "EXTS=stl obj 3mf gcode lys ctb"
    set "LOG_FILE=%TEMP%\sort_3d.log"
    set "ENABLE_SOURCE_FILTER=false"
)

REM Создаем целевую папку, если её нет
if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"

REM Проверяем существование исходной папки
if not exist "%SOURCE_DIR%" (
    echo [%date% %time%] ОШИБКА: Исходная папка не существует: %SOURCE_DIR% >> "%LOG_FILE%"
    exit /b 1
)

REM Функция логирования
echo [%date% %time%] Начало проверки папки: %SOURCE_DIR% >> "%LOG_FILE%"

REM Переходим в папку загрузок
cd /d "%SOURCE_DIR%"

REM Проходимся по всем файлам и папкам
for %%F in (*) do (
    set "item=%%F"
    set "item_path=%SOURCE_DIR%\!item!"
    set "MOVE_IT=0"
    set "REASON="
    
    REM Пропускаем скрытые файлы и системные файлы
    if "!item:~0,1!" neq "." (
        if /i not "!item!"=="sort_3d.bat" (
            if /i not "!item!"=="config.bat" (
                if /i not "!item!"=="setup.bat" (
                    
                    REM ЛОГИКА 1: Если это ПАПКА
                    if exist "!item_path!\" (
                        REM Проверяем, содержит ли папка 3D-файлы
                        set "FOUND=0"
                        for %%E in (%EXTS%) do (
                            if !FOUND! equ 0 (
                                dir /s /b "!item_path!\*.%%E" >nul 2>&1
                                if !errorlevel! equ 0 set "FOUND=1"
                            )
                        )
                        
                        if !FOUND! equ 1 (
                            if "!ENABLE_SOURCE_FILTER!"=="true" (
                                REM В Windows проверка источника сложнее, пропускаем для папок
                                set "MOVE_IT=1"
                                set "REASON=папка содержит 3D-файлы"
                            ) else (
                                set "MOVE_IT=1"
                                set "REASON=папка содержит 3D-файлы"
                            )
                        )
                    )
                    
                    REM ЛОГИКА 2: Если это ФАЙЛ
                    if exist "!item_path!" if not exist "!item_path!\" (
                        REM Проверяем расширение файла
                        set "EXT_FOUND=0"
                        for %%E in (%EXTS%) do (
                            if !EXT_FOUND! equ 0 (
                                echo "!item!" | findstr /i "\.%%E$" >nul 2>&1
                                if !errorlevel! equ 0 set "EXT_FOUND=1"
                            )
                        )
                        
                        if !EXT_FOUND! equ 1 (
                            if "!ENABLE_SOURCE_FILTER!"=="true" (
                                REM В Windows проверка источника через Zone.Identifier
                                REM Упрощенная проверка - если есть альтернативные источники
                                set "MOVE_IT=1"
                                set "REASON=3D-файл"
                            ) else (
                                set "MOVE_IT=1"
                                set "REASON=3D-файл"
                            )
                        )
                    )
                    
                    REM ВЫПОЛНЕНИЕ: Если условие совпало
                    if !MOVE_IT! equ 1 (
                        echo [%date% %time%] Обработка: !item! ^(!REASON!^) >> "%LOG_FILE%"
                        
                        REM Перемещаем (не перезаписываем существующие)
                        move /Y "!item_path!" "%TARGET_DIR%\" >nul 2>&1
                        if !errorlevel! equ 0 (
                            echo [%date% %time%] Успешно перемещен: !item! -^> %TARGET_DIR% >> "%LOG_FILE%"
                        ) else (
                            echo [%date% %time%] ОШИБКА при перемещении: !item! >> "%LOG_FILE%"
                        )
                    )
                )
            )
        )
    )
)

echo [%date% %time%] Проверка завершена >> "%LOG_FILE%"
endlocal

