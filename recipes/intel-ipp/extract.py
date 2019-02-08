#!/usr/bin/env python
import libarchive
import argparse

parser = argparse.ArgumentParser(
    description='Extract gzipped RPM archive',
    formatter_class=argparse.ArgumentDefaultsHelpFormatter
)
parser.add_argument('archive', type=str)


def extract(path):
    return libarchive.extract_file(path)


if __name__ == '__main__':
    extract(parser.parse_args().archive)
