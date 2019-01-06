#!/usr/bin/env python

import os
import re
import sys


def update_dockerfile(new_version, dockerfile_filename):
    """ Set WordPress version in Dockerfile to the specified version"""
    print('Setting WordPress dependency in {} to version {}'.format(dockerfile_filename, new_version))
    github_release_url = 'https://codeload.github.com/WordPress/wordpress-develop/tar.gz/{}'.format(new_version)
    curl = 'RUN curl "{}" -o "/wordpress.tar.gz"; \\\n'.format(github_release_url)

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
    if re.match(r'.*/Dockerfile$', filename):
        update_dockerfile(version, filename)
    else:
        print('unrecognized file type', filename)
        exit(1)
