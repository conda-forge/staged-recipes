#!/usr/bin/env python
# -*- coding: utf-8 -*-
# This file is part of addfips.
# http://github.com/fitnr/addfips
# Licensed under the GPL-v3.0 license:
# http://opensource.org/licenses/GPL-3.0
# Copyright (c) 2016, fitnr <fitnr@fakeisthenewreal>
# pylint: disable=missing-docstring,invalid-name
import csv
import io
import subprocess
import sys
import unittest
from os import path

from addfips import __main__ as addfips_cli


class TestCli(unittest.TestCase):

    def setUp(self):
        dirname = path.join(path.dirname(__file__), 'data')

        self.st_args = ['addfips', path.join(dirname, 'state.csv'), '-s', 'name']
        self.co_args = ['addfips', path.join(dirname, 'county.csv'), '-c', 'county', '-s', 'state']

    def test_state_cli_subprocess(self):
        out = subprocess.check_output(self.st_args)

        f = io.StringIO(out.decode('utf8'))

        reader = csv.DictReader(f)
        row = next(reader)

        self.assertIn('name', row.keys())
        self.assertIn('fips', row.keys())

        self.assertEqual(row.get('name'), 'Alabama')
        assert row.get('fips') == '01'

    def test_county_cli_subprocess(self):
        p = subprocess.Popen(self.co_args, stdout=subprocess.PIPE)
        out, err = p.communicate()

        assert err is None

        f = io.StringIO(out.decode('utf-8'))

        reader = csv.DictReader(f)
        row = next(reader)

        self.assertIn('county', row.keys())
        self.assertIn('fips', row.keys())

        assert row.get('county') == 'Autauga County'
        assert row['fips'] == '01001'

    def test_county_cli_call(self):
        sys.argv = self.co_args
        sys.stdout = io.StringIO()
        addfips_cli.main()
        sys.stdout.seek(0)
        reader = csv.DictReader(sys.stdout)
        row = next(reader)

        self.assertIn('county', row.keys())
        self.assertIn('fips', row.keys())

        assert row['county'] == 'Autauga County'
        assert row['fips'] == '01001'

    def test_state_cli_call(self):
        sys.argv = self.st_args
        sys.stdout = io.StringIO()
        addfips_cli.main()
        sys.stdout.seek(0)
        reader = csv.DictReader(sys.stdout)
        row = next(reader)

        self.assertIn('name', row.keys())
        self.assertIn('fips', row.keys())

        assert row['name'] == 'Alabama'
        assert row['fips'] == '01'

    def test_state_name_cli_call(self):
        sys.argv = self.co_args[:-2] + ['--state-name', 'Alabama']
        sys.stdout = io.StringIO()
        addfips_cli.main()
        sys.stdout.seek(0)
        reader = csv.DictReader(sys.stdout)
        row = next(reader)

        self.assertIn('county', row.keys())
        self.assertIn('fips', row.keys())

        assert row['county'] == 'Autauga County'
        assert row['fips'] == '01001'

    def test_state_cli_call_noheader(self):
        sys.argv = self.st_args[:2] + ['-s', '1', '--no-header']
        sys.stdout = io.StringIO()
        addfips_cli.main()
        sys.stdout.seek(0)
        reader = csv.reader(sys.stdout)
        next(reader)
        row = next(reader)

        assert row[1] == 'Alabama'
        assert row[0] == '01'

    def test_unmatched(self):
        self.assertTrue(addfips_cli.unmatched({'fips': None}))
        self.assertTrue(addfips_cli.unmatched([None, 'foo']))
        self.assertFalse(addfips_cli.unmatched(['01001', 'foo']))
        self.assertFalse(addfips_cli.unmatched({'fips': '01001'}))


if __name__ == '__main__':
    unittest.main()
