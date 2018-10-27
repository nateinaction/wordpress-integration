.PHONY: test

DOCKER_TAG := wordpress-integration
DOCKER_RUN := @docker run --rm -v `pwd`:/workspace
START_MYSQL := service mysql start;

all: build composer_install test

shell:
	$(DOCKER_RUN) -it $(DOCKER_TAG) "/bin/bash" -c "$(START_MYSQL) /bin/bash"

build:
	@docker build -t $(DOCKER_TAG) .

test:
	$(DOCKER_RUN) $(DOCKER_TAG) "/bin/bash" -c "$(START_MYSQL) make phpunit_test"

composer_install:
	$(DOCKER_RUN) -v `pwd`:/app composer install -d "./composer"

phpunit_test:
	./composer/vendor/bin/phpunit -c "./test/phpunit.xml" --testsuite="integration-tests"

