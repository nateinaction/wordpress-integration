import json
import os
import re
import sys
from collections import OrderedDict


def update_makefile(new_version, makefile_filename):
    """ Set WordPress version in Makefile to the specified version"""
    print('Setting WordPress version in {} to {}'.format(makefile_filename, new_version))

    with open(makefile_filename, 'r') as f:
        contents = f.readlines()

    for line_num, line in enumerate(contents):
        wp_version_match = re.match(r'^WORDPRESS_VERSION := (?P<version>\d+)', line)
        if wp_version_match:
            contents[line_num] = 'WORDPRESS_VERSION := {}\n'.format(new_version)

    with open(makefile_filename, 'w') as f:
        f.writelines(contents)


def update_dockerfile(new_version, dockerfile_filename):
    """ Set WordPress version in composer.json to the specified version"""
    print('Setting WordPress dependency in {} to version {}'.format(dockerfile_filename, new_version))
    github_release_url = 'https://codeload.github.com/WordPress/wordpress-develop/zip/{}'.format(new_version)
    curl = 'RUN curl "{}" -o "/wordpress.zip"; \\\n'.format(github_release_url)

    with open(dockerfile_filename, 'r') as f:
        contents = f.readlines()

    for line_num, line in enumerate(contents):
        curl_match = re.match(r'^RUN curl "https://codeload.github.com', line)
        if curl_match:
            contents[line_num] = curl

    with open(dockerfile_filename, 'w') as f:
        f.writelines(contents)


if __name__ == '__main__':
    version = sys.argv[1]
    filename = os.path.abspath(sys.argv[2])
    is_makefile = re.match(r'Makefile$', filename)
    if re.match(r'.*/Makefile$', filename):
        update_makefile(version, filename)
    elif re.match(r'.*/Dockerfile$', filename):
        update_dockerfile(version, filename)
    else:
        print('unrecognized file type', filename)
        exit(1)
