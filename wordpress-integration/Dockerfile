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
COPY ./bin/install-composer.sh /usr/local/bin/
RUN install-composer.sh

# Install phpunit
COPY ./composer/composer.json ./composer/composer.lock /composer/
RUN composer install -d /composer

# Env vars
ENV WORDPRESS_VERSION latest
ENV WORDPRESS_DB_NAME wordpress
ENV WORDPRESS_DB_USER wordpress
ENV WORDPRESS_DB_PASS password
ENV WORDPRESS_DB_HOST 127.0.0.1
ENV WORDPRESS_SVN_DIR /wordpress

# Install test harness
COPY bin/install-test-harness.sh /usr/local/bin/
RUN install-test-harness.sh

WORKDIR /workspace

# Setup entrypoint
COPY ./bin/entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
