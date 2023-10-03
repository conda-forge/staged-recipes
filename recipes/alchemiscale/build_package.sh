# See https://github.com/conda-forge/napari-feedstock/blob/47ee53767779f4b3eb70e34ea3dd792408cb84a4/recipe/meta.yaml#L21 and https://github.com/conda/conda-build/issues/3993
PIP_NO_INDEX=True PIP_NO_DEPENDENCIES=True PIP_NO_BUILD_ISOLATION=False PIP_IGNORE_INSTALLED=True PYTHONDONTWRITEBYTECODE=True ${PYTHON} -m pip install . --no-deps -vv
