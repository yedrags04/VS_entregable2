FROM matomo:apache

# Crear fichero de configuración personalizado PHP
# Ruta indicada: /usr/local/etc/php/conf.d/zzz-matomo.ini
RUN echo "memory_limit = 512M" > /usr/local/etc/php/conf.d/zzz-matomo.ini \
    && echo "upload_max_filesize = 512M" >> /usr/local/etc/php/conf.d/zzz-matomo.ini \
    && echo "post_max_size = 512M" >> /usr/local/etc/php/conf.d/zzz-matomo.ini

# Nota: El puerto 81 se configurará en Kubernetes, no es necesario EXPOSE aquí
# ya que la imagen base usa apache en el 80 internamente, pero haremos el mapeo luego.