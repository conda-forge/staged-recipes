## About

This repo is a holding area for recipes destined for a conda-forge feedstock repo. To find out more about conda-forge, see https://github.com/conda-forge/conda-smithy.

[![Join the chat at https://conda-forge.zulipchat.com](https://img.shields.io/badge/Zulip-join_chat-53bfad.svg)](https://conda-forge.zulipchat.com)

## Feedstock conversion status

[![create_feedstocks](https://github.com/conda-forge/admin-requests/actions/workflows/create_feedstocks.yml/badge.svg)](https://github.com/conda-forge/admin-requests/actions/workflows/create_feedstocks.yml)

Failures with the above job are often caused by API rate limits from the various services used by conda-forge.
This can result in empty feedstock repositories and will resolve itself automatically.
If the issue persists, support can be found [on Zulip](https://conda-forge.zulipchat.com).

## Getting started

1. Fork this repository.
2. Make a new branch from `main` for your package's recipe.
3. Make a new folder in `recipes` for your package. Look at the [example recipe](recipes/example), our [documentation](http://conda-forge.org/docs/maintainer/adding_pkgs.html#) and the [FAQ](https://github.com/conda-forge/staged-recipes#faq) for help.
4. Open a pull request. Building of your package will be tested on Windows, Mac and Linux.
5. When your pull request is merged a new repository, called a feedstock, will be created in the github conda-forge organization, and build/upload of your package will automatically be triggered. Once complete, the package is available on conda-forge.

### `pixi`

`pixi` is a project based environment and task runner optimized for `conda`. Several of
the local workflows and their dependencies described below are captured in
`pixi.toml`. Install `pixi` via the [documented approaches](https://pixi.sh/latest/#installation),
or via `conda`/`mamba`/`micromamba`:

```bash
$CONDA_EXE install -c conda-forge pixi
```

See the available tasks with `pixi task list`.

## Local debugging with `build-locally.py`

The script `build-locally.py` will guide you through the local debugging process. This script
will then launch the platform-specific scripts, which support some key environment variables in
macOS and Windows:

- `MINIFORGE_HOME`: Where the build tools will be installed. Defaults to `~/Miniforge3`.
- `CONDA_BLD_PATH`: Where the build artifacts will be kept. Defaults to `~/Miniforge3/conda-bld`
  on macOS and `C:\bld` on Windows.

On Linux, everything runs in a Docker container. The `staged-recipes` directory is mounted as a volume. The resulting artifacts will be available under `build_artifacts` in the repository directory.

`build-locally.py` can be run with any recent Python, or via a [`pixi`](#pixi) task:

* `pixi run build-linux`: will launch a Docker container, provision all the necessary tools and build your recipe for Linux.
* `pixi run build-osx`: will provision a conda environment with the necessary tools to build your recipe for macOS. This involves fetching and caching the necessary Apple SDKs.
* `pixi run build-win`: will provision a conda environment with the necessary tools to build your recipe for Windows.

These tasks will pass any extra arguments to `build-locally.py`, including `--help`. The resulting
artifacts will be available under `build_artifacts`.

## Generating recipes with `grayskull`

[grayskull](https://github.com/conda-incubator/grayskull) can generate recipes from
Python packages on [PyPI](https://pypi.org) or R packages on [CRAN](https://cran.r-project.org/).
The user should review the recipe generated, especially the license and dependencies.

Use one of:

- manually
  1. install `grayskull`: `conda install -c conda-forge grayskull`
  2. generate recipe:
    - `cd recipes && grayskull pypi PACKAGE_NAME_ON_PYPI_HERE [PACKAGE_NAME_ON_PYPI_HERE...]`
    - `cd recipes && grayskull cran PACKAGE_NAME_ON_CRAN_HERE [PACKAGE_NAME_ON_CRAN_HERE...]`
- with [`pixi`](#pixi):
  1. generate recipe:
    - `pixi run pypi PACKAGE_NAME_ON_PYPI_HERE [PACKAGE_NAME_ON_PYPI_HERE...]`
    - `pixi run cran PACKAGE_NAME_ON_CRAN_HERE [PACKAGE_NAME_ON_CRAN_HERE...]`

## Linting recipes with `conda-smithy`

The [`conda-smithy`](https://github.com/conda-forge/conda-smithy) package provides
helpful linters that can save CI resources by catching known issues up-front.

Use one of:
- manually
  - install `conda-smithy`: `conda install -c conda-forge conda-smithy shellcheck`
  - lint recipes: `conda-smithy recipe-lint --conda-forge recipes/*`
- with [`pixi`](#pixi):
  - lint recipes: `pixi run lint`

> **NOTES**
>
> - `conda-smithy` is
> [frequently updated](https://github.com/conda-forge/conda-smithy/blob/main/CHANGELOG.rst)
> with current best practices. Ensure using the latest with:
>   - `$CONDA_EXE upgrade conda-smithy shellcheck`
>   - or `pixi upgrade --feature conda-smithy`
>
> - to enable most [`shellcheck`](https://www.shellcheck.net/) [rules](https://www.shellcheck.net/wiki)
>    - create a [`conda-forge.yml`](https://conda-forge.org/docs/maintainer/conda_forge_yml)
>      next to your new recipe (and any `.sh` scripts):
>      ```yaml
>      # recipes/your-new-recipe/conda-forge.yml
>      shellcheck:
>        enabled: true
>      ```
>    - run the linter using your preferred method, as described above
>    - if committed and pushed, this will be checked in CI during the review process,
>      then merged into the defaults in the root of the rendered feedstock.


## FAQ

### 1. **How do I start editing the recipe?**

Look at one of [these examples](https://github.com/conda-forge/staged-recipes/tree/main/recipes)
in this repository and modify it as necessary.

Follow the order of the sections in the example recipe. If you make a copy of example recipe, please remove the example's explainer comments from your recipe. Add your own comments to the recipe and build scripts to explain unusual build behavior or recipe options.

*If there are details you are not sure about please open a pull request. The conda-forge team will be happy to answer your questions.*

### 2. **How do I populate the `hash` field?**

If your package is on [PyPI](https://pypi.org), you can get the sha256 hash from your package's page on PyPI; look for the `SHA256` link next to the download link for your package.

You can also generate a hash from the command line on Linux (and Mac if you install the necessary tools below). If you go this route, the `sha256` hash is preferable to the `md5` hash.

To generate the `md5` hash: `md5 your_sdist.tar.gz`

To generate the `sha256` hash: `openssl sha256 your_sdist.tar.gz`

You may need the openssl package, available on conda-forge:
`conda install openssl -c conda-forge`

### 3. **How do I exclude a platform?**

Use the `skip` key in the `build` section along with a selector:

```yaml
build:
    skip: true  # [win]
```

A full description of selectors is [in the conda docs](https://docs.conda.io/projects/conda-build/en/latest/resources/define-metadata.html#preprocessing-selectors).

If the package can otherwise be `noarch` you can also skip it by using [virtual packages](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-virtual.html).

_Note_: As the package will always be built on linux, it needs to be at least available on there.


### 4. **What does the `build: 0` entry mean?**

The build number is used when the source code for the package has not changed but you need to make a new
build. For example, if one of the dependencies of the package was not properly specified the first time
you build a package, then when you fix the dependency and rebuild the package you should increase the build
number.

When the package version changes you should reset the build number to `0`.

### 5. **Do I have to import all of my unit tests into the recipe's `test` field?**

No, you do not. The main purpose of the test section is to test whether this conda package was built and installed correctly (not whether the upstream package contains bugs).

### 6. **Do all of my package's dependencies have to be in conda(-forge) already?**

Short answer: yes. Long answer: In principle, as long as your dependencies are in at least one of
your user's conda channels they will be able to install your package. In practice, that is difficult
to manage, and we strive to get all dependencies built in conda-forge.

### 7. **When or why do I need to use `{{ PYTHON }} -m pip install . -vv`?**

This should be the default install line for most Python packages. This is preferable to `python setup.py` because it handles metadata in a `conda`-friendlier way.

### 8. **Do I need `bld.bat` and/or `build.sh`?**

In many cases, no. Python packages almost never need it. If the build can be done with one line you can put it in the `script` line of the `build` section.

If you _would_ like help with `.sh` best practices, see more information about
[linting with `conda-smithy`](#linting-recipes-with-conda-smithy) and `shellcheck`.

### 9. What does being a conda-forge feedstock maintainer entail?

The maintainers "job" is to:

- keep the feedstock updated by merging maintenance PRs from conda-forge's bots;
- keep the package updated by bumping the version whenever there is a new release;
- answer questions about the package on the feedstock issue tracker.

### 10. Why are there recipes already in the `recipes` directory? Should I do something about it?

When a PR of recipe(s) is ready to go, it is merged into `main`. This will trigger a CI build specially designed to convert the recipe(s). However, for any number of reasons the recipe(s) may not be converted right away. In the interim, the recipe(s) will remain in `main` until they can be converted. There is no action required on the part of recipe contributors to resolve this. Also it should have no impact on any other PRs being proposed. If these recipe(s) pending conversion do cause issues for your submission, please ping `conda-forge/core` for help.

### 11. **Some checks failed, but it wasn't my recipe! How do I trigger a rebuild?**

Sometimes, some of the CI tools' builds fail due to no error within your recipe. If that happens, you can trigger a rebuild by re-creating the last commit and force pushing it to your branch:

```bash
# edit your last commit, giving it a new time stamp and hash
# (you can just leave the message as it is)
git commit --amend
# push to github, overwriting your branch
git push -f
```

If the problem was due to scripts in the `staged-recipes` repository, you may be asked to "rebase" once these are fixed. To do so, run:
```bash
# If you didn't add a remote for conda-forge/staged-recipes yet, also run
# these lines:
# git remote add upstream https://github.com/conda-forge/staged-recipes.git
# git fetch --all
git rebase upstream/main
git push -f
```

### 12. My pull request passes all checks, but hasn't received any attention. How do I call attention to my PR?  What is the customary amount of time to wait?

<!--
Keep this message in sync with the PR template.

https://raw.githubusercontent.com/conda-forge/staged-recipes/main/.github/pull_request_template.md
-->

Thank you very much for putting in this recipe PR!

This repository is very active, so if you need help with a PR, please let the
right people know. There are language-specific teams for reviewing recipes.

| Language        | Name of review team           |
| --------------- | ----------------------------- |
| python          | `@conda-forge/help-python`    |
| python/c hybrid | `@conda-forge/help-python-c`  |
| r               | `@conda-forge/help-r`         |
| java            | `@conda-forge/help-java`      |
| nodejs          | `@conda-forge/help-nodejs`    |
| c/c++           | `@conda-forge/help-c-cpp`     |
| perl            | `@conda-forge/help-perl`      |
| Julia           | `@conda-forge/help-julia`     |
| ruby            | `@conda-forge/help-ruby`      |
| other           | `@conda-forge/staged-recipes` |

Once the PR is ready for review, please mention one of the teams above in a
new comment. i.e. `@conda-forge/help-some-language, ready for review!`
Then, a bot will label the PR as 'review-requested'.

Due to GitHub limitations, first time contributors to conda-forge are unable
to ping conda-forge teams directly, but you can [ask a bot to ping the team][1]
using a special command in a comment on the PR to get the attention of the
`staged-recipes` team. You can also consider asking on our [Zulip chat][2]
if your recipe isn't reviewed promptly.

[1]: https://conda-forge.org/docs/maintainer/infrastructure.html#conda-forge-admin-please-ping-team
[2]: https://conda-forge.zulipchat.com

All apologies in advance if your recipe PR does not receive prompt attention.
This is a high volume repository and the reviewers are volunteers. Review times vary depending on the number of reviewers on a given language team and may be days or weeks. We are always
looking for more staged-recipe reviewers. If you are interested in volunteering,
please contact a member of @conda-forge/core. We'd love to have your help!


### 13. Is there a changelog for this repository?

There's no changelog file, but the following `git` command gives a good overview of the recent changes in the repository:

```bash
$ git log --merges -- ':!recipes'
```
