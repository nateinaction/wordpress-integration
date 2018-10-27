FROM wordpress:php7.2

# Install xdebug
RUN pecl install xdebug && docker-php-ext-enable xdebug

# Install apt dependencies
RUN apt-get update && apt-get install -qq -y --fix-missing --no-install-recommends \
    git \
    mysql-client \
    mysql-server \
    subversion \
    unzip \
    zip \
    ;

# Install composer
COPY bin/install-composer.sh /tmp/
RUN /tmp/install-composer.sh

# Install phpunit via composer
RUN composer global require phpunit/phpunit:^6.5

# Env vars
ENV WORDPRESS_VERSION latest
ENV WORDPRESS_DB_NAME wordpress
ENV WORDPRESS_DB_USER wordpress
ENV WORDPRESS_DB_PASS password
ENV WORDPRESS_DB_HOST 127.0.0.1
ENV WORDPRESS_SVN_DIR /wordpress

# Start and configure mysql
RUN service mysql start \
    && mysql -e "CREATE DATABASE ${WORDPRESS_DB_NAME};" -uroot \
    && mysql -e "GRANT ALL PRIVILEGES ON *.* TO '${WORDPRESS_DB_USER}'@'${WORDPRESS_DB_HOST}' IDENTIFIED BY '${WORDPRESS_DB_PASS}';"

# Install test harness
COPY bin/install-test-harness.sh /tmp/
RUN /tmp/install-test-harness.sh

WORKDIR /workspace
