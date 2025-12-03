# Usamos la imagen oficial base
FROM matomo:apache


RUN echo "memory_limit = 512M" > /usr/local/etc/php/conf.d/zzz-matomo.ini \
    && echo "upload_max_filesize = 512M" >> /usr/local/etc/php/conf.d/zzz-matomo.ini \
    && echo "post_max_size = 512M" >> /usr/local/etc/php/conf.d/zzz-matomo.ini

EXPOSE 80