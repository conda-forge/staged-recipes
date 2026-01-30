# Conda-Forge Submission Instructions for BayeSED3 v2026.01.30

## Files Prepared

- `meta.yaml` - Conda recipe with version 2026.01.30 and SHA256
- `build.sh` - Build script for conda-forge

## Prerequisites

1. **GitHub Release Must Exist**
   - Tag: v2026.01.30
   - URL: https://github.com/hanyk/BayeSED3/releases/tag/v2026.01.30
   - If not created yet, run: `./release_with_gh.sh`

2. **Fork staged-recipes**
   - Go to: https://github.com/conda-forge/staged-recipes
   - Click "Fork" button

## Step-by-Step Submission

### 1. Clone Your Fork

```bash
git clone https://github.com/YOUR_USERNAME/staged-recipes.git
cd staged-recipes
git checkout -b bayesed3
```

### 2. Copy Recipe Files

```bash
mkdir -p recipes/bayesed3
cp /Users/hanyk/workplace/BayeSED3/../conda_forge_recipe/meta.yaml recipes/bayesed3/
cp /Users/hanyk/workplace/BayeSED3/../conda_forge_recipe/build.sh recipes/bayesed3/
```

### 3. Verify SHA256 (if needed)

If SHA256 was PLACEHOLDER_SHA256, calculate it:

```bash
curl -sL https://github.com/hanyk/BayeSED3/archive/refs/tags/v2026.01.30.tar.gz | shasum -a 256
```

Then update `recipes/bayesed3/meta.yaml` with the correct hash.

### 4. Test Build Locally (Optional but Recommended)

```bash
conda build recipes/bayesed3
```

### 5. Commit and Push

```bash
git add recipes/bayesed3/
git commit -m "Add bayesed3 recipe"
git push origin bayesed3
```

### 6. Create Pull Request

1. Go to: https://github.com/conda-forge/staged-recipes
2. Click "New Pull Request"
3. Select your fork and the `bayesed3` branch
4. Fill out the PR template:
   - Describe the package
   - Confirm you've read the guidelines
   - List yourself as maintainer
5. Submit the PR

### 7. Wait for Review

- conda-forge bots will run automated checks
- Maintainers will review (usually 1-7 days)
- Address any feedback or requested changes
- Once approved and merged, your package will be on conda-forge!

## After Acceptance

Once your PR is merged:

1. **Feedstock Created**
   - A new repo will be created: `conda-forge/bayesed3-feedstock`
   - You'll be added as a maintainer

2. **Future Updates Are Automatic**
   - Just create GitHub releases with `./release_with_gh.sh`
   - conda-forge bot detects releases and creates PRs automatically
   - You review and merge the bot's PRs
   - Package updates automatically

## Troubleshooting

**Q: Build fails with "sha256 mismatch"**

A: Recalculate SHA256:
```bash
curl -sL https://github.com/hanyk/BayeSED3/archive/refs/tags/v2026.01.30.tar.gz | shasum -a 256
```

**Q: Tests fail**

A: Check the CI logs for details. Common issues:
- Missing dependencies
- Import errors
- Platform-specific problems

**Q: Linter errors**

A: conda-forge has strict formatting requirements. Follow the error messages to fix.

## Resources

- **conda-forge docs:** https://conda-forge.org/docs/
- **Staged recipes:** https://github.com/conda-forge/staged-recipes
- **Guidelines:** https://conda-forge.org/docs/maintainer/adding_pkgs.html

## Current Recipe Details

- **Version:** 2026.01.30
- **SHA256:** d5558cd419c8d46bdc958064cb97f963d1ea793866414c025906ec15033512ed
- **Source URL:** https://github.com/hanyk/BayeSED3/archive/refs/tags/v2026.01.30.tar.gz
