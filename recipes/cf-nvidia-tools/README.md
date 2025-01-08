# cf-nvidia-tools

This package contains CLI tools for validating and linting NVIDIA's conda recipes on
conda-forge. The tools are hosted directly in this feedstock; there is no external source
code repository for these tools at this time.

## API policy

This project will use semantic versioning, and will not have a beta release. In other words,
it should be safe to pin this tool with an expression like `>=1.0,<2`. Backward incompatible
changes for any tool in this package will be accompanied by a major version bump. New
features will increase the minor version. Anything considered a bug fix will be a patch
release.

## check-glibc

### When to use this tool

The package is binary redistrbution which links to glibc.

### Why is this tool needed

For NVIDIA conda packages which are redists (binary redistributions) there is no compiling
when building the package, so we do not automatically know if the glibc provided by `{{
stdlib('c') }}` is new enough for the binaries in the package. If we don't set a new enough
version for `c_stdlib_version`, end users can get undefined symbol errors. This tool is used
for checking that a binary redist has correctly specified the c_stdlib_version variable in
the recipe.

### How to Use

Use the tool in the build script after installing the binaries to the PREFIX like so:

```bash
check-glibc $PREFIX/lib/*.so.*
```

Here we have used bash to expand a glob expression and provide `check-glibc` with a list of
files to search for glibc symbols. We have narrowed the glob to versioned shared libraries
only because we don't need to check links to binaries (that would be duplicate effort). In
fact, the tool will ignore any non-files. In other words, symbolic links will be ignored, so
you must name the actual files.

You can check arbitrary files by setting your own glob expression or explicitly listing the
files.

The tool will exit with status 1 if `c_stdlib_version` is older than newest symbol detected
in any of the binaries. The newest symbol detected for each binary is logged to the
terminal.

If this check fails, increase `c_stdlib_version` to a version newer than the version
detected by this tool.
