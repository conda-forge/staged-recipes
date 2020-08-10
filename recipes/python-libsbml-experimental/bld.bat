SET LIBSBML_EXPERIMENTAL=1
SET CMAKE_BUILD_PARALLEL_LEVEL=4
%PYTHON% setup.py install --single-version-externally-managed --record=record.txt
