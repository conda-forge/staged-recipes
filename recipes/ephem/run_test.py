import ephem

mars = ephem.Mars()
mars.compute('2008/1/1')
assert str(mars.ra) == '5:59:27.35'
assert str(mars.dec) == '26:56:27.4'
