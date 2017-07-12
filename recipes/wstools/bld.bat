@ECHO OFF
SET PBR_VERSION="%PKG_VERSION%"
python setup.py install --single-version-externally-managed --record record.txt
