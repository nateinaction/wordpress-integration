#!/usr/bin/env bash
# shellcheck disable=SC2001

set -ex

WORDPRESS_VERSION=${1}
PHP_VERSION=${2}
PHP_LATEST=${3}
PHP_TAG=${4}

# Attribute: https://github.com/cloudflare/semver_bash/blob/master/semver.sh
# WordPress doesn't use semver for new major releases so patch version is optional
VERSION_DOTS="${WORDPRESS_VERSION//[^\.]}"
RE='\([0-9]*\)[.]\([0-9]*\)[.]\([0-9]*\)'
MAJOR=$(echo "${WORDPRESS_VERSION}" | sed -e "s/${RE}/\1/")
MINOR=$(echo "${WORDPRESS_VERSION}" | sed -e "s/${RE}/\2/")
if [ "${#VERSION_DOTS}" -eq 1 ]; then
	PATCH='0'
else
	PATCH=$(echo "${WORDPRESS_VERSION}" | sed -e "s/${RE}/\3/")
fi

TAGS="\`${PHP_TAG}\`, \`${PHP_TAG}-wp${MAJOR}.${MINOR}.${PATCH}\`, \`${PHP_TAG}-wp${MAJOR}.${MINOR}\`"
if [ "${PHP_LATEST}" = "${PHP_VERSION}" ]; then
	TAGS="${TAGS}, \`latest\`"
fi
printf "[%s](https://github.com/nateinaction/wordpress-integration/blob/master/Dockerfile)\n\n" "${TAGS}"

