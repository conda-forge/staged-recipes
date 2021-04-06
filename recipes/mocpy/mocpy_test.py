from mocpy import MOC
from astropy.coordinates import SkyCoord
from astropy import units as u
coords = SkyCoord([(353.8156714, -56.33202193), (6.1843286, -56.33202193), (5.27558041, -49.49378172), (354.72441959, -49.49378172)], unit=u.deg)
moc = MOC.from_polygon_skycoord(coords)
assert not moc.empty()

