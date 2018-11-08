.PHONY: test

WORDPRESS_VERSION := 4.9.8
PHP_VERSION ?= 7.2
PHP_LATEST := 7.2
SUPPORTED_VERSIONS := 7.3 7.2 7.1 7.0 5.6
PHP_TAG := php$(PHP_VERSION)
DOCKERFILE := $(PHP_TAG)/Dockerfile
DOCKER_IMAGE_NAME := nateinaction/wordpress-integration
DOCKER_RUN := docker run --rm -v `pwd`:/workspace
COMPOSER_DIR := -d "/workspace/$(PHP_TAG)"

all: lint_bash build composer_install test

shell:
	$(DOCKER_RUN) -it $(DOCKER_IMAGE_NAME) "/bin/bash"

lint_bash:
	@for file in `find . -type f -name "*.sh"`; do $(DOCKER_RUN) koalaman/shellcheck --format=gcc /workspace/$${file}; done

build:
	docker build -t $(DOCKER_IMAGE_NAME):$(PHP_TAG) -f $(DOCKERFILE) .

publish: generate_docker_tags
	docker push $(DOCKER_IMAGE_NAME)

test:
	$(DOCKER_RUN) $(DOCKER_IMAGE_NAME):$(PHP_TAG) "./$(PHP_TAG)/vendor/bin/phpunit ./test"

test_all:
	for version in $(SUPPORTED_VERSIONS); do export PHP_VERSION=$${version}; make; done

generate_docker_tags:
	./build_helper/generate_docker_tags.sh $(DOCKER_IMAGE_NAME) $(WORDPRESS_VERSION) $(PHP_VERSION) $(PHP_LATEST) $(PHP_TAG)

composer_install:
	$(DOCKER_RUN) -v `pwd`/$(PHP_TAG)/cache/:/tmp/cache -v `pwd`/cache/:/root/cache/ composer install $(COMPOSER_DIR)

composer_update:
	$(DOCKER_RUN) composer update $(COMPOSER_DIR)
