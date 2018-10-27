#!/usr/bin/env bash

WORDPRESS_VERSION=${WORDPRESS_VERSION-latest}
WORDPRESS_DB_NAME=${WORDPRESS_DB_NAME-wordpress}
WORDPRESS_DB_USER=${WORDPRESS_DB_USER-wordpress}
WORDPRESS_DB_PASS=${WORDPRESS_DB_PASS-password}
WORDPRESS_DB_HOST=${WORDPRESS_DB_HOST-localhost}
WORDPRESS_SVN_DIR=${WORDPRESS_SVN_DIR-/wordpress}

if [[ ${WORDPRESS_VERSION} =~ [0-9]+\.[0-9]+(\.[0-9]+)? ]]; then
    WP_TESTS_TAG="tags/${WORDPRESS_VERSION}"
elif [[ ${WORDPRESS_VERSION} == 'nightly' || ${WORDPRESS_VERSION} == 'trunk' ]]; then
    WP_TESTS_TAG="trunk"
else
    # http serves a single offer, whereas https serves multiple. we only want one
    curl -s http://api.wordpress.org/core/version-check/1.7/ > /tmp/wp-latest.json
    grep '[0-9]+\.[0-9]+(\.[0-9]+)?' /tmp/wp-latest.json
    LATEST_VERSION=$(grep -o '"version":"[^"]*' /tmp/wp-latest.json | sed 's/"version":"//')
    if [[ -z "${LATEST_VERSION}" ]]; then
        echo "Latest WordPress version could not be found"
        exit 1
    fi
    WP_TESTS_TAG="tags/${LATEST_VERSION}"
fi

# Checkout WordPress svn with retry logic... meh
TRUNCATED=true
while ${TRUNCATED}; do
    SVN_RESPONSE=`svn co --quiet https://develop.svn.wordpress.org/${WP_TESTS_TAG}/ ${WORDPRESS_SVN_DIR}`
    rc=$?;
    if [[ $rc != 0 ]]; then
        echo 'SVN checkout was interupted. Retrying...'
        svn cleanup --quiet ${WORDPRESS_SVN_DIR}
        svn up --quiet ${WORDPRESS_SVN_DIR}
        continue
    fi
    TRUNCATED=false
done

# if response contains "The server sent a truncated HTTP response body"
# svn cleanup
# svn up

# Configure test config
WORDPRESS_TEST_HARNESS_CONFIG="${WORDPRESS_SVN_DIR}/wp-tests-config.php"
cp "${WORDPRESS_SVN_DIR}/wp-tests-config-sample.php" "${WORDPRESS_TEST_HARNESS_CONFIG}"
sed -i "s/youremptytestdbnamehere/${WORDPRESS_DB_NAME}/" "${WORDPRESS_TEST_HARNESS_CONFIG}"
sed -i "s/yourusernamehere/${WORDPRESS_DB_USER}/" "${WORDPRESS_TEST_HARNESS_CONFIG}"
sed -i "s/yourpasswordhere/${WORDPRESS_DB_PASS}/" "${WORDPRESS_TEST_HARNESS_CONFIG}"
sed -i "s|localhost|${WORDPRESS_DB_HOST}|" "${WORDPRESS_TEST_HARNESS_CONFIG}"

