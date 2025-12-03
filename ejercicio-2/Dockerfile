# Usamos la imagen oficial base
FROM matomo:apache

# Creamos el archivo de configuración personalizado como se pedía en el Entregable 1
# PHP_MEMORY_LIMIT: 512M
# upload_max_filesize: 512M
# post_max_size: 512M
RUN echo "memory_limit = 512M" > /usr/local/etc/php/conf.d/zzz-matomo.ini \
    && echo "upload_max_filesize = 512M" >> /usr/local/etc/php/conf.d/zzz-matomo.ini \
    && echo "post_max_size = 512M" >> /usr/local/etc/php/conf.d/zzz-matomo.ini

# Exponer el puerto estándar del contenedor (Matomo usa 80 internamente en apache)
EXPOSE 80