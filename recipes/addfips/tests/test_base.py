#!/usr/bin/env python
# -*- coding: utf-8 -*-
# This file is part of addfips.
# http://github.com/fitnr/addfips
# Licensed under the GPL-v3.0 license:
# http://opensource.org/licenses/GPL-3.0
# Copyright (c) 2016, fitnr <fitnr@fakeisthenewreal>
# pylint: disable=missing-docstring,invalid-name,protected-access
import re
import unittest

from importlib_resources import files

from addfips import addfips


class TestAddFips(unittest.TestCase):

    def setUp(self):
        self.af = addfips.AddFIPS()

    def test_basics(self):
        assert isinstance(self.af._states, dict)
        assert isinstance(self.af._counties, dict)

    def test_empty(self):
        assert self.af.get_county_fips('foo', 'bar') is None
        assert self.af.get_county_fips('foo', state='New York') is None
        assert self.af.get_state_fips('foo') is None

    def test_vintages(self):
        self.assertIn(2000, addfips.COUNTY_FILES)
        self.assertIn(2010, addfips.COUNTY_FILES)
        self.assertIn(2015, addfips.COUNTY_FILES)

    def test_typos(self):
        '''Find missing or mistyped geographic names in data files'''
        for vintage in (2000, 2010, 2015):
            county_csv = files('addfips').joinpath(addfips.COUNTY_FILES[vintage])
            with county_csv.open() as f:
                # purge header
                f.readline()
                for line in f.readlines():
                    try:
                        assert re.search(addfips.COUNTY_PATTERN, line.strip(), flags=re.I)
                    except AssertionError:
                        if line.find('11,001') > -1 or line.find('Guam') > -1:
                            continue
                        err = 'Did not match county regex: {} ({})'.format(line, vintage)
                        raise AssertionError(err)


