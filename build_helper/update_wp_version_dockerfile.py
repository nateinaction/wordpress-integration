#!/usr/bin/env python

import os
import re
import sys


def update_dockerfile(new_version, dockerfile_filename):
    """ Set WordPress version in Dockerfile to the specified version"""
    print('Setting WordPress dependency in {} to version {}'.format(dockerfile_filename, new_version))
    wp_version = 'ARG WORDPRESS_VERSION={}\n'.format(new_version)

    with open(dockerfile_filename, 'r') as f:
        contents = f.readlines()

    for line_num, line in enumerate(contents):
        wp_version_match = re.match(r'^ARG WORDPRESS_VERSION', line)
        if wp_version_match:
            contents[line_num] = wp_version

    with open(dockerfile_filename, 'w') as f:
        f.writelines(contents)


if __name__ == '__main__':
    version = sys.argv[1]
    filename = os.path.abspath(sys.argv[2])
    if re.match(r'.*/Dockerfile$', filename):
        update_dockerfile(version, filename)
    else:
        print('unrecognized file type', filename)
        exit(1)
