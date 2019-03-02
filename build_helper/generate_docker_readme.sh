#!/usr/bin/env bash
# shellcheck disable=SC2001

DOCKER_IMAGE_NAME=${1}
WORDPRESS_VERSION=${2}
PHP_VERSION=${3}
PHP_LATEST=${4}
PHP_TAG=${5}

# Attribute: https://github.com/cloudflare/semver_bash/blob/master/semver.sh
# WordPress doesn't use semver for new major releases so patch version is optional
RE='[^0-9]*\([0-9]*\)[.]\([0-9]*\)[.]\([0-9]*\)\([0-9A-Za-z-]*\)'
MAJOR=$(echo "${WORDPRESS_VERSION}" | sed -e "s/${RE}/\1/")
MINOR=$(echo "${WORDPRESS_VERSION}" | sed -e "s/${RE}/\2/")
PATCH=$(echo "${WORDPRESS_VERSION}" | sed -e "s/${RE}/\3/")

# Add tags to array, PHP_TAG is added to the image during build
TAGS+=("${MAJOR}.${MINOR}.${PATCH}-${PHP_TAG}")
TAGS+=("${MAJOR}.${MINOR}-${PHP_TAG}")

for DOCKER_TAG in "${TAGS[@]}"; do
	printf "\`${DOCKER_TAG}\` " >> README.md
done
printf "\`${PHP_TAG}\` " >> README.md
if [[ "${PHP_LATEST}" == "${PHP_VERSION}" ]]; then
	printf "\`latest\` " >> README.md
fi
printf "([${PHP_TAG}/Dockerfile](https://github.com/nateinaction/wordpress-integration/blob/master/${PHP_TAG}/Dockerfile))\n\n" >> README.md

