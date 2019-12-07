<?php
/**
 * Unit tests determines if WordPress core functions exist
 *
 * @package worldpeaceio/wordpress-integration
 */

/**
 * This unit tests validates that WP test enviroment exists with WP_UnitTestCase class
 * Then it verifies that WP exists with wp_kses
 */
class ValidIntegrationEnvironmentTest extends \WP_UnitTestCase {
	/**
	 * Test WordPress is available
	 */
	public function test_wordpress_available(): void {
		$wordpress_available = function_exists('wp_kses');
		$this->assertTrue($wordpress_available);
	}

	/**
	 * Test verify extensions installed
	 *
	 * Extensions installed: xdebug
	 */
	public function test_php_extensions_installed(): void {
		$xdebug_installed = function_exists('xdebug_break');
		$this->assertTrue($xdebug_installed);
	}
}
