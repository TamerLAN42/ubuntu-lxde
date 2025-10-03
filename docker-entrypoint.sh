#!/usr/bin/env bash
set -e

# Если задан VNC_PASSWORD - создаём файл пароля для x11vnc.
if [ -n "${VNC_PASSWORD}" ]; then
  mkdir -p /root/.vnc
  x11vnc -storepasswd "${VNC_PASSWORD}" /root/.vnc/passwd 2>/dev/null
  chmod 600 /root/.vnc/passwd
fi

# Создаём ярлыки на рабочем столе
mkdir -p /root/Desktop
mkdir -p /usr/share/applications
# Browser/Firefox
cat > /usr/share/applications/firefox.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Firefox
Comment=Browse the Web
Exec=/opt/firefox/firefox
Icon=/opt/firefox/browser/chrome/icons/default/default128.png
Terminal=false
StartupNotify=true
Categories=Network;WebBrowser;
EOF

cat > /root/Desktop/firefox.desktop << 'EOF'
[Desktop Entry]
Type=Link
Name=Firefox
Icon=/opt/firefox/browser/chrome/icons/default/default128.png
URL=/usr/share/applications/firefox.desktop
EOF

# Filemanager/pcmanfm
cat > /root/Desktop/pcmanfm.desktop << 'EOF'
[Desktop Entry]
Type=Link
Name=File Manager
Icon=system-file-manager
URL=/usr/share/applications/pcmanfm.desktop
EOF

# Terminal
cat > /root/Desktop/terminal.desktop << 'EOF'
[Desktop Entry]
Type=Link
Name=LXTerminal
Icon=lxterminal
URL=/usr/share/applications/lxterminal.desktop
EOF


# Запускаем supervisord (CMD аргументы передаются через exec "$@")
exec "$@"
