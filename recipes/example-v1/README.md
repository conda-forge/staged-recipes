
This recipe is an example of the v1 recipe format that was defined by CEP 13 and CEP 14. The v1 recipe format currently requires rattler-build as a build tool.

Conda-forge's infrastructure has seen a steady stream of effort to ensure things work as usual with v1 recipes. As of late 2025, v1 recipes are integrated without any major restrictions. The biggest missing feature is the lack of support for a shared build step between multiple outputs, though this is not relevant for most recipes.

See conda-forge/conda-forge.github.io#2308 for progress on general support for this new format.