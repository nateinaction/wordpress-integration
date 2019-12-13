#!/usr/bin/env python3

import logging
import os
import re
import sys


def get_match_params(filepath: str, wp_version: str):
    """
    Ensure that the file is one of the supported file types and provide match params
    :param filepath: String
    :param wp_version: String
    :return: Find String, Replace String
    """
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
    for filetype in supported_filetypes:
        if re.match(r'.*/{}$'.format(filetype), filepath):
            logging.info('Found {}'.format(filepath))
            return supported_filetypes[filetype]['find'], supported_filetypes[filetype]['replace']

    raise ValueError('Unrecognized file type: {}'.format(filepath))


def read_file_contents(filepath: str):
    with open(filepath, 'r') as f:
        return f.readlines()


def write_file_contents(filepath: str, contents: str):
    with open(filepath, 'w') as f:
        f.writelines(contents)


def find_replace(find: str, replace: str, contents: list):
    for line_num, line in enumerate(contents):
        if re.match(find, line):
            logging.info('- {}'.format(line))
            logging.info('+ {}'.format(replace))
            contents[line_num] = replace
            break
    
    return contents


if __name__ == '__main__':
    logging.basicConfig(stream=sys.stderr, level=logging.DEBUG)
    wordpress_version = sys.argv[1]
    filename = os.path.abspath(sys.argv[2])
    try:
        find, replace = get_match_params(filename, wordpress_version)
        file_contents = read_file_contents(filename)
        file_contents = find_replace(find, replace, file_contents)
        write_file_contents(filename, file_contents)
    except:
        raise
