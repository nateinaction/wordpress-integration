#!/usr/bin/env bash
# shellcheck disable=SC2001

DOCKER_IMAGE_NAME=${1}
WORDPRESS_VERSION=${2}
PHP_TAG=${3}

# Attribute: https://github.com/cloudflare/semver_bash/blob/master/semver.sh
RE='[^0-9]*\([0-9]*\)[.]\([0-9]*\)[.]\([0-9]*\)\([0-9A-Za-z-]*\)'
MAJOR=$(echo "${WORDPRESS_VERSION}" | sed -e "s/${RE}/\1/")
MINOR=$(echo "${WORDPRESS_VERSION}" | sed -e "s/${RE}/\2/")
PATCH=$(echo "${WORDPRESS_VERSION}" | sed -e "s/${RE}/\3/")

# Add tags to array, PHP_TAG is added to the image during build
TAGS+=("${MAJOR}.${MINOR}.${PATCH}-${PHP_TAG}")
TAGS+=("${MAJOR}.${MINOR}-${PHP_TAG}")

for DOCKER_TAG in "${TAGS[@]}"; do
	docker tag "${DOCKER_IMAGE_NAME}":"${PHP_TAG}" "${DOCKER_IMAGE_NAME}":"${DOCKER_TAG}"
done
