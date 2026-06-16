# metaxy staged-recipes submission

Recipe submission for packaging [`metaxy`](https://pypi.org/project/metaxy/) on conda-forge.

## Files

- `recipe.yaml`: conda recipe for the PyPI sdist.
- `conda-forge.yml`: Pixi, `rattler-build`, and version PR automerge configuration.

## Validate

```shell
rattler-build build --recipe recipes/metaxy --channel https://conda.anaconda.org/conda-forge --render-only
```
