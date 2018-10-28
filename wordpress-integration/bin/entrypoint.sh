#!/usr/bin/env bash
set -e

# Start and configure mysql
start-and-configure-mysql.sh

# Run phpunit
/composer/vendor/bin/phpunit $@
