FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    DISPLAY=:0 \
    VNC_PORT=5900

WORKDIR /root

# Базовое окружение для работы системы(supervisord для управления сервисами + VNC/NoVNC). Ну и ещё всякого по мелочи
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      lxde-core lxterminal \
      x11vnc xvfb xauth dbus-x11 novnc websockify python3 \
      supervisor \
      sudo wget curl ca-certificates \
      nano net-tools \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Подбиваем окружение под нужды (Раньше тут было много всего, а потом я уверовал в легковесность)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      xz-utils && \
    wget -O /tmp/firefox.tar.xz "https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US" && \
    tar -xf /tmp/firefox.tar.xz -C /opt/ && \
    ln -sf /opt/firefox/firefox /usr/local/bin/firefox && \
    rm /tmp/firefox.tar.xz && \
    apt-get purge -y xz-utils && \
    apt-get install -f -y && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Критичные конфиги для демонов + entrypoint
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY supervisord.d/ /etc/supervisor/conf.d/
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Переносим QoL файлы
COPY wallpaper.jpg /etc/alternatives/desktop-background
COPY desktop.conf /root/.config/lxsession/LXDE/desktop.conf
COPY panel /root/.config/lxpanel/LXDE/panels/panel

# Создаём HTML-страницу для редиректа с index.html на vnc.html(Фикс NoVNC)
RUN echo '<html><head><meta http-equiv="refresh" content="0; url=/vnc.html"></head><body>Redirecting...</body></html>' > /usr/share/novnc/index.html

# WARNING! К папкам на хосте не монтировать, только named volumes
# Иначе всё перезапишется, сломается, будете грустить, а оно вам надо?
VOLUME /root

EXPOSE 5900

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