class TestData(unittest.TestCase):

    def setUp(self):
        self.af = addfips.AddFIPS()
        self.row = {
            'county': 'Kings',
            'borough': 'Brooklyn',
            'state': 'New York',
            'statefp': '36',
            'foo': 'bar'
        }
        self.list = ['Kings', 'Brooklyn', 'New York', 'NY', '36']

    def test_get_state(self):
        assert self.af.get_state_fips('New York') == '36'
        assert self.af.get_state_fips('36') == '36'
        assert self.af.get_state_fips('NY') == '36'
        assert self.af.get_state_fips('ny') == '36'
        assert self.af.get_state_fips('new york') == '36'

    def test_county_row_dict_defaults(self):
        new = self.af.add_county_fips(self.row)
        self.assertEqual(new['fips'], '36047')

        self.af.default_state_field = 'statefp'
        self.af.default_county_field = 'borough'
        new = self.af.add_county_fips(self.row)
        assert new['fips'] == '36047'

    def test_county_row_state_name(self):
        new = self.af.add_county_fips(self.row, county_field='county', state='New York')
        assert new['fips'] == '36047'
        assert new['foo'] == 'bar'

    def test_vintage2015(self):
        self.assertIsNone(self.af.get_county_fips('Clifton Forge', 'VA'))

    def test_vintage2010(self):
        af2010 = addfips.AddFIPS(vintage=2010)
        assert af2010.get_county_fips('Wade Hampton', 'Alaska') == '02270'
        self.assertIsNone(af2010.get_county_fips('Clifton Forge', 'VA'))

    def test_vintage2000(self):
        af2000 = addfips.AddFIPS(vintage=2000)
        assert af2000.get_county_fips('Wade Hampton', 'Alaska') == '02270'
        self.assertEqual(af2000.get_county_fips('Clifton Forge city', 'Virginia'), "51560")
        assert af2000.get_county_fips('Clifton Forge', 'Virginia') == "51560"

    def test_get_county(self):
        # Full County Name with various ways of ID'ing state
        assert self.af.get_county_fips("Val Verde County", '48') == "48465"
        assert self.af.get_county_fips("Johnson County", 'Kansas') == "20091"
        assert self.af.get_county_fips("Fall River County", "SD") == "46047"

    def test_case_insensitive(self):
        assert self.af.get_county_fips('niagara', 'ny') == '36063'

    def test_no_county(self):
        assert self.af.get_county_fips("El Dorado", 'California') == "06017"

    def test_parish(self):
        assert self.af.get_county_fips('Acadia Parish', 'Louisiana') == "22001"
        assert self.af.get_county_fips('Caldwell', 'Louisiana') == "22021"

    def test_alaska_borough(self):
        self.assertEqual(self.af.get_county_fips('Aleutians East', 'AK'), "02013")
        self.assertEqual(self.af.get_county_fips("Juneau", "Alaska"), "02110")

    def test_nyc_borough(self):
        assert self.af.get_county_fips("Brooklyn", "NY") == "36047"

    def test_diacretic(self):
        assert self.af.get_county_fips('Dona Ana', '35') == "35013"
        assert self.af.get_county_fips('Añasco Municipio', 'Puerto Rico') == "72011"

    def test_municipio(self):
        self.assertEqual(self.af.get_county_fips('Añasco Municipio', 'PR'), "72011")
        self.assertEqual(self.af.get_county_fips('Añasco', 'PR'), "72011")

    def test_municipality(self):
        self.assertEqual(self.af.get_county_fips('Anchorage Municipality', 'AK'), "02020")
        self.assertEqual(self.af.get_county_fips('Anchorage', 'AK'), "02020")

        assert self.af.get_county_fips('Northern Islands', '69') == "69085"

    def test_city(self):
        assert self.af.get_county_fips('Emporia', 'Virginia') == "51595"

    def test_state_row(self):
        new = self.af.add_state_fips(self.row, state_field='state')
        assert new['fips'] == '36'
        assert new['foo'] == 'bar'

        new = self.af.add_state_fips(self.row, state_field='statefp')
        assert new['fips'] == '36'

    def test_state_list(self):
        new = self.af.add_state_fips(self.list, state_field=2)
        assert new[0] == '36'

        new = self.af.add_state_fips(self.list, state_field=3)
        assert new[0] == '36'

    def test_county_dict(self):
        new = self.af.add_county_fips(self.row, county_field='county', state_field='state')
        assert new['fips'] == '36047'
        assert new['foo'] == 'bar'

        new = self.af.add_county_fips(self.row, county_field='county', state_field='statefp')
        assert new['fips'] == '36047'

        new = self.af.add_county_fips(self.row, county_field='borough', state_field='statefp')
        assert new['fips'] == '36047'

    def test_county_list(self):
        new = self.af.add_county_fips(self.list, county_field=1, state_field=2)
        assert new[0] == '36047'

    def test_saint(self):
        assert self.af.get_county_fips('St. Clair County', 'AL') == "01115"
        assert self.af.get_county_fips('St. Clair', 'AL') == "01115"
        assert self.af.get_county_fips('St. Louis City', 'Missouri') == "29510"

        self.assertEqual(self.af.get_county_fips('Saint Louis County', 'Missouri'), "29189")
        assert self.af.get_county_fips('Saint Louis County', 'MO') == "29189"
        assert self.af.get_county_fips('Saint Louis City', 'MO') == "29510"

        assert self.af.get_county_fips('Ste. Genevieve County', 'MO') == "29186"
        assert self.af.get_county_fips('Sainte Genevieve', 'MO') == "29186"

    def test_fort(self):
        assert self.af.get_county_fips('Ft. Bend County', 'Texas') == '48157'
        assert self.af.get_county_fips('Fort Bend County', 'Texas') == '48157'

        assert self.af.get_county_fips('Beaufort County', 'North Carolina') == '37013'
        assert self.af.get_county_fips('Beauft. County', 'North Carolina') is None

    def test_district(self):
        assert self.af.get_county_fips("Manu'a District", "60") == "60020"


if __name__ == '__main__':
    unittest.main()
