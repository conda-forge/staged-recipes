""" Tests for python-geohash conda-forge recipe
"""
# Library import
import geohash

# Ensure C extension works
assert geohash._geohash is not None


POINTS_GEOHASH = {
    # lat, lon, precision
    (42.6, -5.6, 12): 'ezs42e44yx96'
}
GEOHASH_POINTS = {
    'ezs42': (42.60498046875, -5.60302734375)
}


for pt, gh in POINTS_GEOHASH.items():
    ans = geohash.encode(*pt)
    assert ans == gh


for gh, pt in GEOHASH_POINTS.items():
    ans = geohash.decode(gh)
    assert ans[0] == pt[0]
    assert ans[1] == pt[1]
