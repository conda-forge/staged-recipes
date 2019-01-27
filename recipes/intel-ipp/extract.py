#!/usr/bin/env python
import libarchive.public
import argparse

parser = argparse.ArgumentParser(
    description='Extract gzipped RPM archive',
    formatter_class=argparse.ArgumentDefaultsHelpFormatter
)
parser.add_argument('archive', type=str)


def extract(path):
    for entry in libarchive.public.file_pour(path):
        print(entry)


if __name__ == '__main__':
    extract(parser.parse_args().archive)
