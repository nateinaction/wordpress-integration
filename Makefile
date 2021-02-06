PHP_LATEST := 8.0
PHP_VERSIONS := 8.0 7.4 7.3 7.2 7.1
PHP_TAG = php$*
WORDPRESS_LATEST = $(shell cat wordpress_version.txt)
WORDPRESS_LATEST_ONLY_MAJOR = $(shell echo $(WORDPRESS_LATEST) | sed s/\..$$//)
DOCKER_RUN := docker run --rm -v `pwd`:/workspace -w /workspace
IMAGE_NAME := worldpeaceio/wordpress-integration
COMPOSER_IMAGE := -v ~/.composer/cache/:/tmp/cache composer
PYTHON_IMAGE := python:alpine

build: README.md

.PHONY: clean
clean:
	rm -rf build
	rm -rf vendor
	rm README.md

vendor:
	$(DOCKER_RUN) $(COMPOSER_IMAGE) install

build/php%.md: vendor
	mkdir -p build
	@# Default tag will be php7.2
	docker build -t $(IMAGE_NAME):$(PHP_TAG) --build-arg "PHP_MAJOR_VERSION=$*" .
	@# WP major minor patch tag e.g. php7.2-wp5.0.3
	docker tag $(IMAGE_NAME):$(PHP_TAG) $(IMAGE_NAME):$(PHP_TAG)-wp$(WORDPRESS_LATEST)
	@# WP major minor tag e.g. php7.2-wp5.0
	docker tag $(IMAGE_NAME):$(PHP_TAG) $(IMAGE_NAME):$(PHP_TAG)-wp$(WORDPRESS_LATEST_ONLY_MAJOR)
	@# Tag latest if running latest PHP version
	$(shell if [ $* = $(PHP_LATEST) ]; then docker tag $(IMAGE_NAME):$(PHP_TAG) $(IMAGE_NAME):latest; fi)
	@# Test the image
	$(DOCKER_RUN) $(IMAGE_NAME):$(PHP_TAG) "./vendor/bin/phpunit ./test"
	@# Write the the README markdown for these tags
	printf "[%s, %s, %s%s](https://github.com/nateinaction/wordpress-integration/blob/master/Dockerfile)\n\n" \
		"$(PHP_TAG)" \
		"$(PHP_TAG)-wp$(WORDPRESS_LATEST)" \
		"$(PHP_TAG)-wp$(WORDPRESS_LATEST_ONLY_MAJOR)" \
		"$(shell if [ $* = $(PHP_LATEST) ]; then echo ', latest'; fi)" > build/$(PHP_TAG).md

README.md: $(addprefix build/php, $(addsuffix .md, $(PHP_VERSIONS)))
	echo "# Supported tags and respective \`Dockerfile\` links" > README.md
	ls -rd $(shell pwd)/build/*.md | xargs cat >> README.md
	printf "\n" >> README.md
	cat README.footer.md >> README.md

.PHONY: shell-%
shell-%:
	$(DOCKER_RUN) -it $(IMAGE_NAME):$(PHP_TAG) "/bin/bash"

.PHONY: lint
lint:
	@for file in `find . -type f -name "*.sh"`; do $(DOCKER_RUN) koalaman/shellcheck --format=gcc /workspace/$${file}; done
