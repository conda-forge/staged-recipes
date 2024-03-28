#!/bin/bash
export PYMUPDF_SETUP_DEVENV="" 
export PYMUPDF_SETUP_MUPDF_TGZ="" 
python -m pip install . -vv --no-deps --no-build-isolation
