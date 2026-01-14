# rnnoise

## Windows Accommodation

This package uses the `autotools_clang_conda` on Windows to accommodate the build process.

This `autotools_clang_conda` package currently makes no accomdations
for builds using anthing other than `build.bat` (or `bld.bat`)
such as `build.nu` or `build.py`.

## Model Selection

We assume you are generally familiar with neural-networks:
ref: en.wikipedia.org/wiki/Neural_network_(machine_learning)

The rnnoise is a neural network engine, 
there are several models which may (or may not) be compatible with a particular `rnnoise` engine.
A model consistes of weighted edges, which describe a trained neural network. 
There are several models created for rnnoise, 
some (but not all) were created by the author of rnnoise. 
This package contains a specific model, developed by the author.

The package build deviates from the upstream build process in that
it downloads the model source using the `recipe.yaml` source instead of a download script.
This means that the model selection does not used the

Models may be obtained by `gitlab` tags:
https://gitlab.xiph.org/xiph/rnnoise/-/blob/v0.2/model_version?ref_type=tags
