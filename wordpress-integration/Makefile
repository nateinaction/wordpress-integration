.PHONY: test

DOCKER_TAG := wordpress-integration
DOCKER_VOLUME := -v `pwd`:/workspace
DOCKER_RUN := @docker run --rm $(DOCKER_VOLUME)
START_MYSQL := /etc/init.d/mysql start;

all: build test

shell:
	$(DOCKER_RUN) -it $(DOCKER_TAG) "/bin/bash" -c "$(START_MYSQL) /bin/bash"

build:
	@docker build -t $(DOCKER_TAG) .

test:
	$(DOCKER_RUN) $(DOCKER_TAG) "/bin/bash" -c "$(START_MYSQL) make phpunit_test"

phpunit_test:
	/root/.composer/vendor/bin/phpunit -c ./test/phpunit.xml --testsuite="integration-tests"

