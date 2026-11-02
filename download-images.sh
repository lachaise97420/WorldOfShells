#!/bin/bash
# Download all shell preview images to local cache
CACHE_DIR="$HOME/.cache/WorldOfShells/images"
mkdir -p "$CACHE_DIR"

urls=(
    "https://raw.githubusercontent.com/dsksnkz/ghOSt/main/site/assets/product/desktop.webp"
    "https://raw.githubusercontent.com/dsksnkz/ghOSt/main/site/assets/product/switcher.webp"
    "https://raw.githubusercontent.com/dsksnkz/ghOSt/main/site/assets/product/calendar.webp"
    "https://raw.githubusercontent.com/dsksnkz/ghOSt/main/site/assets/product/settings.webp"
    "https://raw.githubusercontent.com/dsksnkz/ghOSt/main/site/assets/product/launcher.webp"
    "https://raw.githubusercontent.com/dsksnkz/ghOSt/main/site/assets/product/media.webp"
    "https://raw.githubusercontent.com/dsksnkz/ghOSt/main/site/assets/product/sidebar.webp"
    "https://raw.githubusercontent.com/dsksnkz/ghOSt/main/site/assets/product/login.webp"
    "https://github.com/user-attachments/assets/bc67b3fa-33a6-4326-9752-f0d271d0ed22"
    "https://github.com/user-attachments/assets/600f75bc-b4d1-442d-bec5-41ee7dfa5023"
    "https://github.com/user-attachments/assets/edf45f8f-b71a-4bc5-9880-46dafbebf47c"
    "https://github.com/user-attachments/assets/cb6c5708-5786-4328-89bd-24737d39e482"
    "https://github.com/user-attachments/assets/6ef28e50-612f-4e7b-9822-c0aa0168a6ae"
    "https://github.com/user-attachments/assets/203a9678-c3b7-4720-bb97-853a511ac5c8"
    "https://github.com/user-attachments/assets/732c30de-5f4a-4a2b-a995-c8ab656cecd5"
    "https://github.com/user-attachments/assets/a937cf35-a43b-4558-8c39-5694ff5fcac4"
    "https://github.com/user-attachments/assets/2da00ea1-8921-4473-a2a9-44a44535a822"
    "https://github.com/user-attachments/assets/5d4e7d07-d0b4-4406-a4c9-ed7ba90e3fe4"
    "https://github.com/user-attachments/assets/6a32395f-9437-4192-8faf-2951a9e84cbe"
    "https://github.com/user-attachments/assets/c51bed8b-3670-4d4c-9074-873be224fb8e"
    "https://github.com/user-attachments/assets/98703a66-0743-439f-a721-cef7afa6ab95"
    "https://raw.githubusercontent.com/na-ive/nandoroid-docs/refs/heads/main/public/showcase1.png"
    "https://raw.githubusercontent.com/na-ive/nandoroid-docs/refs/heads/main/public/showcase2.png"
    "https://raw.githubusercontent.com/na-ive/nandoroid-docs/refs/heads/main/public/showcase3.png"
    "https://raw.githubusercontent.com/na-ive/nandoroid-docs/refs/heads/main/public/showcase4.png"
    "https://raw.githubusercontent.com/Blapples/SekaiPop/main/assets/shot-desktop-widgets.png"
    "https://raw.githubusercontent.com/Blapples/SekaiPop/main/assets/shot-edit-desktop.png"
    "https://raw.githubusercontent.com/Blapples/SekaiPop/main/assets/shot-quick-panel-phone.png"
    "https://raw.githubusercontent.com/Blapples/SekaiPop/main/assets/shot-sekai-pad-eq.png"
)

for url in "${urls[@]}"; do
    hash=$(echo "$url" | md5sum | cut -d' ' -f1)
    ext="${url##*.}"
    ext="${ext%%\?*}"
    [ "$ext" = "png" ] || [ "$ext" = "jpg" ] || [ "$ext" = "jpeg" ] || [ "$ext" = "svg" ] || ext="png"
    filepath="$CACHE_DIR/${hash}.${ext}"
    if [ ! -f "$filepath" ]; then
        curl -sL "$url" -o "$filepath" 2>/dev/null
    fi
done
echo "done"