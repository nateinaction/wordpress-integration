.PHONY: test

DOCKER_TAG := wordpress-integration
DOCKER_RUN := docker run --rm -v `pwd`:/workspace
DOCKER_RUN_COMPOSER := $(DOCKER_RUN) -v `pwd`:/app composer
COMPOSER_DIR := -d "./composer"

all: lint_bash build composer_install test

shell:
	@$(DOCKER_RUN) -it $(DOCKER_TAG) "/bin/bash"

lint_bash:
	@for file in `find bin -type f -name "*.sh"`; do $(DOCKER_RUN) koalaman/shellcheck --format=gcc /workspace/$$file; done;

build:
	@docker build -t $(DOCKER_TAG) .

publish:
	@docker push $(DOCKER_TAG)

test:
	@$(DOCKER_RUN) -it $(DOCKER_TAG) "/workspace/composer/vendor/bin/phpunit -c ./test/phpunit.xml --testsuite=integration-tests"

composer_install:
	@$(DOCKER_RUN_COMPOSER) install $(COMPOSER_DIR)

composer_update:
	@$(DOCKER_RUN_COMPOSER) update $(COMPOSER_DIR)
