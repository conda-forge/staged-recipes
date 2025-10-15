# Linting Issues Fixed ✅

## Changes Made to recipes/grass/meta.yaml

### 1. Added {{ stdlib('c') }} ✅
Added the required C standard library dependency after the compiler declarations:
```yaml
requirements:
  build:
    - {{ compiler('c') }}
    - {{ compiler('cxx') }}
    - {{ stdlib('c') }}  # ← ADDED
```

### 2. Fixed Selector Spacing ✅
Changed `make # [unix]` to `make  # [unix]` (two spaces before #):
```yaml
    - make  # [unix]  # ← Fixed spacing
```

### 3. Added Empty Line at End ✅
Added a blank line at the end of the file after the last line.

## Summary

All three linting issues have been resolved:
- ✅ Selector spacing corrected (line 19)
- ✅ Empty line added at end of file
- ✅ {{ stdlib('c') }} dependency added

## Next Steps

```bash
# Check the changes
git diff recipes/grass/meta.yaml

# Add and commit
git add recipes/grass/meta.yaml
git commit -m "Fix conda-forge linting issues

- Add {{ stdlib('c') }} dependency
- Fix selector spacing on make dependency
- Add empty line at end of file
"

# Push to update your PR
git push origin grass-linux-8.4.1
```

The linter should now pass! ✅
