#!/usr/bin/env python

import unittest


def main():
  suite = unittest.TestLoader().discover('test', pattern = 'test.py')
  unittest.TextTestRunner(verbosity=2).run(suite)


if __name__ == '__main__':
    main()
