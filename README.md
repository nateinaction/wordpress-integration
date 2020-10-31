# Supported tags and respective `Dockerfile` links
[php7.4, php7.4-wp5.5.3, php7.4-wp5.5, latest](https://github.com/nateinaction/wordpress-integration/blob/master/Dockerfile)

[php7.3, php7.3-wp5.5.3, php7.3-wp5.5](https://github.com/nateinaction/wordpress-integration/blob/master/Dockerfile)

[php7.2, php7.2-wp5.5.3, php7.2-wp5.5](https://github.com/nateinaction/wordpress-integration/blob/master/Dockerfile)

[php7.1, php7.1-wp5.5.3, php7.1-wp5.5](https://github.com/nateinaction/wordpress-integration/blob/master/Dockerfile)


# WordPress Integration Docker Image
![Build Status](https://github.com/worldpeaceio/wordpress-integration/workflows/Build/badge.svg)
[![Docker Hub Pulls](https://img.shields.io/docker/pulls/worldpeaceio/wordpress-integration.svg)](https://hub.docker.com/r/worldpeaceio/wordpress-integration)

This docker image sets up a WordPress integration environment that can be used to test WordPress plugins and themes.

Testing your plugin has never been easier!

```bash
docker run --rm -v `pwd`:/workspace worldpeaceio/wordpress-integration ./vendor/bin/phpunit ./test-dir
```

### Supported versions:
- [PHP](https://make.wordpress.org/core/handbook/references/php-compatibility-and-wordpress-versions/)
- [WordPress](https://codex.wordpress.org/Supported_Versions)

### What this image provides

- WordPress (located at /wordpress/src)
- WordPress Testcase, Mocks and Factories (located at /wordpress/tests/phpunit/includes/)
- Xdebug

### What this image does NOT provide

- PHPUnit

This image is agnostic about your test runner. You can manage your own version of PHPUnit as a dev dependency in your project. Just mount your project directory and call an executable to run your tests.

### Bootstrap requirement

When using PHPUnit or another test runner you will need to use a bootstrap file like the following to help kick things off. With PHPUnit, you can use a bootstrap file by adding the `--bootstrap FILENAME` flag or by setting the bootstrap option in your `phpunit.xml` config file.

```php
<?php
/**
 * Test bootstrap
 *
 * @package your-plugin
 */

$wordpress_tests = '/wordpress/tests/phpunit/includes';

/**
 * The WordPress tests functions.
 *
 * We are loading this so that we can add our tests filter
 * to load the plugin, using tests_add_filter().
 */
require_once $wordpress_tests . '/functions.php';

/**
 * Manually load the plugin main file.
 *
 * The plugin won't be activated within the test WP environment,
 * that's why we need to load it manually.
 *
 * You will also need to perform any installation necessary after
 * loading your plugin, since it won't be installed.
 */
function _manually_load_plugin() {
	require '/workspace/your-plugin-entrypoint.php';
}
tests_add_filter( 'muplugins_loaded', '_manually_load_plugin' );

/**
 * Sets up the WordPress test environment.
 *
 * We've got our action set up, so we can load this now,
 * and viola, the tests begin.
 */
require $wordpress_tests . '/bootstrap.php';
```

### Example of plugins using this image

- [Segment Cache for WP Engine](https://github.com/nateinaction/segment-cache-for-wp-engine)
- [WP Engine GeoTarget](https://github.com/wpengine/geoip)

### Contributing and maintaining this image

If you feel like this image is missing something please post a PR or open a new issue!

#### Updating WordPress

This image is automatically kept up-to-date with WordPress core by a Github Action. If you need to manually modify the WordPress version in the image just run `echo WORDPRESS_VERSION > build/wordpress-version.txt` in the repo root.
