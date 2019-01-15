.PHONY: test

WORDPRESS_VERSION := 5.0.3
PHP_VERSION ?= 7.2
PHP_LATEST := 7.2
SUPPORTED_VERSIONS := 7.3 7.2 7.1
PHP_TAG := php$(PHP_VERSION)
DOCKERFILE := $(PHP_TAG)/Dockerfile
DOCKER_RUN := docker run --rm -v `pwd`:/workspace
WP_TEST_IMAGE := nateinaction/wordpress-integration
COMPOSER_IMAGE := -v ~/.composer/cache/:/tmp/cache composer
COMPOSER_DIR := -d "/workspace/$(PHP_TAG)"
PYTHON_IMAGE := python:alpine

all: lint_bash build_image composer_install test

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

get_wp_version_makefile:
	@echo $(WORDPRESS_VERSION)

update_wp_version_dockerfile:
	build_helper/update_wp_version_dockerfile.py $(WORDPRESS_VERSION) $(PHP_TAG)/Dockerfile

update_wp_version_dockerfile_all:
	set -e; for version in $(SUPPORTED_VERSIONS); do PHP_VERSION=$${version} make update_wp_version_dockerfile; done

generate_docker_readme_partial:
	./build_helper/generate_docker_readme.sh $(WP_TEST_IMAGE) $(WORDPRESS_VERSION) $(PHP_VERSION) $(PHP_LATEST) $(PHP_TAG)

generate_readme: generate_docker_readme_partial
	rm -rf README.md
	echo "# Supported tags and respective `Dockerfile` links" >> README.md
	set -e; for version in $(SUPPORTED_VERSIONS); do PHP_VERSION=$${version} make generate_docker_readme_partial; done
	printf "\n" >> README.md
	cat build_helper/README.partial.md >> README.md
