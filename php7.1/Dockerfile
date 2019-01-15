FROM php:7.1

# Install apt dependencies
RUN apt-get update && apt-get install -qq -y --fix-missing --no-install-recommends \
    mysql-client \
    mysql-server \
    && rm -rf /var/lib/apt/lists/*

# Install and enable xdebug
RUN pecl install xdebug && docker-php-ext-enable xdebug

# Install mysqli
RUN docker-php-ext-install mysqli

# Install test harness
RUN curl "https://codeload.github.com/WordPress/wordpress-develop/tar.gz/5.0.3" -o "/wordpress.tar.gz"; \
    mkdir /wordpress; \
    tar -xf /wordpress.tar.gz -C /wordpress --strip-components=1

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

