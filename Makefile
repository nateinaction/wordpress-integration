.PHONY: test

WORDPRESS_VERSION := 5.0.0
PHP_VERSION ?= 7.2
PHP_LATEST := 7.2
SUPPORTED_VERSIONS := 7.3 7.2 7.1 5.6
PHP_TAG := php$(PHP_VERSION)
DOCKERFILE := $(PHP_TAG)/Dockerfile
DOCKER_RUN := docker run --rm -v `pwd`:/workspace
WP_TEST_IMAGE := nateinaction/wordpress-integration
COMPOSER_IMAGE := -v ~/.composer/cache/:/tmp/cache composer
COMPOSER_DIR := -d "/workspace/$(PHP_TAG)"

all: lint_bash composer_install build_image test

shell:
	$(DOCKER_RUN) -it $(WP_TEST_IMAGE) "/bin/bash"

lint_bash:
	@for file in `find . -type f -name "*.sh"`; do $(DOCKER_RUN) koalaman/shellcheck --format=gcc /workspace/$${file}; done

composer_install:
	$(DOCKER_RUN) $(COMPOSER_IMAGE) install $(COMPOSER_DIR)

composer_update:
	$(DOCKER_RUN) $(COMPOSER_IMAGE) composer update $(COMPOSER_DIR)

composer_update_all:
	set -e; for version in $(SUPPORTED_VERSIONS); do PHP_VERSION=$${version} make composer_update; done

build_image:
	docker build -t $(WP_TEST_IMAGE):$(PHP_TAG) -f $(DOCKERFILE) .

test:
	$(DOCKER_RUN) $(WP_TEST_IMAGE):$(PHP_TAG) "./$(PHP_TAG)/vendor/bin/phpunit ./test"

test_all:
	set -e; for version in $(SUPPORTED_VERSIONS); do PHP_VERSION=$${version} make; done

publish: generate_docker_tags
	docker push $(WP_TEST_IMAGE)

generate_docker_tags:
	./build_helper/generate_docker_tags.sh $(WP_TEST_IMAGE) $(WORDPRESS_VERSION) $(PHP_VERSION) $(PHP_LATEST) $(PHP_TAG)
