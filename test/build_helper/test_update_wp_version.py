import unittest
from build_helper import update_wp_version


class TestUpdateWpVersion(unittest.TestCase):
    def test_get_match_patterns(self):
        wp_version = 'abc123'
        supported_filetypes = {
            'Makefile': {
                'find': r'^WORDPRESS_VERSION :=',
                'replace': 'WORDPRESS_VERSION := {}\n'.format(wp_version),
            },
            'Dockerfile': {
                'find': r'^ARG WORDPRESS_VERSION',
                'replace': 'ARG WORDPRESS_VERSION={}\n'.format(wp_version),
            },
        }
        find, replace = update_wp_version.get_match_params('something/Dockerfile', wp_version)
        self.assertEqual(find, supported_filetypes['Dockerfile']['find'])
        self.assertEqual(replace, supported_filetypes['Dockerfile']['replace'])

        find, replace = update_wp_version.get_match_params('some/thing/Makefile', wp_version)
        self.assertEqual(find, supported_filetypes['Makefile']['find'])
        self.assertEqual(replace, supported_filetypes['Makefile']['replace'])

        with self.assertRaises(ValueError):
            update_wp_version.get_match_params('MakefileDoesntwork', wp_version)

        with self.assertRaises(ValueError):
            update_wp_version.get_match_params('something', wp_version)

    def test_find_and_replace(self):
        find = r'^WORDPRESS_VERSION :='
        replace = 'WORDPRESS_VERSION := abc123\n'
        contents = [
            'some first line\n',
            'some second line\n',
            'WORDPRESS_VERSION := old_version\n',
            'WORDPRESS_VERSION := old_version\n',
            'some final line\n',
        ]
        expected_contents = [
            'some first line\n',
            'some second line\n',
            'WORDPRESS_VERSION := abc123\n',
            'WORDPRESS_VERSION := old_version\n',
            'some final line\n',
        ]
        actual_contents = update_wp_version.find_replace(find, replace, contents)
        self.assertListEqual(expected_contents, actual_contents)

        contents = []
        expected_contents = []
        actual_contents = update_wp_version.find_replace(find, replace, contents)
        self.assertListEqual(expected_contents, actual_contents)


if __name__ == '__main__':
    unittest.main()
