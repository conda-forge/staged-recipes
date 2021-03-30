"""
Functionality for converting between Placekeys and geos (latitude, longitude tuples) or
H3 indices. This module also includes additional utilities related to Placekeys.

"""

import re
import json
from math import asin, cos, radians, sqrt

import h3
import h3.api.basic_int as h3_int
from shapely.geometry import mapping, shape, Polygon, polygon
from shapely.ops import transform
from shapely.strtree import STRtree
from shapely.wkt import loads as wkt_loads


RESOLUTION = 10
BASE_RESOLUTION = 12
ALPHABET = '23456789BCDFGHJKMNPQRSTVWXYZ'.lower()
ALPHABET_LENGTH = len(ALPHABET)
CODE_LENGTH = 9
TUPLE_LENGTH = 3
PADDING_CHAR = 'a'
REPLACEMENT_CHARS = "eu"
REPLACEMENT_MAP = (
    ("prn", "pre"),
    ("f4nny", "f4nne"),
    ("tw4t", "tw4e"),
    ("ngr", "ngu"),  # 'u' avoids introducing 'gey'
    ("dck", "dce"),
    ("vjn", "vju"),  # 'u' avoids introducing 'jew'
    ("fck", "fce"),
    ("pns", "pne"),
    ("sht", "she"),
    ("kkk", "kke"),
    ("fgt", "fgu"),  # 'u' avoids introducing 'gey'
    ("dyk", "dye"),
    ("bch", "bce")
)
HEADER_BITS = bin(h3_int.geo_to_h3(0.0, 0.0, resolution=RESOLUTION))[2:].zfill(64)[:12]
BASE_CELL_SHIFT = 2 ** (3 * 15)    # Adding this will increment the base cell value by 1
UNUSED_RESOLUTION_FILLER = 2 ** (3 * (15 - BASE_RESOLUTION)) - 1
FIRST_TUPLE_REGEX = '[' + ALPHABET + REPLACEMENT_CHARS + PADDING_CHAR + ']{3}'
TUPLE_REGEX = '[' + ALPHABET + REPLACEMENT_CHARS + ']{3}'
WHERE_REGEX = re.compile(
    '^' + '-'.join([FIRST_TUPLE_REGEX, TUPLE_REGEX, TUPLE_REGEX]) + '$')
WHAT_REGEX = re.compile('^[' + ALPHABET + ']{3}(-[' + ALPHABET + ']{3})?$')


def _get_header_int():
    """
    :return: An integer corresponding to the header of an H3 integer
    """
    header_int = 0
    for i, b in enumerate(HEADER_BITS[::-1]):
        header_int = header_int + int(b) * 2 ** i
    header_int *= 2 ** 52
    return header_int


HEADER_INT = _get_header_int()


def geo_to_placekey(lat, long):
    """
    Convert latitude and longitude into a Placekey.

    :param lat: Latitude (float)
    :param long: Longitude (float)
    :return: Placekey (string)

    """
    return _encode_h3_int(h3_int.geo_to_h3(lat, long, resolution=RESOLUTION))


def placekey_to_geo(placekey):
    """
    Convert a Placekey into a (latitude, longitude) tuple.

    :param placekey: Placekey (string)
    :return: (latitude, longitude) as a tuple of floats

    """
    return h3.h3_to_geo(placekey_to_h3(placekey))


def placekey_to_h3(placekey):
    """
    Convert a Placekey string into an H3 string.

    :param placekey: Placekey (string)
    :return: H3 (string)

    """
    _, where = _parse_placekey(placekey)
    return h3.h3_to_string(_decode_to_h3_int(where))


def h3_to_placekey(h3_string):
    """
    Convert an H3 hexadecimal string into a Placekey string.

    :param h3_string: H3 (string)
    :return: Placekey (string)

    """
    return _encode_h3_int(h3.string_to_h3(h3_string))


