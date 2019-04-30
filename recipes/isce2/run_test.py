import isce

def testStripmapReaders():
    from isceobj.Sensor import SENSORS
    for k,v in SENSORS.items():
        if not k.startswith('ERS_ENVISAT'): #Fixed for next release
            print('Sensor: {0}'.format(k))
            obj = v()

def testTOPSReaders():
    from isceobj.Sensor.TOPS import SENSORS
    for k,v in SENSORS.items():
        print('TOPS Sensor: {0}'.format(k))
        obj = v()

def testGeometryModules():
    from zerodop.topozero.Topozero import Topo
    from zerodop.geo2rdr.Geo2rdr import Geo2rdr
    from zerodop.geozero.Geozero import Geocode

def testCythonOpenCV():
    from contrib.splitSpectrum import SplitRangeSpectrum

if __name__ == '__main__':

    testStripmapReaders()
    testTOPSReaders()
    testGeometryModules()
    testCythonOpenCV()
