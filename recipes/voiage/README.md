# voiage conda-forge Recipe

This is the sole Conda recipe for the native Maturin package and the handoff
source for publishing voiage to conda-forge. The release workflow replaces its
version and source hash only after the immutable PyPI sdist is published.

## Building the conda package

To build the conda package locally:

```bash
# Install conda-build
conda install -n base conda-build

# Build the package
conda build conda-recipe

# Install the built package
conda install -c local voiage
```

## Publishing to conda-forge

To publish to conda-forge:

1. Fork the [conda-forge/staged-recipes](https://github.com/conda-forge/staged-recipes) repository
2. Copy this recipe directory to `recipes/voiage` in the forked repository
3. Submit a pull request to `conda-forge/staged-recipes`; the recipe is pinned
   to the published `voiage 1.0.0` sdist and its verified SHA256 hash.

## Recipe Structure

- `meta.yaml`: Main recipe file with package metadata and dependencies

## Dependencies

The recipe specifies the following dependencies:

### Host Dependencies
- python >=3.12
- pip
- maturin >=1.9,<2.0
- a conda-forge Rust compiler

### Run Dependencies
- python >=3.12
- click, numpy, scipy, pandas, xarray, scikit-learn
- pyarrow, polars, pydantic, typing_extensions, typer

## Testing

The recipe includes tests to verify:
- Package imports correctly
- Command-line interface works
- All required dependencies are properly specified
