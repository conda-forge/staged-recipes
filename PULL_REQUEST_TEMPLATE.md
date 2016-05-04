Recipes added with this pull request (max 5):
 
 - package1
 - package2
 
I have checked the following in my recipes:
* [ ] My files end with only 1 newline character, no more, no less.
* [ ] My recipe follow the same style as [example](https://github.com/conda-forge/staged-recipes/blob/master/recipes/example/meta.yaml) as much as possible.
* [ ] The license field also specifies the number of the license if applicable (e.g. `GPLv3` instead of `GPL` or `BSD 3-clause` instead of `BSD`).
* [ ] My recipe has tests.
* [ ] I have looked at [pinned packages](https://github.com/conda-forge/staged-recipes/wiki/Pinned-dependencies) and pinned those packages as stated.
* [ ] The `summary` just explains the package and does not include the package name. (e.g. Instead of saying `Jupyterhub is a multi-user server for Jupyter notebooks` just say `Multi-user server for Jupyter notebooks`)

If you build for Windows too:
* [ ] I have read [VC features](https://github.com/conda-forge/staged-recipes/wiki/VC-features) 

If recipe uses make:
* [ ] I have also added `make check` or similar if applicable.

If recipe builds a library:
* [ ] I have enabled both static and shared libraries.

If recipe builds some C/C++ code:
* [ ] I have not included `gcc` or `libgcc` in `requirements`. Exceptions can be made but must be tested first with `gcc`/`clang` that is already installed in our CI machines.

If it is Python Pypi package:
* [ ] I have used `pip` to install it and my recipe has these elements:
```yaml
build:
  script: pip install --no-deps .
requirements:
  build:
    - python
    - pip
  run:
    - python
```
