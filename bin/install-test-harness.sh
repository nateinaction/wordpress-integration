#!/usr/bin/env bash

# Script expects these vars to be present
WORDPRESS_VERSION=${WORDPRESS_VERSION}
WORDPRESS_DB_NAME=${WORDPRESS_DB_NAME}
WORDPRESS_DB_USER=${WORDPRESS_DB_USER}
WORDPRESS_DB_PASS=${WORDPRESS_DB_PASS}
WORDPRESS_DB_HOST=${WORDPRESS_DB_HOST}
WORDPRESS_SVN_DIR=${WORDPRESS_SVN_DIR}

# Determine WordPress version
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

# Checkout WordPress svn with retry logic
RETRY_COUNT=0
TRUNCATED=true
echo 'WordPress SVN checkout started.'
while ${TRUNCATED}; do
    if [[ ${RETRY_COUNT} == 5 ]]; then
        echo "SVN checkout failed after ${RETRY_COUNT} attempts."
        exit 1
    fi

    svn co --quiet "https://develop.svn.wordpress.org/${WP_TESTS_TAG}/" "${WORDPRESS_SVN_DIR}"
    rc=$?;
    if [[ ${rc} != 0 ]]; then
        echo 'SVN checkout was interrupted. Retrying...'
        svn cleanup --quiet "${WORDPRESS_SVN_DIR}"
        svn up --quiet "${WORDPRESS_SVN_DIR}"
        ((RETRY_COUNT++))
        continue
    fi
    TRUNCATED=false
done

# Configure test config
WORDPRESS_TEST_HARNESS_CONFIG="${WORDPRESS_SVN_DIR}/wp-tests-config.php"
cp "${WORDPRESS_SVN_DIR}/wp-tests-config-sample.php" "${WORDPRESS_TEST_HARNESS_CONFIG}"
sed -i "s/youremptytestdbnamehere/${WORDPRESS_DB_NAME}/" "${WORDPRESS_TEST_HARNESS_CONFIG}"
sed -i "s/yourusernamehere/${WORDPRESS_DB_USER}/" "${WORDPRESS_TEST_HARNESS_CONFIG}"
sed -i "s/yourpasswordhere/${WORDPRESS_DB_PASS}/" "${WORDPRESS_TEST_HARNESS_CONFIG}"
sed -i "s|localhost|${WORDPRESS_DB_HOST}|" "${WORDPRESS_TEST_HARNESS_CONFIG}"
