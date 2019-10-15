FROM wordpress:php7.3

# Install apt dependencies
RUN apt-get update && apt-get install -qq -y --fix-missing --no-install-recommends \
    default-mysql-client \
    default-mysql-server \
    && rm -rf /var/lib/apt/lists/*

# Install and enable xdebug
RUN pecl install xdebug && docker-php-ext-enable xdebug

# Install test harness
RUN curl "https://codeload.github.com/WordPress/wordpress-develop/tar.gz/5.2.4" -o "/wordpress.tar.gz" \
    && mkdir /wordpress \
    && tar -xf /wordpress.tar.gz -C /wordpress --strip-components=1

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
