# Hydra


https://github.com/CategoricalData/hydra

It uses source from [Hydra](https://github.com/CategoricalData/hydra/tags).

## Recipe Format

For more information about this format see:
* https://prefix-dev.github.io/rattler-build/latest/reference/recipe_file/
* https://github.com/prefix-dev/recipe-format

## Testing

### Option 1: Provide the recipe name

```bash
AZURE=True pixi run python build-locally.py linux64 --recipes hydra-python
```

### Option 2: Navigate to the target reciple and build from there

```bash
cd recipes/hydra-python
AZURE=True pixi run python ../../build-locally.py linux64
```

### Option 3: Use rattler-build directly

```bash
pixi run rattler-build build --recipe-dir recipes/hydra-python --target-platform linux-64
```
