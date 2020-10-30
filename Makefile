PHP_LATEST := 7.4
PHP_VERSIONS := 7.4 7.3 7.2 7.1
PHP_TAG = php$*
WORDPRESS_VERSION := 5.5.2
DOCKER_RUN := docker run --rm -v `pwd`:/workspace -w /workspace
IMAGE_NAME := worldpeaceio/wordpress-integration
COMPOSER_IMAGE := -v ~/.composer/cache/:/tmp/cache composer
PYTHON_IMAGE := python:alpine

build: README.md

.PHONY: clean
clean:
	rm -rf build
	rm README.md

.PHONY: setup
setup:
	rm -rf .git/hooks
	cd .git && ln -s ../git_hooks/ hooks

vendor:
	$(DOCKER_RUN) $(COMPOSER_IMAGE) install

build/php%.md: vendor
	mkdir -p build
	@# Default tag will be php7.2
	docker build -t $(IMAGE_NAME):$(PHP_TAG) --build-arg "PHP_MAJOR_VERSION=$*" .
	@# WP major minor patch tag e.g. php7.2-wp5.0.3
	docker tag $(IMAGE_NAME):$(PHP_TAG) $(IMAGE_NAME):$(PHP_TAG)-wp$(WORDPRESS_VERSION)
	@# WP major minor tag e.g. php7.2-wp5.0
	docker tag $(IMAGE_NAME):$(PHP_TAG) $(IMAGE_NAME):$(PHP_TAG)-wp$(shell make get_wp_version_makefile_major_minor_only)
	@# Test the image
	$(DOCKER_RUN) $(IMAGE_NAME):$(PHP_TAG) "./vendor/bin/phpunit ./test"
	@# Write the the README markdown for these tags
	./build_helper/generate_docker_readme.sh $(WORDPRESS_VERSION) $* $(PHP_LATEST) $(PHP_TAG) > build/$(PHP_TAG).md

README.md: $(addprefix build/php, $(addsuffix .md, $(PHP_VERSIONS)))
	echo "# Supported tags and respective \`Dockerfile\` links" > README.md
	ls -rd $(shell pwd)/build/* | xargs cat >> README.md
	printf "\n" >> README.md
	cat build_helper/README.footer.md >> README.md

.PHONY: shell-%
shell-%:
	$(DOCKER_RUN) -it $(IMAGE_NAME):$(PHP_TAG) "/bin/bash"

### Used by git pre commit hooks ###

.PHONY: lint
lint:
	@for file in `find . -type f -name "*.sh"`; do $(DOCKER_RUN) koalaman/shellcheck --format=gcc /workspace/$${file}; done

.PHONY: test_helpers
test_helpers:
	$(DOCKER_RUN) $(PYTHON_IMAGE) python -m unittest test/build_helper/test_update_wp_version.py

### Composer shortcut ###

.PHONY: composer_update
composer_update:
	$(DOCKER_RUN) $(COMPOSER_IMAGE) composer update

### Used by CI ###

.PHONY: get_wp_version_makefile
get_wp_version_makefile:
	@echo $(WORDPRESS_VERSION)

.PHONY: get_wp_version_makefile_major_minor_only
get_wp_version_makefile_major_minor_only:
	@echo $(WORDPRESS_VERSION) | sed s/\..$$//

.PHONY: update_wp_version_makefile
update_wp_version_makefile:
ifdef version
	build_helper/update_wp_version.py $(version) Makefile
endif

.PHONY: update_wp_version_dockerfile
update_wp_version_dockerfile:
	build_helper/update_wp_version.py $(WORDPRESS_VERSION) Dockerfile

.PHONY: publish
publish:
	docker push $(IMAGE_NAME)
