#!/bin/bash
set -e

# Имя выходного файла CSV
output_file="kdbx_secrets.csv"

# Получаем текущую дату в формате YYYY-MM-DD
current_date=$(date +'%Y-%m-%d')

# Функция для корректного экранирования значений для CSV:
# Заменяет все двойные кавычки на две двойные кавычки и оборачивает значение в кавычки.
csv_escape() {
  local s="$1"
  s="${s//\"/\"\"}"
  printf '"%s"' "$s"
}

# Записываем заголовок CSV в выходной файл.
echo '"Group","Title","Username","Password","URL","Notes","TOTP","Icon","Last Modified","Created"' > "$output_file"

# Ищем все файлы с именем, начинающимся на "age." и заканчивающимся на ".yaml"
find . -type f -name 'age.*.yaml' | while IFS= read -r file; do
  # В поле Group теперь выводим "argocd" с добавлением текущей даты.
  group="argocd ${current_date}"
  title="$file"
  username=""
  password=""
  url=""
  # Считываем содержимое файла — оставляем настоящие переводы строк.
  notes=$(cat "$file")
  totp=""
  icon=""
  last_modified=""
  created=""

  # Формируем строку CSV: каждое поле корректно экранируется.
  printf "%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n" \
    "$(csv_escape "$group")" \
    "$(csv_escape "$title")" \
    "$(csv_escape "$username")" \
    "$(csv_escape "$password")" \
    "$(csv_escape "$url")" \
    "$(csv_escape "$notes")" \
    "$(csv_escape "$totp")" \
    "$(csv_escape "$icon")" \
    "$(csv_escape "$last_modified")" \
    "$(csv_escape "$created")"
done >> "$output_file"

echo "CSV успешно записан в файл $output_file"