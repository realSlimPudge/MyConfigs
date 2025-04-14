
#!/bin/bash
set -x

current_wp="$HOME/wallpapers/current_wallpaper"
blurred_wp="$HOME/wallpapers/current_wallpaper_blurred.png"
blur="50x30"

# Если файла нет, создать его
if [ ! -f "$current_wp" ]; then
    touch "$current_wp"
fi

# Получаем список обоев (полные пути) в массив
mapfile -t wallpapers < <(find "$HOME/wallpapers" -type f \( -iname '*.jpg' -o -iname '*.png' \))

# Если список пустой, выходим
if [ ${#wallpapers[@]} -eq 0 ]; then
    echo "В папке с обоями нет подходящих файлов."
    exit 1
fi

# Формируем массив с базовыми именами файлов
basenames=()
for file in "${wallpapers[@]}"; do
    basenames+=( "$(basename "$file")" )
done

# Выводим список имен через wofi (только базовые имена)
selected_name=$(printf "%s\n" "${basenames[@]}" | wofi --dmenu --prompt "Выберите обои:")

# Если ничего не выбрано, выходим
if [ -z "$selected_name" ]; then
    echo "Обои не выбраны. Выход."
    exit 1
fi

# Находим полный путь по выбранному имени
selected_wallpaper=""
for i in "${!basenames[@]}"; do
    if [[ "${basenames[$i]}" == "$selected_name" ]]; then
        selected_wallpaper="${wallpapers[$i]}"
        break
    fi
done

# Если не найдено, выходим
if [ -z "$selected_wallpaper" ]; then
    echo "Не удалось найти выбранный файл. Выход."
    exit 1
fi

# Обновляем файл с текущими обоями и устанавливаем переменную
echo "$selected_wallpaper" > "$current_wp"
current_wallpaper="$selected_wallpaper"

# Генерируем тему с помощью pywal
wal -q -i "$current_wallpaper"

# Выводим имя нового обоя (без пути, для логов)
new_wp=$(echo "$current_wallpaper" | sed "s|$HOME/wallpapers/||g")

# Обновляем конфигурацию для waybar и запускаем его
source "$HOME/.cache/wal/colors.sh"
~/.config/waybar/launch.sh

# Обновляем символическую ссылку для cava
ln -sf "$HOME/.cache/wal/cava-colors" "$HOME/.config/cava/config"

# Смена обоев через swww с анимацией перехода
transition_type="grow"
swww img "$current_wallpaper" \
    --transition-type="$transition_type" \
    --transition-pos top-right \
    --transition-fps=60 \
    --transition-step=60 \
    --transition-duration=1

# Создание заблюренной версии обоев (для wlogout)
magick "$current_wallpaper" -resize 1920x1080\! "$current_wallpaper"
echo ":: Resized"
if [ ! "$blur" == "0x0" ]; then
    magick "$current_wallpaper" -blur "$blur" "$blurred_wp"
    echo ":: Blurred"
fi
