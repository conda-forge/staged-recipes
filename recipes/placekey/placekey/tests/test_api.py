"""
Placekey API client tests.

To exclude slow tests run `pytest -m"not slow" placekey/tests/test_api.py`.
"""

import os
import unittest
import pytest
import random
from placekey.api import PlacekeyAPI


class TestAPI(unittest.TestCase):
    """
    Tests for api.py
    """

    @classmethod
    def setUpClass(cls):
        cls.api_key = os.getenv('PLACEKEY_API_KEY')

    def setUp(self):
        if not self.api_key:
            self.fail('The PLACEKEY_API_KEY environment variable must be set to run tests.')

        self.pk_api = PlacekeyAPI(
            api_key=self.api_key, user_agent_comment="placekey-py-tests")

    def test_lookup_placekey(self):
        """
        test lookup_placekey
        """
        # A lat/long query
        self.assertDictEqual(
            self.pk_api.lookup_placekey(latitude=37.7371, longitude=-122.44283),
            {'query_id': '0', 'placekey': '@5vg-82n-kzz'}
        )

        # An address query
        place = {
            "street_address": "598 Portola Dr",
            "city": "San Francisco",
            "region": "CA",
            "postal_code": "94131",
            "iso_country_code": "US"
        }
        self.assertDictEqual(
            self.pk_api.lookup_placekey(**place, strict_address_match=True),
            {'query_id': '0', 'placekey': '227@5vg-82n-pgk'}
        )

        # An invalid query
        bad_place = {
            "street_address": "598 Portola Dr",
            "city": "San Francisco",
            "region": "CA",
            "postal_code": "94131",
            "iso_country_code": "US",
            "something": "foo"
        }
        self.assertFalse(
            self.pk_api._validate_query(bad_place)
        )

    def test_lookup_placekeys(self):
        """
        Test lookup_placekeys

        This test also covers lookup_batch, as lookup_placekeys is a wrapper
        for that function.
        """
        places = [
            {
                "street_address": "1543 Mission Street, Floor 3",
                "city": "San Francisco",
                "region": "CA",
                "postal_code": "94105",
                "iso_country_code": "US"
            },
            {
                "query_id": "thisqueryidaloneiscustom",
                "location_name": "Twin Peaks Petroleum",
                "street_address": "598 Portola Dr",
                "city": "San Francisco",
                "region": "CA",
                "postal_code": "94131",
                "iso_country_code": "US"
            },
            {
                "latitude": 37.7371,
                "longitude": -122.44283
            }
        ]
        self.assertListEqual(
            self.pk_api.lookup_placekeys(places),
            [
                {'query_id': 'place_0', 'placekey': '226@5vg-7gq-5mk'},
                {'query_id': 'thisqueryidaloneiscustom', 'placekey': '227-222@5vg-82n-pgk'},
                {'query_id': 'place_2', 'placekey': '@5vg-82n-kzz'}
            ]
        )

    @pytest.mark.slow
    def test_lookup_placekeys_slow(self):
        """
        Longer running rate-limit test for lookup_placekeys. This should run and
        get a valid result for each item queried.
        """
        random.seed(1)
        num_samples = 10000
        lat_long_samples = [
            {'latitude': random.uniform(-90.0, 90.0), 'longitude': random.uniform(0.0, 180.0)}
            for _ in range(num_samples)
        ]
        results = self.pk_api.lookup_placekeys(lat_long_samples)
        self.assertEqual(len(results), num_samples)
        self.assertTrue(all(['placekey' in r for r in results]))
