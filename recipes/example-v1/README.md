# V1 recipe format

This recipe is an example of the v1 recipe format that was defined by
[CEP 13](https://github.com/conda/ceps/blob/main/cep-0013.md) and
[CEP 14](https://github.com/conda/ceps/blob/main/cep-0014.md).
The v1 recipe format currently requires rattler-build as a build tool.

Conda-forge's infrastructure has seen a steady stream of effort to ensure things work as usual with v1 recipes.
As of late 2025, v1 recipes are integrated without any major restrictions. The biggest missing feature is the
lack of [support](https://github.com/conda/ceps/pull/102) for a shared build step between multiple outputs,
though this is not relevant for most recipes.

See https://github.com/conda-forge/conda-forge.github.io/issues/2308 for progress on general support for this new format.
