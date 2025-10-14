# rnnoise

## Windows Accommodation

This package uses the `autotools_clang_conda` on Windows to accommodate the build process.

This `autotools_clang_conda` package currently makes no accomdations
for builds using anthing other than `build.bat` (or `bld.bat`)
such as `build.nu` or `build.py`.

## Model Selection

The package build deviates from the upstream build process in that
it downloads the model source using the recipe.yaml source instead of
the download script.
This means that the model selection does not used the
https://gitlab.xiph.org/xiph/rnnoise/-/blob/v0.2/model_version?ref_type=tags
directly but rather specifies the model version in the recipe.yaml file.
