<?php
/**
 * Create test bootstrap
 *
 * @package segment-cache-for-wp-engine
 */

$_tests_dir = '/wordpress-test-harness';

/**
 * The WordPress tests functions.
 *
 * We are loading this so that we can add our tests filter
 * to load the plugin, using tests_add_filter().
 */
require_once $_tests_dir . '/includes/functions.php';

/**
 * Sets up the WordPress test environment.
 *
 * We've got our action set up, so we can load this now,
 * and viola, the tests begin.
 */
require $_tests_dir . '/includes/bootstrap.php';
