#!/bin/bash

# install using pip from the whl file provided by pypi

pip install scrypt==0.8.0
pip install sphinxcontrib-restbuilder
pip install sphinxcontrib-programoutput
python -m pip install --no-deps --ignore-installed .