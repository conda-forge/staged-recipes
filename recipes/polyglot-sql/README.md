# polyglot-sql staged-recipes submission

Recipe submission for packaging [`polyglot-sql`](https://pypi.org/project/polyglot-sql/) on conda-forge.

## Files

- `recipe.yaml`: conda recipe for the PyPI sdist.
- `conda-forge.yml`: Pixi, `rattler-build`, and version PR automerge configuration.
- `LICENSE`: upstream MIT license text because the PyPI sdist declares MIT but does not ship a license file.

## Validate

```shell
rattler-build build --recipe recipes/polyglot-sql --channel https://conda.anaconda.org/conda-forge --render-only --variant c_stdlib=macosx_deployment_target --variant python=3.12
```
