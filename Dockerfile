# Usa a imagem base do PHP com Apache
FROM php:8.1-apache

# Atualiza o sistema e instala pacotes necessários
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y wget unzip cron nano \
       libonig-dev libzip-dev libpng-dev libjpeg-dev \
       libfreetype6-dev libxml2-dev libicu-dev libxslt1-dev \
       unixodbc-dev libpq-dev rsync netcat-openbsd \
       ghostscript libaio1 libgss3 locales sassc \
       libmagickwand-dev libldap2-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Instala as extensões PHP necessárias
RUN docker-php-ext-install mysqli opcache pgsql intl sockets \
       bcmath pcntl gd zip soap ldap \
    && docker-php-ext-configure soap --enable-soap \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && pecl install igbinary uuid xmlrpc-beta imagick \
    && docker-php-ext-enable igbinary uuid imagick

# Configurações de desempenho do php.ini para o Moodle
RUN { \
        echo 'log_errors = on'; \
        echo 'display_errors = off'; \
        echo 'always_populate_raw_post_data = -1'; \
        echo 'cgi.fix_pathinfo = 1'; \
        echo 'session.auto_start = 0'; \
        echo 'upload_max_filesize = 950M'; \
        echo 'post_max_size = 950M'; \
        echo 'memory_limit = 2048M'; \
        echo 'max_execution_time = 2800'; \
        echo 'max_input_vars = 8000'; \
        echo 'max_file_uploads = 50'; \
        echo '[opcache]'; \
        echo 'opcache.enable = 1'; \  
        echo 'opcache.memory_consumption = 256'; \
        echo 'opcache.max_accelerated_files = 10000'; \
        echo 'opcache.revalidate_freq = 60'; \
        echo 'opcache.use_cwd = 1'; \
        echo 'opcache.validate_timestamps = 1'; \
        echo 'opcache.save_comments = 1'; \
        echo 'opcache.enable_file_override = 0'; \  
    } > /usr/local/etc/php/conf.d/php.ini

# Define o diretório de trabalho para o Apache
WORKDIR /var/www/html

# Faz o download do Moodle 4.4, descompacta e configura as permissões
RUN wget -q https://download.moodle.org/download.php/direct/stable404/moodle-latest-404.tgz \
    && tar -zxvf moodle-latest-404.tgz \
    && rm moodle-latest-404.tgz \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html 

# Cria o diretório de dados do Moodle e ajusta as permissões
RUN mkdir /var/www/moodledata \
    && chown -R www-data:www-data /var/www/moodledata \
    && chmod -R 770 /var/www/moodledata

# Baixar e instalar os temas Adaptable, Moove e Boost Magnific para o Moodle
RUN mkdir -p /var/www/html/course/format \
    && wget -q https://moodle.org/plugins/download.php/33115/theme_moove_moodle44_2024082400.zip \
    && wget -q https://moodle.org/plugins/download.php/33227/theme_boost_magnific_moodle44_2024092600.zip \
    && wget -q https://moodle.org/plugins/download.php/32457/theme_stream_moodle44_2024070101.zip \
    && wget -q https://moodle.org/plugins/download.php/32790/theme_almondb_moodle44_2024080800.zip \
    && unzip -q theme_moove_moodle44_2024082400.zip -d /var/www/html/moodle/theme \
    && unzip -q theme_boost_magnific_moodle44_2024092600.zip -d /var/www/html/moodle/theme \
    && unzip -q theme_stream_moodle44_2024070101.zip -d /var/www/html/moodle/theme \
    && unzip -q theme_almondb_moodle44_2024080800.zip -d /var/www/html/moodle/theme \
    && rm theme_moove_moodle44_2024082400.zip theme_boost_magnific_moodle44_2024092600.zip theme_stream_moodle44_2024070101.zip theme_almondb_moodle44_2024080800.zip \
    && chown -R www-data:www-data /var/www/html/moodle/theme \
    && chmod -R 755 /var/www/html/moodle/theme \