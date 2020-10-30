.PHONY: test

PHP_LATEST := 7.4
PHP_VERSION ?= $(PHP_LATEST)
SUPPORTED_PHP_VERSIONS := 7.4 7.3 7.2
PHP_TAG := php$(PHP_VERSION)
WORDPRESS_VERSION := 5.5.2
DOCKER_RUN := docker run --rm -v `pwd`:/workspace -w /workspace
WP_TEST_IMAGE := worldpeaceio/wordpress-integration
COMPOSER_IMAGE := -v ~/.composer/cache/:/tmp/cache composer
PYTHON_IMAGE := python:alpine

all: composer_install lint_bash build_image test

shell:
	$(DOCKER_RUN) -it $(WP_TEST_IMAGE) "/bin/bash"

lint: lint_bash

lint_bash:
	@for file in `find . -type f -name "*.sh"`; do $(DOCKER_RUN) koalaman/shellcheck --format=gcc /workspace/$${file}; done

composer_install:
	$(DOCKER_RUN) $(COMPOSER_IMAGE) install

composer_update:
	$(DOCKER_RUN) $(COMPOSER_IMAGE) composer update

build_image:
	@# Default tag will be php7.2
	docker build -t $(WP_TEST_IMAGE):$(PHP_TAG) --build-arg $(PHP_VERSION) .
	@# WP major minor patch tag e.g. php7.2-wp5.0.3
	docker tag $(WP_TEST_IMAGE):$(PHP_TAG) $(WP_TEST_IMAGE):$(PHP_TAG)-wp$(WORDPRESS_VERSION)
	@# WP major minor tag e.g. php7.2-wp5.0
	docker tag $(WP_TEST_IMAGE):$(PHP_TAG) $(WP_TEST_IMAGE):$(PHP_TAG)-wp$(shell make get_wp_version_makefile_major_minor_only)

test: test_image test_helpers

test_image:
	$(DOCKER_RUN) $(WP_TEST_IMAGE):$(PHP_TAG) "./vendor/bin/phpunit ./test"

test_helpers:
	$(DOCKER_RUN) $(PYTHON_IMAGE) python -m unittest test/build_helper/test_update_wp_version.py

test_all_images:
	set -e; for version in $(SUPPORTED_PHP_VERSIONS); do PHP_VERSION=$${version} make build_image test_image; done

get_wp_version_makefile:
	@echo $(WORDPRESS_VERSION)

get_wp_version_makefile_major_minor_only:
	@echo $(WORDPRESS_VERSION) | sed s/\..$$//

update_wp_version_makefile:
ifdef version
	build_helper/update_wp_version.py $(version) Makefile
endif

update_wp_version_dockerfile:
	build_helper/update_wp_version.py $(WORDPRESS_VERSION) Dockerfile

publish:
	docker push $(WP_TEST_IMAGE)

generate_docker_readme_partial:
	./build_helper/generate_docker_readme.sh $(WP_TEST_IMAGE) $(WORDPRESS_VERSION) $(PHP_VERSION) $(PHP_LATEST) $(PHP_TAG)

generate_readme: generate_docker_readme_partial
	rm -rf README.md
	echo "# Supported tags and respective \`Dockerfile\` links" > README.md
	set -e; for version in $(SUPPORTED_PHP_VERSIONS); do PHP_VERSION=$${version} make generate_docker_readme_partial; done
	printf "\n" >> README.md
	cat build_helper/README.partial.md >> README.md
