FROM wordpress:php7.2

# Install apt dependencies
RUN apt-get update && apt-get install -qq -y --fix-missing --no-install-recommends \
    build-essential \
    git \
    less \
    libcairo2-dev \
    libgif-dev \
    libjpeg-dev \
    libyaml-dev \
    mysql-client \
    mysql-server \
    pkg-config \
    subversion \
    sudo \
    unzip \
    vim \
    wget \
    zip \
    ;

# Install xdebug
RUN pecl install xdebug && docker-php-ext-enable xdebug

# Set perms on site and bin dirs
RUN chown -R www-data:www-data /var/www/ /usr/local/bin/

# Install composer
COPY bin/install-composer.sh /tmp/
RUN /tmp/install-composer.sh

# Install phpunit via composer
RUN composer global require phpunit/phpunit:^6.5

# Env vars
ENV WORDPRESS_VERSION latest
ENV WORDPRESS_DB_NAME wordpress
ENV WORDPRESS_DB_USER wordpress
ENV WORDPRESS_DB_PASSWORD password
ENV WORDPRESS_DB_HOST 127.0.0.1
ENV WORDPRESS_TEST_HARNESS_DIR /wordpress-test-harness
ENV WORDPRESS_SVN_DIR /wordpress

# Start and configure mysql
RUN /etc/init.d/mysql start \
    && mysql -e "CREATE DATABASE ${WORDPRESS_DB_NAME};" -uroot \
    && mysql -e "GRANT ALL PRIVILEGES ON *.* TO '${WORDPRESS_DB_USER}'@'${WORDPRESS_DB_HOST}' IDENTIFIED BY '${WORDPRESS_DB_PASSWORD}';"

# Install test harness
COPY bin/install-wp-test-harness.sh /tmp/
RUN /tmp/install-wp-test-harness.sh

WORKDIR /workspace
