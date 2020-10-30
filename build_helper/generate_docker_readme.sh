#!/usr/bin/env bash
# shellcheck disable=SC2001

set -ex

DOCKER_IMAGE_NAME=${1}
WORDPRESS_VERSION=${2}
PHP_VERSION=${3}
PHP_LATEST=${4}
PHP_TAG=${5}

# Attribute: https://github.com/cloudflare/semver_bash/blob/master/semver.sh
# WordPress doesn't use semver for new major releases so patch version is optional
VERSION_DOTS="${WORDPRESS_VERSION//[^\.]}"
if [ "${#VERSION_DOTS}" -eq 1 ]
then
	RE='\([0-9]*\)[.]\([0-9]*\)'
	MAJOR=$(echo "${WORDPRESS_VERSION}" | sed -e "s/${RE}/\1/")
	MINOR=$(echo "${WORDPRESS_VERSION}" | sed -e "s/${RE}/\2/")
	PATCH='0'
else
	RE='\([0-9]*\)[.]\([0-9]*\)[.]\([0-9]*\)'
	MAJOR=$(echo "${WORDPRESS_VERSION}" | sed -e "s/${RE}/\1/")
	MINOR=$(echo "${WORDPRESS_VERSION}" | sed -e "s/${RE}/\2/")
	PATCH=$(echo "${WORDPRESS_VERSION}" | sed -e "s/${RE}/\3/")
fi

# Add tags to array, PHP_TAG is added to the image during build
TAGS+=("${PHP_TAG}-wp${MAJOR}.${MINOR}.${PATCH}")
TAGS+=("${PHP_TAG}-wp${MAJOR}.${MINOR}")

printf "[\`${PHP_TAG}\`" >> README.md
for DOCKER_TAG in "${TAGS[@]}"; do
	printf ", \`${DOCKER_TAG}\`" >> README.md
done
if [[ "${PHP_LATEST}" == "${PHP_VERSION}" ]]; then
	printf ", \`latest\`" >> README.md
fi
printf "](https://github.com/nateinaction/wordpress-integration/blob/master/Dockerfile)\n\n" >> README.md

