FROM php:7-apache

RUN apt-get update && apt-get install -y \
    git \
    zip \
    wget \
    xvfb \
    libfontconfig1 \
    fontconfig \
    libjpeg62-turbo \
    libxrender1 \
    libicu52 \
    libicu-dev \
    xfonts-75dpi \
    zlib1g-dev

RUN docker-php-ext-install pdo_mysql zip intl
RUN docker-php-ext-configure pdo_mysql
RUN docker-php-ext-enable pdo_mysql zip intl

RUN pecl install xdebug \
    && echo "zend_extension=xdebug.so" >> "/usr/local/etc/php/conf.d/xdebug.ini"

RUN php -r "copy('https://getcomposer.org/installer', '/tmp/composer-setup.php');"
RUN php -r "if (hash_file('SHA384', '/tmp/composer-setup.php') === 'aa96f26c2b67226a324c27919f1eb05f21c248b987e6195cad9690d5c1ff713d53020a02ac8c217dbf90a7eacc9d141d') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('/tmp/composer-setup.php'); } echo PHP_EOL;"
RUN php /tmp/composer-setup.php --install-dir=/bin
RUN php -r "unlink('/tmp/composer-setup.php');"

RUN curl -LsS https://symfony.com/installer -o /bin/symfony
RUN chmod a+x /bin/symfony

# configure xhtmltopdf
RUN wget http://download.gna.org/wkhtmltopdf/0.12/0.12.2.1/wkhtmltox-0.12.2.1_linux-jessie-amd64.deb -O /tmp/wkhtmltox.deb
RUN dpkg -i /tmp/wkhtmltox.deb

# Configure Apache
RUN groupadd meymard
RUN useradd -m -g meymard meymard

ENV APACHE_RUN_USER meymard
ENV APACHE_RUN_GROUP meymard

RUN echo 'date.timezone = "Europe/Paris"' > /usr/local/etc/php/conf.d/timezone.ini

RUN { \
            echo '<VirtualHost *:80>'; \
            echo '    ServerAdmin local@admin.fr'; \
            echo '    DocumentRoot /devis-factures/web'; \
            echo '    <Directory "/devis-factures/web">'; \
            echo '        Options -Indexes'; \
            echo '        AllowOverride All'; \
            echo '        Require all granted'; \
            echo '    </Directory>'; \
            echo '    ErrorLog  "/var/log/apache2/devisfactures_error_log"'; \
            echo '    CustomLog "/var/log/apache2/devisfactures_access_log" combined'; \
            echo '</VirtualHost>'; \
    } | tee "$APACHE_CONFDIR/conf-available/devisfactures.conf" \
    && a2enconf devisfactures

# Install phpcs
RUN mkdir /phpcs
RUN cd /phpcs
RUN curl -o /phpcs/phpcs.phar -L https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar
RUN chmod +x /phpcs/phpcs.phar
RUN git clone git://github.com/escapestudios/Symfony2-coding-standard.git /phpcs/Symfony2-coding-standard
RUN /phpcs/phpcs.phar --config-set installed_paths /phpcs/Symfony2-coding-standard
RUN ln -s /phpcs/phpcs.phar /bin/phpcs
RUN curl -L https://github.com/FriendsOfPHP/PHP-CS-Fixer/releases/download/v2.0.0/php-cs-fixer.phar -o /bin/php-cs-fixer
RUN chmod +x /bin/php-cs-fixer

RUN mkdir /devis-factures

WORKDIR /devis-factures
