try:
    import drmaa
except RuntimeError as e:
    assert str(e) == "Could not find drmaa library.  Please specify its full path using the environment variable DRMAA_LIBRARY_PATH"
