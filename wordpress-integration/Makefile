.PHONY: test

DOCKER_TAG := wordpress-integration
DOCKER_RUN := @docker run -it --rm -v `pwd`:/workspace
DOCKER_SHELL := $(DOCKER_RUN) $(DOCKER_TAG) "/bin/bash"
ALLOW_ROOT := --allow-root
START_MYSQL := /etc/init.d/mysql start;

all: docker_build
	$(DOCKER_SHELL) -c "$(START_MYSQL) make test"

shell:
	$(DOCKER_SHELL)

docker_build:
	docker build -t $(DOCKER_TAG) ./docker/

test:
	/root/.composer/vendor/bin/phpunit -c ./test/phpunit.xml --testsuite=unit-tests

