FROM debian:latest

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
    gnupg \
    curl wget vim openssh-server software-properties-common netcat apachetop htop && \
    apt-get update && \
    apt-get install --no-install-recommends -y build-essential apt-transport-https lsb-release ca-certificates -y && \
    rm -rf /var/lib/apt/lists/*

#PHP Setup
RUN wget -q -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list && \
apt update && \
apt install apache2 php7.4 libapache2-mod-php php7.4-cli php7.4-fpm php7.4-json php7.4-common php7.4-mysql php7.4-zip php7.4-gd php7.4-intl php7.4-mbstring php7.4-curl php7.4-xml php7.4-tidy php7.4-soap php7.4-bcmath php7.4-xmlrpc default-mysql-client --no-install-recommends -y 

#Drupal Setup
RUN wget -q https://www.drupal.org/download-latest/tar.gz -O drupal.tar.gz && \
tar -xvf drupal.tar.gz && \
mv drupal-* /var/www/html/drupal

#change ownership and permissions
RUN chown -R www-data:www-data /var/www/html/drupal/ && \
chmod -R 755 /var/www/html/drupal/

#apache configurations
COPY apache2-app.conf /etc/apache2/sites-enabled/000-default.conf

#drupal configurations
RUN mkdir -p /var/www/html/sites/default/ && \
cp /var/www/html/drupal/sites/default/default.settings.php /var/www/html/drupal/sites/default/settings.php && \
chmod 664 /var/www/html/drupal/sites/default/settings.php && \
a2enmod rewrite && \
chown -R :www-data /var/www/html/drupal/* 

#Codebase
COPY docroot/ /var/www/html/drupal

CMD /usr/sbin/apache2ctl -D FOREGROUND
