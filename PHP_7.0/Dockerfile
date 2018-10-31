FROM php:7.0

# Install apt dependencies
RUN apt-get update && apt-get install -qq -y --fix-missing --no-install-recommends \
	libmemcached-dev \
	libz-dev \
    mysql-client \
    mysql-server \
    subversion \
    ;

# Install pecl dependencies
RUN pecl install memcached xdebug

# Install PHP extensions
RUN docker-php-ext-install mysqli

# Enable PHP extensions
RUN docker-php-ext-enable memcached xdebug

# Env vars
ENV WORDPRESS_VERSION 4.9.8
ENV WORDPRESS_DB_NAME wordpress
ENV WORDPRESS_DB_USER wordpress
ENV WORDPRESS_DB_PASS password
ENV WORDPRESS_DB_HOST 127.0.0.1
ENV WORDPRESS_SVN_DIR /wordpress

# Install test harness
COPY bin/install-test-harness.sh /usr/local/bin/
RUN install-test-harness.sh

# Setup entrypoint
COPY ./bin/entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

WORKDIR /workspace
