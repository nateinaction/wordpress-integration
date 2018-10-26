.PHONY: test

# User editable vars
WORDPRESS_VERSION ?= latest
WORDPRESS_DB_NAME ?= wordpress
WORDPRESS_DB_USER ?= wordpress
WORDPRESS_DB_PASSWORD ?= password
WORDPRESS_DB_HOST ?= localhost
WORDPRESS_DIR ?= /tmp/wordpress
WORDPRESS_TEST_HARNESS_DIR ?= /tmp/wordpress-test-harness
BIN_DIR ?= /usr/local/bin

# Shortcuts
DOCKER_TAG := wordpress-integration
DOCKER_RUN := @docker run -it --rm -v `pwd`:/workspace
DOCKER_SHELL := $(DOCKER_RUN) $(DOCKER_TAG) "/bin/bash"
ALLOW_ROOT := --allow-root
START_MYSQL := /etc/init.d/mysql start;

# Commands
all: docker_build
	$(DOCKER_SHELL) -c "$(START_MYSQL) make install test"

shell:
	$(DOCKER_SHELL)

docker_build:
	docker build -t $(DOCKER_TAG) ./docker/

install: install_wp_cli install_wp

install_wp_cli:
	curl -o $(BIN_DIR)/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x $(BIN_DIR)/wp

install_wp: setup_wp_core setup_wp_config setup_wp_db

setup_wp_core:
	wp core download $(ALLOW_ROOT) --force --path="$(WORDPRESS_DIR)"

setup_wp_config:
	wp config create $(ALLOW_ROOT) --path="$(WORDPRESS_DIR)" --force \
		--dbname="${WORDPRESS_DB_NAME}" \
		--dbuser="${WORDPRESS_DB_USER}" \
		--dbpass="${WORDPRESS_DB_PASSWORD}" \
		--dbhost="${WORDPRESS_DB_HOST}"

setup_wp_db:
	wp db reset $(ALLOW_ROOT) --path="$(WORDPRESS_DIR)" --yes
	wp core install $(ALLOW_ROOT) --path="$(WORDPRESS_DIR)" --skip-email \
		--url="http://localhost:3000" \
		--title="Test" \
		--admin_user="test" \
		--admin_password="test" \
		--admin_email="test@test.com"

test:
	/root/.composer/vendor/bin/phpunit -c ./test/phpunit.xml --testsuite=unit-tests

