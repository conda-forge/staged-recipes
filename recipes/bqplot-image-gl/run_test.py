import sys

from notebook.nbextensions import validate_nbextension

if validate_nbextension('bqplot-image-gl/extension') != []:
    print("Issue detected with nbextension for bqplot-image-gl")
    sys.exit(1)

