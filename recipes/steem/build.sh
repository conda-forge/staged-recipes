#!/bin/bash

# install using pip from the whl file provided by pypi

pip install sphinxcontrib-restbuilder
pip install sphinxcontrib-programoutput
pip install pytest-pylint
python -m pip install --no-deps --ignore-installed .