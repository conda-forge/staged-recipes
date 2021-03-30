"""
Placekey tests. These can be ran by calling `python3 -m unittest placekey.tests.test_placekey`
in the parent directory of this repository.

"""

import unittest
import h3.api.basic_int as h3_int
from shapely.wkt import loads as wkt_loads
from shapely.geometry import shape
from shapely.ops import transform
import placekey.placekey as pk


class TestPlacekey(unittest.TestCase):
    """
    Tests for placekey.py
    """

    def setUp(self):
        def parse(line):
            tokens = line.split(',')
            return {
                "lat": float(tokens[0]),
                "long": float(tokens[1]),
                "h3_r10": tokens[2],
                "h3_int_r10": int(tokens[3]),
                "placekey": tokens[4],
                'h3_lat': float(tokens[5]),
                'h3_long': float(tokens[6]),
                'info': tokens[7]
            }

        with open('placekey/tests/example_geos.csv', 'r') as f:
            next(f)  # skip header
            self.sample = [parse(l.strip()) for l in f.readlines()]

        def parse_distances(line):
            tokens = line.split('\t')
            return {
                'placekey_1': tokens[0],
                'geo_1': [float(x) for x in tokens[1][1:-1].split(',')],
                'placekey_2': tokens[2],
                'geo_2': [float(x) for x in tokens[3][1:-1].split(',')],
                'distance': float(tokens[4]),
            }

        with open('placekey/tests/example_distances.tsv') as f:
            next(f)  # skip header
            self.distance_samples = [parse_distances(l.strip())
                                     for l in f.readlines()]

    def test_geo_to_placekey(self):
        """
        Test geo to Placekey conversion
        """
        for row in self.sample:
            self.assertEqual(
               pk.geo_to_placekey(row['lat'], row['long']), row['placekey'],
                "converted geo ({}, {}) did not match placekey ({})".format(
                    row['lat'], row['long'], row['placekey']))

    def test_placekey_to_geo(self):
        """
        Test Placekey to geo conversion
        """
        matching_places = 3
        for row in self.sample:
            lat, long = pk.placekey_to_geo(row['placekey'])
            self.assertAlmostEqual(
                lat, row['h3_lat'], matching_places,
                 "placekey's latitude ({}) too far from associated geo's latitude ({})".format(
                    lat,  row['h3_lat']))
            self.assertAlmostEqual(
                long, row['h3_long'], matching_places,
                 "placekey's longitude ({}) too far from associated geo's longitude ({})".format(
                    long, row['h3_long']))

    def test_placekey_to_h3(self):
        """
        Test Placekey to H3 conversion
        """
        for row in self.sample:
            self.assertEqual(
                pk.placekey_to_h3(row['placekey']), row['h3_r10'],
                "converted placekey ({}) did not match H3 at resolution 10 ({})".format(
                    pk.placekey_to_h3(row['placekey']), row['h3_r10']))

    def test_h3_to_placekey(self):
        """
        Test H3 to Placekey conversion
        """
        for row in self.sample:
            self.assertEqual(
                pk.h3_to_placekey(row['h3_r10']), row['placekey'],
                "converted h3 ({}) did not match placekey ({})".format(
                    pk.h3_to_placekey(row['h3_r10']), row['placekey']))

    def test_string_cleaning(self):
        """
        Test removal and reinsertion of bad words in strings
        """
        for bw, replacement in pk.REPLACEMENT_MAP:
            self.assertEqual(
                pk._dirty_string(pk._clean_string(bw)), bw,
                "dirty(clean()) not an identity mapping for {}".format(bw))
            self.assertEqual(
                pk._clean_string(pk._dirty_string(replacement)), replacement,
                "clean(dirty()) not an identity mapping for {}".format(replacement))

        self.assertEqual(pk._clean_string('vjngr'), "vjugu",
                         "clean overlapping bad words out of sequence order")
        self.assertEqual(pk._dirty_string('vjugu'), 'vjngr',
                         "dirty overlapping bad words out of sequence order")

        self.assertEqual(pk._clean_string('prngr'), "pregr",
                         "clean overlapping bad words in sequence order")
        self.assertEqual(pk._dirty_string('pregr'), 'prngr',
                         "dirty overlapping bad words in sequence order")

    def test_get_neighboring_placekeys(self):
        """
        Test generation of neighboring placekeys
        """
        key = '@5vg-7gq-tvz'
        neighbors_dist1 = {
            '@5vg-7gq-7nq',
            '@5vg-7gq-7t9',
            '@5vg-7gq-gx5',
            '@5vg-7gq-tjv',
            '@5vg-7gq-tvz',
            '@5vg-7gq-ty9',
            '@5vg-7gq-v2k'}

        self.assertSetEqual(pk.get_neighboring_placekeys(key, 0), {key},
                            "placekey is its only neighbor of distance 0")
        self.assertSetEqual(pk.get_neighboring_placekeys(key, 1), neighbors_dist1,
                            "placekey neighbors of distance 1 correct")

    def test_placekey_to_hex_boundary(self):
        """
        Test placekey to geo boundary conversion
        """
        key = '@5vg-7gq-tvz'
        h3_integer = pk.placekey_to_h3_int(key)
        self.assertTupleEqual(
            pk.placekey_to_hex_boundary(key, geo_json=True),
            h3_int.h3_to_geo_boundary(h3_integer, geo_json=True),
            "placekey boundary equal to H3 boundary (geo_json=True)")
        self.assertTupleEqual(
            pk.placekey_to_hex_boundary(key, geo_json=False),
            h3_int.h3_to_geo_boundary(h3_integer, geo_json=False),
            "placekey boundary equal to H3 boundary (geo_json=False)")

    def test_placekey_to_wkt(self):
        """
        Test Placekey to WKT conversion
        """
        key = '@5vg-7gq-tvz'
        wkt = (
               'POLYGON ((37.77804284141394 -122.4188730164743, '
               '37.77820687262237 -122.4197189541481, '
               '37.77887710717697 -122.4199258090291, '
               '37.77938331431949 -122.4192867193292, '
               '37.77921928451977 -122.4184407703954, '
               '37.77854904616886 -122.4182339224218, '
               '37.77804284141394 -122.4188730164743))'
               )
        pk_wkt = pk.placekey_to_wkt(key, geo_json=False)
        try:
            self.assertEqual(pk_wkt, wkt, 'correct WKT conversion')
        except AssertionError:
            # Depending on the system there may be small variations in the least
            # significant digits of the polygon vertices. This check verifies
            # that the resulting polygons
            pk_poly = wkt_loads(pk_wkt)
            wkt_poly = wkt_loads(wkt)
            self.assertTrue(pk_poly.almost_equals(wkt_poly, decimal=12))

    def test_placekey_to_geojson(self):
        """
        Test Placekey to GeoJSON conversion
        """
        key = '@5vg-7gq-tvz'  # centroid: (lat=37.77871308025089, long=-122.41907986670626)

        # Recall that GeoJSON specifies coordinates as (long, lat)
        geo_json = {
            'type': 'Polygon',
            'coordinates': ((
                (-122.41887301647432, 37.77804284141394),
                (-122.41823392242185, 37.77854904616886),
                (-122.41844077039543, 37.77921928451977),
                (-122.41928671932915, 37.77938331431949),
                (-122.41992580902914, 37.77887710717697),
                (-122.41971895414808, 37.77820687262237),
                (-122.41887301647432, 37.77804284141394)),)
        }
        pk_geojson = pk.placekey_to_geojson(key)
        try:
            self.assertEqual(pk_geojson, geo_json, 'correct GeoJSON conversion')
        except AssertionError:
            # Depending on the system there may be small variations in the least
            # significant digits of the polygon vertices. This check verifies
            # that the resulting polygons
            pk_poly = shape(pk_geojson)
            geojson_poly = shape(geo_json)
            self.assertTrue(pk_poly.almost_equals(geojson_poly, decimal=12))

    def test_placekey_format_is_valid(self):
        """
        Test format validation for Placekeys
        """
        self.assertTrue(pk.placekey_format_is_valid('5vg-7gq-tvz'),
                        'where with no @')
        self.assertTrue(pk.placekey_format_is_valid('@5vg-7gq-tvz'),
                        'where with @')
        self.assertTrue(pk.placekey_format_is_valid('zzz@5vg-7gq-tvz'),
                        'single tuple what with where')
        self.assertTrue(pk.placekey_format_is_valid('222-zzz@5vg-7gq-tvz'),
                        'double tuple what with where')

        self.assertFalse(pk.placekey_format_is_valid('@abc'), 'short where part')
        self.assertFalse(pk.placekey_format_is_valid('abc-xyz'), 'short where part')
        self.assertFalse(pk.placekey_format_is_valid('abcxyz234'), 'no dashes')
        self.assertFalse(pk.placekey_format_is_valid('abc-345@abc-234-xyz'),
                         'padding character in what')
        self.assertFalse(pk.placekey_format_is_valid('ebc-345@abc-234-xyz'),
                         'replacement character in what')
        self.assertFalse(pk.placekey_format_is_valid('bcd-345@'),
                         'missing what part')
        self.assertFalse(pk.placekey_format_is_valid('22-zzz@abc-234-xyz'),
                         'short what part')

        self.assertFalse(pk.placekey_format_is_valid('@abc-234-xyz'), 'invalid where value')

    def test_where_part_is_valid(self):
        """
        Test validation of where parts
        """
        self.assertTrue(pk._where_part_is_valid('5vg-7gq-tvz'),
                        "recognize valid where part")
        self.assertFalse(pk._where_part_is_valid('5vg-7gq-tva'),
                         "recognize where part with invalid format")
        self.assertFalse(pk._where_part_is_valid('zzz-zzz-zzz'),
                         "recognize where part with invalid h3 integer value")


    def test_placekey_distance(self):
        """
        Test distance computation between two Placekeys
        """
        self.assertEqual(
            pk.placekey_distance(
                pk.geo_to_placekey(0.0, 0.0), pk.geo_to_placekey(0.0, 0.0)),
            0.0,
            "identical points have distance 0")

        for i, sample in enumerate(self.distance_samples):
            difference = abs(
                pk.placekey_distance(sample['placekey_1'], sample['placekey_2']) -
                (sample['distance'] * 1000)
            )
            self.assertLessEqual(
                difference, 100,
                "distances too far apart ({})".format(i))

    def test_polygon_to_placekeys(self):
        """
        Test generation of placekeys that intersect a polygon
        """
        # Polygon is identical to the boundary of a single Placekey
        geo = (51.509865, -0.118092)  # London
        poly = pk.placekey_to_polygon(pk.geo_to_placekey(*geo))
        keys_no_touching = pk.polygon_to_placekeys(poly, include_touching=False)
        keys_touching = pk.polygon_to_placekeys(poly, include_touching=True)

        self.assertCountEqual(
            keys_no_touching['interior'], ['@4hh-zvh-66k'],
            "interior plackeys don't match")
        self.assertCountEqual(
            keys_no_touching['boundary'], (),
            "boundary plackeys don't match (no touching)")
        self.assertCountEqual(
            keys_touching['boundary'],
            ('@4hh-zvh-649', '@4hh-zvh-ffz', '@4hh-zvh-fs5', '@4hh-zvh-6hq',
             '@4hh-zvh-gx5', '@4hh-zvh-6c5'),
            "boundary plackeys don't match (touching)")
        self.assertCountEqual(
            keys_no_touching['interior'], keys_touching['interior'],
            "allow_touching flag doesn't impact interior"
        )

        # Polygon contains no Placekey hexagons (it is a shrunk and translated
        # resolution 10 hexagon)
        poly = wkt_loads(
            'POLYGON ((40.74001974100619 -73.9349274413473, '
            '40.73989965751763 -73.93565632113229, '
            '40.73939022508482 -73.93588138346178, '
            '40.73900088156213 -73.93537758083224, '
            '40.73912096147669 -73.93464871779295, '
            '40.73963038848786 -73.93442364063776, '
            '40.74001974100619 -73.9349274413473))')
        keys = pk.polygon_to_placekeys(poly)
        self.assertEqual(keys['interior'], (), "no interior placekeys")
        self.assertCountEqual(
            keys['boundary'],
            ('@627-s8p-vmk', '@627-s8p-xyv', '@627-s8p-xt9', '@627-s8p-vfz'),
            "boundary placekey sets not equal"
        )

        # This tests the WKT and GeoJSON wrappers
        geo = (41.2565, 95.9345)
        poly = pk.placekey_to_polygon(pk.geo_to_placekey(*geo)).buffer(0.01)  # (lat, long)-tuples

        poly_keys = pk.polygon_to_placekeys(poly, include_touching=False, geo_json=False)

        wkt_keys = pk.wkt_to_placekeys(poly.wkt, include_touching=False, geo_json=False)

        # GeoJSON uses (long, lat) tuples. We'll test doing it both ways with the geo_json parameter.
        conformant_geojson_keys = pk.geojson_to_placekeys(
            transform(lambda lat, long: (long, lat), poly),
            include_touching=False,
            geo_json=True
        )

        non_conformant_geojson_keys = pk.geojson_to_placekeys(
            poly, include_touching=False, geo_json=False)

        self.assertCountEqual(poly_keys['interior'], wkt_keys['interior'],
                              "poly and wkt conversions' interiors don't match")
        self.assertCountEqual(poly_keys['interior'], conformant_geojson_keys['interior'],
                              "poly and conformant geojson conversions' interiors don't match")
        self.assertCountEqual(poly_keys['interior'], non_conformant_geojson_keys['interior'],
                              "poly and non-conformant geojson conversions' interiors don't match")

        self.assertCountEqual(poly_keys['boundary'], wkt_keys['boundary'],
                              "poly and wkt conversions' interiors don't match")
        self.assertCountEqual(poly_keys['boundary'], conformant_geojson_keys['boundary'],
                              "poly and conformant geojson conversions' interiors don't match")
        self.assertCountEqual(poly_keys['boundary'], non_conformant_geojson_keys['boundary'],
                              "poly and non-conformant geojson conversions' interiors don't match")