def get_prefix_distance_dict():
    """
    Return a dictionary mapping the length of a shared Placekey prefix to the
    maximal distance in meters between two Placekeys sharing a prefix of that length.

    :return: Dictionary mapping prefix length -> distance (m)

    """
    return {
        0: 2.004e7,
        1: 2.004e7,
        2: 2.777e6,
        3: 1.065e6,
        4: 1.524e5,
        5: 2.177e4,
        6: 8227.0,
        7: 1176.0,
        8: 444.3,
        9: 63.47
    }


def h3_int_to_placekey(h3_integer):
    """
    Convert an H3 integer into a Placekey.

    :param h3_integer: H3 index (int)
    :return: Placekey (string)

    """
    return _encode_h3_int(h3_integer)


def placekey_to_h3_int(placekey):
    """
    Convert a Placekey to an H3 integer.

    :param placekey: Placekey (string)
    :return: H3 index (int)

    """
    _, where = _parse_placekey(placekey)
    return _decode_to_h3_int(where)


def get_neighboring_placekeys(placekey, dist=1):
    """
    Return the unordered set of Placekeys whose grid distance is `<= dist` from the given
    Placekey. In this context, grid distance refers to the number of H3 cells between
    two H3 cells, so that neighboring cells have distance 1, neighbors of neighbors have
    distance 2, etc.

    :param placekey: Placekey (string)
    :param dist: size of the neighborhood around the input Placekey to return (int)
    :return: Set of Placekeys (set)

    """
    h3_integer = placekey_to_h3_int(placekey)
    neighboring_h3 = h3_int.k_ring(h3_integer, dist)
    return {h3_int_to_placekey(h) for h in neighboring_h3}


def placekey_to_hex_boundary(placekey, geo_json=False):
    """
    Given a Placekey, return the coordinates of the boundary of the hexagon.

    :param placekey: Placekey (string)
    :param geo_json: If True return the coordinates in GeoJSON format:
        (long, lat)-tuples and with the first and last tuples identical, and in
        counter-clockwise orientation. If False (default) tuples will be
        (lat, long), the last tuple will not equal the first, and the orientation
        will be clockwise.
    :return: Tuple of tuples ((float, float),...).

    """
    h3_integer = placekey_to_h3_int(placekey)
    return h3_int.h3_to_geo_boundary(h3_integer, geo_json=geo_json)


def placekey_to_polygon(placekey, geo_json=False):
    """
    Get the boundary shapely Polygon for a Placekey.

    :param place_key: Placekey (string)
    :param geo_json: If True return the coordinates in GeoJSON format:
        (long, lat)-tuples and with the first and last tuples identical, and in
        counter-clockwise orientation. If False (default) tuples will be
        (lat, long), the last tuple will not equal the first, and the orientation
        will be clockwise.
    :return: A shapely Polygon object

    """
    return polygon.orient(
        Polygon(placekey_to_hex_boundary(placekey, geo_json=geo_json)),
        sign=1)


def placekey_to_wkt(placekey, geo_json=False):
    """
    Convert a Placekey into the WKT (Well-Known Text) string for the
    corresponding hexagon. Coordinates are (longitude, latitude).

    :param placekey: Placekey (string)
    :param geo_json: If True return the coordinates in GeoJSON format:
        (long, lat)-tuples and with the first and last tuples identical, and in
        counter-clockwise orientation. If False (default) tuples will be
        (lat, long), the last tuple will not equal the first, and the orientation
        will be clockwise.
    :return: WKT (Well-Known Text) polygon (string)
    """
    return placekey_to_polygon(placekey, geo_json=geo_json).wkt


def placekey_to_geojson(placekey):
    """
    Convert a Placekey into a GeoJSON dicitonary. Note that GeoJSON uses
    (longitude, latitude) points, and the first and last points are identical.

    :param placekey: Placekey (string)
    :return: Dictionary describing the polygon in GeoJSON format
    """
    return mapping(placekey_to_polygon(placekey, geo_json=True))



