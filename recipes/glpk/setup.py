from setuptools import setup, Extension
import os

library_dir = os.environ.get("LIBRARY_LIB", None)
# On Mac and Linux LIBRARY_LIB is not defined
if library_dir is None:
    library_dir = os.path.join(os.environ.get("PREFIX"), 'lib')


include_dir = os.environ.get("LIBRARY_INC", None)
# On Mac and Linux LIBRARY_INC is not defined
if include_dir is None:
    include_dir = os.path.join(os.environ.get("PREFIX"), 'include')


module = Extension("spam",
                   sources=["spam.c"],
                   include_dirs=[include_dir],
                   library_dirs=[library_dir],
                   libraries=["glpk"]
                   )

setup(name="spam",
      test_suite="spam.suite",
      ext_modules=[module])
