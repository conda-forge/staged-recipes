import pngpack
import sys

width = 3
height = 3
temp_data = [1, 1, 3,
             1, 2, 1,
             3, 1, 1]

bounds = pngpack.PngpackBounds(0, 360, -180, 180)

pp = pngpack.Pngpack(width, height, bounds, "pp-example")

channel = pngpack.PngpackChannel('temp', temp_data)
channel.add_textfield("units", "degrees")
pp.add_channel(channel)

result = pp.write('/dev/null')

if not result:
    sys.exit(1)