def polygon_to_placekeys(poly, include_touching=False, geo_json=False):
    """
    Given a shapely Polygon, return Placekeys contained in
    or intersecting the boundary of the polygon.

    :param poly: shapely Polygon object
    :param include_touching: If True Placekeys whose hexagon boundary only touches
        that of the input polygon are included in the set of boundary Placekeys.
        Default is False.
    :param geo_json: If True assume coordinates in `poly` are in GeoJSON format:
        (long, lat)-tuples and with the first and last tuples identical, and in
        counter-clockwise orientation. If False (default) assumes tuples will be
        (lat, long).
    :return: A dictionary with keys 'interior' and 'boundary' whose values are
        tuples of Placekeys that are contained in poly or which intersect the
        boundary of poly respectively.

    """
    if geo_json:
        poly = transform(lambda x, y: (y, x), poly)

    buffer_size = 2e-3
    buffered_poly = poly.buffer(buffer_size)
    candidate_hexes = h3_int.polyfill(mapping(buffered_poly), 10)

    tree = STRtree([poly])
    interior_hexes = []
    boundary_hexes = []
    for h in list(candidate_hexes):
        hex_poly = Polygon(h3_int.h3_to_geo_boundary(h))
        if len(tree.query(hex_poly)) > 0:
            if poly.contains(hex_poly):
                interior_hexes.append(h)
            elif poly.intersects(hex_poly):
                if include_touching:
                    boundary_hexes.append(h)
                elif not include_touching and not poly.touches(hex_poly):
                    boundary_hexes.append(h)

    return {
        'interior': tuple(h3_int_to_placekey(h) for h in interior_hexes),
        'boundary': tuple(h3_int_to_placekey(h) for h in boundary_hexes)
    }


def wkt_to_placekeys(wkt, include_touching=False, geo_json=False):
    """
    Given a WKT description of a polygon, return Placekeys contained in
    or intersecting the boundary of the polygon.

    :param wkt: Well-Known Text object (string)
    :param include_touching: If True Placekeys whose hexagon boundary only touches
        that of the input polygon are included in the set of boundary Placekeys.
        Default is False.
    :param geo_json: If True assume coordinates in `poly` are in GeoJSON format:
        (long, lat)-tuples and with the first and last tuples identical, and in
        counter-clockwise orientation. If False (default) assumes tuples will be
        (lat, long).

    :return: List of Placekeys

    """
    return polygon_to_placekeys(
        wkt_loads(wkt), include_touching=include_touching, geo_json=geo_json)


def geojson_to_placekeys(geojson, include_touching=False, geo_json=True):
    """
    Given a GeoJSON description of a polygon, return Placekeys contained in
    or intersecting the boundary of the polygon.

    :param geo_json: GeoJSON object (string or dict). Note this function assumes coordinate
        tuples are (long, lat)
    :param include_touching: If True Placekeys whose hexagon boundary only touches
        that of the input polygon are included in the set of boundary Placekeys.
        Default is False.
    :param geo_json: If True (default) assume coordinates in `poly` are in GeoJSON format:
        (long, lat)-tuples and with the first and last tuples identical, and in
        counter-clockwise orientation. If False assumes tuples will be
        (lat, long).
    :return: List of Placekeys

    """
    if isinstance(geojson, str):
        poly = shape(json.loads(geojson))
    else:
        poly = shape(geojson)

    return polygon_to_placekeys(
        poly, include_touching=include_touching, geo_json=geo_json)


def placekey_format_is_valid(placekey):
    """
    Boolean for whether or not the format of a Placekey is valid, including
    checks for valid encoding of location.

    :param placekey: Placekey (string)
    :return: True if the Placekey is valid, False otherwise

    """
    what, where = _parse_placekey(placekey)

    if what:
        return _where_part_is_valid(where) and bool(WHAT_REGEX.match(what))
    else:
        return _where_part_is_valid(where)


def placekey_distance(placekey_1, placekey_2):
    """
    Return the distance in meters between the centers of two Placekeys.

    :param placekey_1: Placekey (string)
    :param placekey_2: Placekey (string)
    :return: distance in meters (float)

    """
    geo_1 = h3_int.h3_to_geo(placekey_to_h3_int(placekey_1))
    geo_2 = h3_int.h3_to_geo(placekey_to_h3_int(placekey_2))
    return _geo_distance(geo_1, geo_2)


