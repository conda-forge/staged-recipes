# pyvips

This depends on the as-yet uncommitted `libvips` recipe.

pyvips can use cffi API mode, so it can compile a binary wrapper at install
time with setuptools. I'm not sure how to handle this with conda.

Because of this, pkgconfig is listed as a run-time dependency. Perhaps a
compiler should be listed too. Or maybe we can build the wrapper in `build`?


