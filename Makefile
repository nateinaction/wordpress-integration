.PHONY: test

PHP_VERSION ?= 7.2
PHP_LATEST := 7.2
SUPPORTED_VERSIONS := 7.3 7.2 7.1 7.0 5.6
PHP_DIR := PHP_$(PHP_VERSION)
DOCKERFILE := $(PHP_DIR)/Dockerfile
DOCKER_IMAGE_NAME := nateinaction/wordpress-integration
DOCKER_RUN := docker run --rm -v `pwd`:/workspace
COMPOSER_DIR := -d "/workspace/$(PHP_DIR)"

all: lint_bash build composer_install test

shell:
	$(DOCKER_RUN) -it $(DOCKER_IMAGE_NAME) "/bin/bash"

lint_bash:
	@for file in `find bin -type f -name "*.sh"`; do $(DOCKER_RUN) koalaman/shellcheck --format=gcc /workspace/$${file}; done

build:
	docker build -t $(DOCKER_IMAGE_NAME):$(PHP_DIR) -f $(DOCKERFILE) .

publish:
	if [[ "$(PHP_LATEST)" == "$(PHP_VERSION)" ]]; then docker tag $(DOCKER_IMAGE_NAME):$(PHP_DIR) $(DOCKER_IMAGE_NAME):latest; fi
	docker push $(DOCKER_IMAGE_NAME)

test:
	$(DOCKER_RUN) -it $(DOCKER_IMAGE_NAME):$(PHP_DIR) "/workspace/$(PHP_DIR)/vendor/bin/phpunit --bootstrap ./test/bootstrap.php ./test"

test_all:
	for version in $(SUPPORTED_VERSIONS); do export PHP_VERSION=$${version}; make; done

composer_install:
	$(DOCKER_RUN) composer install $(COMPOSER_DIR)

composer_update:
	$(DOCKER_RUN) composer update $(COMPOSER_DIR)