def _parse_placekey(placekey):
    """
    Split a Placekey in to what and where parts.

    :param placekey: Placekey (string)
    :return: what (string), where (string)

    """
    if '@' in placekey:
        what, where = placekey.split('@')
    else:
        what, where = None, placekey

    return what, where


def _where_part_is_valid(where):
    """
    Boolean for whether or not the where part of a Placekey is valid.

    :param placekey: Placekey (string)
    :return: True if the Placekey's where part is valid, False otherwise

    """
    return (bool(WHERE_REGEX.match(where)) and
            h3_int.h3_is_valid(placekey_to_h3_int(where)))


def _geo_distance(geo_1, geo_2):
    earth_radius = 6371  # In km

    lat_1 = radians(geo_1[0])
    long_1 = radians(geo_1[1])
    lat_2 = radians(geo_2[0])
    long_2 = radians(geo_2[1])

    hav_lat = 0.5 * (1 - cos(lat_1 - lat_2))
    hav_long = 0.5 * (1 - cos(long_1 - long_2))
    radical = sqrt(hav_lat + cos(lat_1) * cos(lat_2) * hav_long)
    return 2 * earth_radius * asin(radical) * 1000


def _encode_h3_int(h3_integer):
    short_h3_integer = _shorten_h3_integer(h3_integer)
    encoded_short_h3 = _encode_short_int(short_h3_integer)

    clean_encoded_short_h3 = _clean_string(encoded_short_h3)
    if len(clean_encoded_short_h3) <= CODE_LENGTH:
        clean_encoded_short_h3 = str.rjust(clean_encoded_short_h3, CODE_LENGTH, PADDING_CHAR)

    return '@' + '-'.join(clean_encoded_short_h3[i:i + TUPLE_LENGTH]
                          for i in range(0, len(clean_encoded_short_h3), TUPLE_LENGTH))


def _encode_short_int(x):
    if x == 0:
        return ALPHABET[0]
    else:
        res = ''
        while x > 0:
            remainder = x % ALPHABET_LENGTH
            res = ALPHABET[remainder] + res
            x = x // ALPHABET_LENGTH
        return res


def _decode_to_h3_int(where_part):
    code = _strip_encoding(where_part)
    dirty_encoding = _dirty_string(code)
    short_h3_integer = _decode_string(dirty_encoding)
    return _unshorten_h3_integer(short_h3_integer)


def _decode_string(s):
    val = 0
    for i in range(len(s)):
        val += (ALPHABET_LENGTH ** i) * ALPHABET.index(s[-1 - i])
    return val


def _strip_encoding(s):
    s = s.replace('@', '').replace('-', '').replace(PADDING_CHAR, '')
    return s


def _shorten_h3_integer(h3_integer):
    """
    Shorten an H3 integer to only include location data up to the base resolution
    :param h3_integer: H3 integer (int)
    :return: shortened H3 integer
    """
    # Cuts off the 12 left-most bits that don't code location
    out = (h3_integer + BASE_CELL_SHIFT) % (2 ** 52)
    # Cuts off the rightmost bits corresponding to resolutions greater than the base resolution
    out = out >> (3 * (15 - BASE_RESOLUTION))
    return out


def _unshorten_h3_integer(short_h3_integer):
    unshifted_int = short_h3_integer << (3 * (15 - BASE_RESOLUTION))
    rebuilt_int = HEADER_INT + UNUSED_RESOLUTION_FILLER - BASE_CELL_SHIFT + unshifted_int
    return rebuilt_int


def _clean_string(s):
    # Replacement should be in order
    for k, v in REPLACEMENT_MAP:
        if k in s:
            s = s.replace(k, v)
    return s


def _dirty_string(s):
    # Replacement should be in (reversed) order
    for k, v in REPLACEMENT_MAP[::-1]:
        if v in s:
            s = s.replace(v, k)
    return s
