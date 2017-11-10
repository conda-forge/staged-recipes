try:
    import dask_drmaa
except RuntimeError as e:
    assert str(e) == "Could not find drmaa library.  Please specify its full path using the environment variable DRMAA_LIBRARY_PATH"

try:
    import dask_drmaa.cli
except RuntimeError as e:
    assert str(e) == "Could not find drmaa library.  Please specify its full path using the environment variable DRMAA_LIBRARY_PATH"
