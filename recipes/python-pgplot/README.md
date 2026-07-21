# Conda-Forge Recipe for python-pgplot

This directory contains the conda-forge recipe for `python-pgplot`, a Python extension providing bindings for the PGPLOT graphics library via the giza backend.

## Files

- `meta.yaml` - Main conda recipe specification
- `build.sh` - Unix build script (Linux/macOS)
- `bld.bat` - Windows build script (currently disabled)

## Key Features

- **System dependency handling**: Automatically installs and links against giza from conda-forge
- **Cross-platform**: Supports Linux and macOS (Windows not supported due to giza availability)
- **Binary extension**: Builds C extension module with proper numpy integration
- **Comprehensive testing**: Verifies both Python import and C extension loading

## Dependencies

### Build Requirements
- C compiler
- pkg-config
- giza >=1.3.2 (from conda-forge)

### Runtime Requirements  
- Python
- NumPy (version-pinned for ABI compatibility)
- giza >=1.3.2

## Submission to conda-forge

To submit this recipe to conda-forge:

1. Fork the [conda-forge/staged-recipes](https://github.com/conda-forge/staged-recipes) repository
2. Create a new directory `recipes/python-pgplot/`
3. Copy `meta.yaml`, `build.sh`, and `bld.bat` to that directory
4. Submit a pull request

## Local Testing

To test this recipe locally with conda-build:

```bash
conda install conda-build
conda build conda-recipe/
```

## Notes

- Windows builds are disabled due to giza not being available on Windows in conda-forge
- The recipe uses the PyPI source distribution as the source
- pkg-config is used to locate giza headers and libraries
- The build includes verification that the C extension loads correctly
