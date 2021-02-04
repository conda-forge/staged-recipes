# test_data directory

This directory contains input files for test cases. The structure of
subdirectories should be kept in sync with the structure of the
`text_extensions_for_pandas` package. For example, any files for the tests in
`text_extensions_for_pandas/spanner/test_join.py` should be in the directory
`test_data/spanner/test_join`.

There is also a top-level directory `test_data/common` to hold large data files
that are shared among many tests.

