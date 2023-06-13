# CUDA Metapackage Versioning

The version of a CUDA Toolkit metapackage corresponds to the CUDA release
label. For example, the release label of CUDA 12.0 Update 1 is 12.0.1.  This
does not include the `cuda-version` metapackage which is versioned only by the
MAJOR.MINOR of a release label.

# Metapackage dependency versions

Installing a metapackage at a specific version should install all dependent
packages at the exact version from that CUDA release.

# Metapackage dependencies on cuda-version

Metapackages do not directly constrain to a specific `cuda-version` as their
version is more precise. Dependent packages will still install an appropriate
`cuda-version`.
