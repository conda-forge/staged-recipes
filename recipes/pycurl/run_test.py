import curl
import pycurl
try:
    from cStringIO import StringIO as BytesIO
except:
    from io import BytesIO


buf = BytesIO()

c = pycurl.Curl()
c.setopt(c.URL, 'https://repo.continuum.io/')
c.setopt(c.WRITEFUNCTION, buf.write)
c.perform()

print(buf.getvalue())
assert b'Anaconda, Inc.' in buf.getvalue()
buf.close()
