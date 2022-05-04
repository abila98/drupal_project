FROM debian:latest

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
    gnupg \
    curl wget vim openssh-server software-properties-common netcat apachetop htop
RUN apt-get install --no-install-recommends -y build-essential apt-transport-https lsb-release ca-certificates -y

#PHP Setup
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
RUN apt-get install apache2 php7.4 libapache2-mod-php php7.4-cli php7.4-fpm php7.4-json php7.4-common php7.4-mysql php7.4-zip php7.4-gd php7.4-intl php7.4-mbstring php7.4-curl php7.4-xml php7.4-tidy php7.4-soap php7.4-bcmath php7.4-xmlrpc default-mysql-client -y 

#Drupal Setup
RUN wget https://www.drupal.org/download-latest/tar.gz -O drupal.tar.gz
RUN tar -xvf drupal.tar.gz
RUN mv drupal-* /var/www/html/drupal

#change ownership and permissions
RUN chown -R www-data:www-data /var/www/html/drupal/
RUN chmod -R 755 /var/www/html/drupal/

#apache configurations
COPY apache2-app.conf /etc/apache2/sites-enabled/000-default.conf

#drupal configurations
RUN mkdir -p /var/www/html/sites/default/
RUN cp /var/www/html/drupal/sites/default/default.settings.php /var/www/html/drupal/sites/default/settings.php
RUN chmod 664 /var/www/html/drupal/sites/default/settings.php
RUN a2enmod rewrite
RUN chown -R :www-data /var/www/html/drupal/*
RUN chmod 644 /var/www/html/drupal/sites/default/settings.php
#Codebase
COPY docroot/ /var/www/html/drupal

CMD /usr/sbin/apache2ctl -D FOREGROUND