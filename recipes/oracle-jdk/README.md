## Design for Wrapping Previously Installed Libraries with a Conda Package

How do I develop a package which wraps a library not installed by conda?
An example of such libraries would be those whose distribution is limited or restricted.
e.g.
- this package
- https://github.com/conda-forge/oracle-instant-client-feedstock

## Context:

Suppose you are developing open-source plugins for various proprietary software.
e.g. modeling tools (UML, SysML, etc.).
While developing (testing) these tools it is necessary to cycle through all the versions of those tools and their libraries.
The binaries for these libraries are not freely distributed; access to these libraries is not a simple download from a url.
Making conda-forge packages for these libraries is problematic.

## Goal:
Develop a consistent way of handling packages which wrap libraries which are not installed using conda.

## Ref:

- https://docs.conda.io/projects/conda-build/en/latest/user-guide/environment-variables.html
- https://docs.conda.io/projects/conda-build/en/latest/resources/link-scripts.html

## Approach

The current approach is to use some combination of `post-link`, `pre-unlink`, `activate`, and de`activate` scripts.
Generally, `pre-link` scripts are discouraged (they are not supported in mamba).
There are some issues with this approach.

The main issue is that any artifacts (files, hardlinks, symlinks, etc.) produced by these scripts are not recorded in the package's meta-data file, e.g. miniconda3/env/conda-meta/foo-0.1.0-1.json.
If the artifacts were known at packaging-time then they could be coded in the `pre-unlink` script, but
as they can only be discovered at install-time then they need to be saved somewhere.

A related issue is the setting of environment variables.
This is partially handled via the requirements:run: [].
The problem is that those environment variables are defined at packaging-time.
Again, the previously defined variables need to be retained in the ``activate`` script and restored in de`activate`.


The `post-link` : `pre-unlink` and `activate`: `deactivate` pairs need to share information. 

The `post-link`, and `activate` scripts may write simple helper scripts which 
may be called by `pre-unlink`, and `deactivate` to revert what they did.
Similarly, the `post-link` script determines the path to the installed software being wrapped.
This can be done via discovery or download. 
The discovered path will be needed by the `activate` script.
These files need to be place in something like the **conda-meta** folder but distinct.
To that end I created a **conda-meso** folder.

```
set "CONDA_MESO=%CONDA_PREFIX%\conda-meso\%PKG_NAME%-%PKG_VERSION%_%PKG_BUILDNUM%"
set "DISCOVERY_SCRIPT=%CONDA_MESO%\discovery.bat"
set "UNLINK_SCRIPT=%CONDA_MESO%\unlink-aux.bat"
set "DEACTIVATE_SCRIPT=%CONDA_MESO%\deactivate-aux.bat`
```

n.b. similar scripts would be written by `post-link`.sh and `activate`.sh.
