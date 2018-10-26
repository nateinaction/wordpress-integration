<?php
/**
 * Unit tests determines if WordPress core functions exist
 *
 * @package wordpress-integration-docker
 */

/**
 * This unit tests validates that WP test enviroment exists with WP_UnitTestCase class
 * Then it verifies that WP exists with wp_kses
 */
class ValidIntegrationEnvironmentTest extends \WP_UnitTestCase {
	/**
	 * Test inside_wordpress_environment
	 */
	public function test_inside_wordpress_environment() {
		$inside_wordpress_environment = function_exists('wp_kses');
		$this->assertTrue( $inside_wordpress_environment );
	}
}
