#!/bin/bash
set -e

###################
# Конфигурация
###################

# Цветовые коды для вывода
declare -r RED='\033[0;31m'
declare -r GREEN='\033[0;32m'
declare -r YELLOW='\033[0;33m'
declare -r NC='\033[0m'

###################
# Вспомогательные функции
###################

# Выводит сообщение об ошибке и завершает работу
error_exit() {
    echo -e "${RED}Ошибка: $1${NC}" >&2
    exit 1
}

# Выводит информационное сообщение
info_message() {
    echo -e "${GREEN}$1${NC}"
}

# Выводит предупреждение
warning_message() {
    echo -e "${YELLOW}$1${NC}"
}

# Проверяет успешность дешифрования/шифрования
check_operation_result() {
    local target_file=$1
    if [ ! -s "$target_file" ]; then
        error_exit "Файл $target_file пуст после операции."
    fi
}

# Проверяет наличие файла ключа
validate_key_file() {
    local key_file=$1
    if [ -z "$key_file" ]; then
        error_exit "Укажите путь к файлу ключа через флаг -k."
    fi
    if [ ! -f "$key_file" ]; then
        error_exit "Файл ключа ($key_file) не найден."
    fi
}

###################
# Основные функции
###################

# Шифрование файлов в выбранной директории
encrypt_files() {
    local dir=$1
    info_message "Начинаю процесс шифрования (файлы age.*.yaml -> enc.*.yaml)..."
    
    local files=("$dir"/age.*.yaml)
    if [ ${#files[@]} -eq 0 ]; then
        warning_message "Файлы с префиксом age. не найдены в $dir."
        return 1
    fi

    for src in "${files[@]}"; do
        local base=$(basename "$src")
        local target="$dir/enc.${base#age.}"
        info_message "Шифруем $src -> $target"
        sops --encrypt "$src" > "$target"
        check_operation_result "$target"
    done
}

# Дешифрование файлов в выбранной директории
decrypt_files() {
    local dir=$1
    info_message "Начинаю процесс дешифрования (файлы enc.*.yaml -> age.*.yaml)..."
    
    local files=("$dir"/enc.*.yaml)
    if [ ${#files[@]} -eq 0 ]; then
        warning_message "Файлы с префиксом enc. не найдены в $dir."
        return 1
    fi

    for src in "${files[@]}"; do
        local base=$(basename "$src")
        local target="$dir/age.${base#enc.}"
        info_message "Дешифруем $src -> $target"
        sops --decrypt "$src" > "$target"
        check_operation_result "$target"
    done
}

# Дешифрование всех найденных файлов
decrypt_all_files() {
    info_message "Начинаю процесс дешифрования всех найденных файлов..."
    
    while IFS= read -r -d '' src; do
        local dir=$(dirname "$src")
        local base=$(basename "$src")
        local target="$dir/age.${base#enc.}"
        info_message "Дешифруем $src -> $target"
        sops --decrypt "$src" > "$target"
        check_operation_result "$target"
    done < <(find . -type f -name "enc.*.yaml" -print0)
}

# Выбор директории с помощью fzf
select_directory() {
    local directories=$1
    local selected=$(echo "$directories" | fzf --prompt="Выберите директорию с файлами enc.*.yaml/age.*.yaml: ")
    if [ -z "$selected" ]; then
        warning_message "Директория не выбрана. Выходим."
        exit 1
    fi
    echo "$selected"
}

###################
# Основной скрипт
###################

main() {
    # Обработка аргументов командной строки
    while getopts "k:" opt; do
        case "$opt" in
            k) KEY_FILE="$OPTARG" ;;
            *) error_exit "Использование: $0 -k путь_к_файлу_ключа" ;;
        esac
    done
    shift $((OPTIND - 1))

    # Проверка файла ключа
    validate_key_file "$KEY_FILE"
    export SOPS_AGE_KEY_FILE="$KEY_FILE"
    info_message "Используется ключ: $SOPS_AGE_KEY_FILE"

    # Поиск директорий с файлами
    local directories=$(find . -type f \( -name "enc.*.yaml" -o -name "age.*.yaml" \) -exec dirname {} \; | sort -u)
    if [ -z "$directories" ]; then
        error_exit "Не найдено директорий с файлами enc.*.yaml или age.*.yaml."
    fi

    # Вывод меню и получение выбора пользователя
    echo -e "${GREEN}Доступные команды:${NC}"
    echo "e - encrypt (шифровать файлы в выбранной директории)"
    echo "d - decrypt (дешифровать файлы в выбранной директории)"
    echo "a - decrypt all (дешифровать все найденные файлы)"
    read -p "Введите команду (e/d/a): " ACTION

    # Включаем nullglob для корректной работы с файлами
    shopt -s nullglob

    # Обработка выбранного действия
    case "$ACTION" in
        e)
            local selected_dir=$(select_directory "$directories")
            info_message "Вы выбрали: $selected_dir"
            encrypt_files "$selected_dir"
            ;;
        d)
            local selected_dir=$(select_directory "$directories")
            info_message "Вы выбрали: $selected_dir"
            decrypt_files "$selected_dir"
            ;;
        a)
            decrypt_all_files
            ;;
        *)
            error_exit "Неверное действие. Используйте 'e' для шифрования, 'd' для дешифрования или 'a' для дешифрования всех файлов."
            ;;
    esac

    info_message "Операция $ACTION успешно завершена."
}

# Запуск скрипта
main "$@"