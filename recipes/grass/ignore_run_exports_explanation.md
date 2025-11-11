# Understanding `ignore_run_exports` in GRASS Conda Recipe

## Why List Libraries in `ignore_run_exports` That ARE Actually Used?

This seems contradictory at first, but there's important reasoning behind it.

## What's Happening Here

These libraries are **definitely used** by GRASS, but they're listed in `ignore_run_exports` to prevent conda-build's **automatic dependency constraint propagation**.

## Understanding `run_exports`

When a conda package is built, it can declare `run_exports` to say: *"If you build against me, you must also run with me (or compatible versions)"*. 

For example:
- When you list `gdal` in `host:`, GDAL's package says: *"Add `gdal >=3.11.0,<3.12.0a0` to the run dependencies automatically"*
- This happens for **every package** with `run_exports` metadata

## The Problem with Auto-Generated Constraints

Without `ignore_run_exports`, conda-build would automatically add **very strict version pins** like:

```yaml
run:
  - gdal >=3.11.0,<3.12.0a0
  - libtiff >=4.6.0,<4.7.0a0
  - numpy >=1.23.5,<2.0a0
  - python >=3.11,<3.12.0a0
  # ... and 13 more ultra-strict pins
```

## Why This Is Bad for GRASS

### 1. Over-Constraining Users
GRASS might work fine with `gdal 3.9`, `3.10`, `3.11`, or even `3.12`, but auto-pins would force exactly `3.11.x`

### 2. Dependency Hell
With 17 packages having strict auto-pins, finding a compatible environment becomes **nearly impossible**:

```
Cannot solve environment:
- grass needs gdal >=3.11.0,<3.12.0a0
- qgis needs gdal >=3.10.0,<3.11.0a0
- Solution: impossible
```

### 3. Manual Control
By ignoring auto-exports, you can specify **looser, more flexible** constraints in the `run:` section

## What You Actually Specified in `run:`

Looking at the `run:` section:

```yaml
run:
  - gdal          # No version constraint! Any gdal in conda-forge works
  - numpy         # No version constraint!
  - python        # No version constraint!
  - libtiff       # No version constraint!
```

This means: *"GRASS needs these libraries, but we trust they maintain backwards compatibility, so any recent version is fine"*

## The Strategy

```
ignore_run_exports           →  Blocks automatic strict pins
+                            
Manual entries in run:       →  Add flexible, user-friendly constraints
=
Better package usability
```

## Why These Specific 17 Packages?

Looking at the list, these fall into categories:

1. **Core geospatial libraries** (gdal, pdal): Maintain API stability across minor versions
2. **Common system libraries** (zlib, expat, sqlite): Extremely stable ABIs
3. **Build-only tools** (python, numpy in some contexts): Version at runtime can differ from build
4. **X11 protocol headers** (xorg-xextproto): Just header files, no runtime linking
5. **Low-level libraries** (pixman, freetype): Stable ABIs, rare breaking changes

## What About Libraries NOT in `ignore_run_exports`?

Notice what's **missing** from the ignore list:

- `geos` - Not ignored because GEOS has more volatile ABI changes
- `proj` - Not ignored because coordinate transformations are version-sensitive
- `cairo`, `fftw`, `blis` - Not ignored, possibly more strict ABI requirements

For these, you **want** the automatic version constraints because compatibility is more fragile.

## Real-World Example

### Without `ignore_run_exports`:
```bash
$ conda install grass qgis gdal=3.10
Error: grass requires gdal >=3.11.0,<3.12.0a0
```

### With `ignore_run_exports`:
```bash
$ conda install grass qgis gdal=3.10
Success! GRASS works fine with GDAL 3.10
```

## Summary

These libraries **ARE used** by GRASS, but you're:

1. **Ignoring automatic over-constraining** from conda-build
2. **Manually specifying flexible constraints** (or no constraints) in `run:`
3. **Trusting library maintainers** to maintain backwards compatibility
4. **Making GRASS easier to install** alongside other geospatial tools

It's a balance between **ensuring dependencies exist** vs **not being so strict that installation becomes impossible**!
