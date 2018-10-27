.PHONY: test

DOCKER_TAG := wordpress-integration
DOCKER_RUN := @docker run --rm -v `pwd`:/workspace
START_MYSQL := service mysql start;

all: build test

shell:
	$(DOCKER_RUN) -it --entrypoint "/bin/bash" $(DOCKER_TAG)

build:
	@docker build -t $(DOCKER_TAG) .

test:
	$(DOCKER_RUN) -it $(DOCKER_TAG) -c "./test/phpunit.xml" --testsuite="integration-tests"

update_composer_dependencies:
	$(DOCKER_RUN) -v `pwd`:/app composer update -d "./composer"
