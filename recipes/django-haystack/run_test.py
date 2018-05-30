# try to import haystack
# this will cause an error because Django is not setup
# but all we want conda-build to check for is that there
# is not an import error. This is a cheap altervative
# to running the full django-haystack test suite, which
# has a lot of dependencies and is relatively expensive.
try:
    import haystack
except ImportError:
    raise
except Exception:
    pass
