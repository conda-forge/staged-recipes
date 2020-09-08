from turbojpeg import TurboJPEG
import requests

url = "https://upload.wikimedia.org/wikipedia/commons/9/98/03-bryone-dioique.jpg"
r = requests.get(url, allow_redirects=True)

jpeg = TurboJPEG()

with open("03-bryone-dioique.jpg", "wb") as test_file:
    test_file.write(r.content)

with open("03-bryone-dioique.jpg", "rb") as in_file:
    bgr_array = jpeg.decode(in_file.read())

with open("output.jpg", "wb") as out_file:
    out_file.write(jpeg.encode(bgr_array))
