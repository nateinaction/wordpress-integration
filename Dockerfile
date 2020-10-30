ARG PHP_MAJOR_VERSION=7.4
FROM wordpress:php${PHP_MAJOR_VERSION}
ARG PHP_MAJOR_VERSION

# Install apt dependencies
RUN set -ex; \
    apt-get update && apt-get install -qq -y --fix-missing --no-install-recommends \
        default-mysql-client \
        default-mysql-server; \
    apt-get clean; \
    rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* /srv/provision/;

# Install and enable xdebug
RUN set -ex; \
    if [ "${PHP_MAJOR_VERSION}" = "7.1" ]; then \
        pecl install xdebug-2.9.8; \
    elif [ "${PHP_MAJOR_VERSION}" = "7.0" ]; then \
        pecl install xdebug-2.6.1; \
    elif [ "${PHP_MAJOR_VERSION}" = "5.6" ]; then \
        pecl install xdebug-2.5.5; \
    else \
        pecl install xdebug; \
    fi; \
    docker-php-ext-enable xdebug;

# Install test harness
ARG WORDPRESS_VERSION=5.5.2
RUN set -ex; \
    curl "https://codeload.github.com/WordPress/wordpress-develop/tar.gz/${WORDPRESS_VERSION}" -o "/wordpress.tar.gz"; \
    mkdir /wordpress; \
    tar -xf /wordpress.tar.gz -C /wordpress --strip-components=1; \
    rm /wordpress.tar.gz;

# Env vars
ENV WORDPRESS_DB_NAME wordpress
ENV WORDPRESS_DB_USER wordpress
ENV WORDPRESS_DB_PASS password
ENV WORDPRESS_DB_HOST 127.0.0.1

# Configure test harness
COPY ./bin/configure-test-harness.sh /usr/local/bin/
RUN configure-test-harness.sh

# Setup entrypoint
COPY ./bin/entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

WORKDIR /workspace
