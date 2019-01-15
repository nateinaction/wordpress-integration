#!/usr/bin/env python

import os
import re
import sys


def update_makefile(new_version, makefile_filename):
    """ Set WordPress version in Makefile to the specified version"""
    print('Setting WordPress version in {} to {}'.format(makefile_filename, new_version))

    with open(makefile_filename, 'r') as f:
        contents = f.readlines()

    for line_num, line in enumerate(contents):
        wp_version_match = re.match(r'^WORDPRESS_VERSION := (?P<version>[\d\.]+)', line)
        if wp_version_match:
            contents[line_num] = 'WORDPRESS_VERSION := {}\n'.format(new_version)

    with open(makefile_filename, 'w') as f:
        f.writelines(contents)


if __name__ == '__main__':
    version = sys.argv[1]
    filename = os.path.abspath('./Makefile')
    update_makefile(version, filename)
