
#!/bin/bash
set -x

current_wp="$HOME/wallpapers/current_wallpaper"
blurred_wp="$HOME/wallpapers/current_wallpaper_blurred.png"
blur="50x30"

# Если файла нет, создать его
if [ ! -f "$current_wp" ]; then
    touch "$current_wp"
fi

# Если в файле уже есть путь, сохранить его как текущий обой (чтобы его исключить)
if [ -s "$current_wp" ]; then
    old_current_wallpaper=$(cat "$current_wp")
fi

# Выбрать новый рандомный обой, исключая старый обой и заблюренную версию
random_wallpaper=$(find "$HOME/wallpapers/" -type f \( -iname '*.png' -o -iname '*.jpg' \) \
    ! -path "$old_current_wallpaper" ! -path "$blurred_wp" | shuf -n1)

# Если случайный обой не найден (например, в папке только старый и заблюренный), использовать старый
if [ -z "$random_wallpaper" ]; then
    random_wallpaper="$old_current_wallpaper"
fi

# Обновить файл с текущим обоем
echo "$random_wallpaper" > "$current_wp"
current_wallpaper="$random_wallpaper"

# Применить обой через wal (опционально, если нужен для генерации цветовой схемы)
wal -q -i "$current_wallpaper"

# Вывести имя нового обоя (без пути)
new_wp=$(echo "$current_wallpaper" | sed "s|$HOME/wallpapers/||g")

source "$HOME/.cache/wal/colors.sh"
~/.config/waybar/launch.sh

# Обновление символической ссылки для cava
ln -sf "$HOME/.cache/wal/cava-colors" "$HOME/.config/cava/config"

# Смена обоев через swww
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
if [ ! "$blur" == "0x0" ] ; then
    magick "$current_wallpaper" -blur "$blur" "$blurred_wp"
    echo ":: Blurred"
fi
