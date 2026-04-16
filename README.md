## About

This repo is a holding area for recipes destined for a conda-forge feedstock repo.

Keep reading to learn about [getting started](#getting-started),
preparing your [local environment](#local-debugging),
[generating recipes](#generating-recipes-with-grayskull)
for Python/R packages, [linting](#linting-recipes-with-conda-smithy), and [building](#building-with-build-locallypy) a package.

> To find out more about conda-forge, see [conda-smithy](https://github.com/conda-forge/conda-smithy).

[![Join the chat at https://conda-forge.zulipchat.com](https://img.shields.io/badge/Zulip-join_chat-53bfad.svg)](https://conda-forge.zulipchat.com)

## Getting started

1. [Fork](https://github.com/conda-forge/staged-recipes/fork) this repository.
2. Make a new branch from `main` for your package's recipe.
3. Make a new folder in `recipes` for your package, and start a `recipe.yaml` (or `meta.yaml`).

   For more information:
   - [generate](#generating-recipes-with-grayskull) a recipe
   - read the [example recipe](recipes/example-v1)
   - read the [FAQ](https://github.com/conda-forge/staged-recipes#faq)
   - search for [examples on GitHub](https://github.com/search?q=org%3Aconda-forge+path%3Arecipe.yaml+&type=code)
   - visit our [documentation](http://conda-forge.org/docs/maintainer/adding_pkgs.html#)
4. (recommended) Try to build the feedstock [locally](#local-debugging).
5. Open a pull request, paying attention to the checklist. Building of your
   package will be tested on Linux, macOS, and Windows.
6. Ask for review or help by `@`-mentioning the appropriate [review teams](#review-teams)
   (or using the [bot command](#review-bot-command)) in a pull request comment
7. When your pull request is reviewed and merged:
    - a new "feedstock" repository is created in the GitHub conda-forge organization
      - If this is your first recipe, you will receive an email about steps to accept
        an invitation to a new GitHub group.
    - a build of your package is triggered
    - the package is uploaded to conda-forge

### Feedstock conversion status

[![create_feedstocks](https://github.com/conda-forge/admin-requests/actions/workflows/create_feedstocks.yml/badge.svg)](https://github.com/conda-forge/admin-requests/actions/workflows/create_feedstocks.yml)

Failures with the above job are often caused by API rate limits from the various services used by conda-forge.
This can result in empty feedstock repositories and will resolve itself automatically.
If the issue persists, support can be found [on Zulip](https://conda-forge.zulipchat.com).

## Local debugging

While all of the above steps eventually need to work in CI for a recipe to be merged,
building locally is a good way to learn more about conda-forge, and make better
use of donated, community resources.

### Building with `build-locally.py`

The script `build-locally.py` will guide you through the local debugging process. This script
will then launch the platform-specific scripts, and the resulting artifacts will
be available under `build_artifacts` in the repository directory.

On Linux, everything runs in a Docker container. The `staged-recipes` directory is mounted as a volume.

On macOS and Windows, some environment variables control where files are kept:

- `MINIFORGE_HOME`: Where the build tools will be installed. Defaults to `~/Miniforge3`.
- `CONDA_BLD_PATH`: Where the build artifacts will be kept. Defaults to `~/Miniforge3/conda-bld`
  on macOS and `C:\bld` on Windows.

`build-locally.py` can be run with any recent Python, or via a [`pixi`](#pixi) task.

#### Building with `pixi`

<details>
<summary>Learn more about <b>building with <code>pixi</code></b>...</summary>

- Linux
    ```bash
    pixi run build-linux
    ```
  - launch a Docker container
  - provision all the necessary tools
  - build your recipe

- macOS
  ```bash
  pixi run build-osx
  ```
  - find (or provision) [`$CONDA_EXE`](#conda-exe)
  - provision a conda environment with the necessary tools
    - This involves fetching and caching the necessary Apple SDKs.
  - build your recipe

- Windows
  ```bash
  pixi run build-win
  ```
  - find (or provision) [`$CONDA_EXE`](#conda-exe)
  - provision a conda environment with the necessary tools
  - build your recipe

These tasks will pass any extra arguments to `build-locally.py`, including `--help`. The resulting
artifacts will be available under `build_artifacts`.

</details>

### `$CONDA_EXE`

If you have never used conda-forge before, you may need a conda-compatible
package manager, such as `conda`, `mamba`, or `micromamba`.
`$CONDA_EXE`, the "well-known" environment variable is used for
"_a conda package manager in an activated POSIX shell session,_" is used
throughout this document.

> On Windows, this environment variable would be `%CONDA_EXE%`.

If a compatible `$CONDA_EXE` is not found, the `build-locally.py` script may download
`micromamba`: as a single file static binary it isn't _installed_, per se, and
can be used to create other environments.

### `miniforge`

For a more traditional installation, downloading, installing, and activating a
[miniforge](https://conda-forge.org/miniforge/) installer provides `conda` and `mamba`,
with conda-forge as the default source of packages. If found, `build-locally.py`
will use this instead of downloading `micromamba`.

### `pixi`

`pixi` is a workspace-based environment and task runner optimized for conda packaging.
Several of the local workflows and their dependencies described below are captured
in `pixi.toml`. Install `pixi` via `$CONDA_EXE`:

```bash
$CONDA_EXE install -c conda-forge pixi
```

... or one of the [documented approaches](https://pixi.sh/latest/#installation).

See the available tasks with `pixi task list`, or get started
[building with `pixi`](#building-with-pixi).

## Generating recipes with `grayskull`

[grayskull](https://github.com/conda-incubator/grayskull) can generate recipes from
Python packages on [PyPI](https://pypi.org) or R packages on [CRAN](https://cran.r-project.org/).
The user should review the recipe generated, especially the license and dependencies.

<details><summary>Learn more about <b>generating Python and R recipes</b>...</summary>
Use one of:

- manually

  1. install `grayskull`:

     ```bash
     conda install -c conda-forge grayskull conda-recipe-manager
     ```

  2. navigate to the `recipes` folder:
     ```bash
     cd recipes
     ```
  3. generate recipe:

     > omit `--use-v1-format` to get a `meta.yaml` for `conda-build` instead

     - Python
       ```bash
       grayskull pypi --use-v1-format PACKAGE_ON_PYPI_HERE [ANOTHER...]
       ```
     - R:
       ```bash
       grayskull cran --use-v1-format PACKAGE_ON_CRAN_HERE [ANOTHER...]
       ```

- with [`pixi`](#pixi):
  1. generate recipe:
     > use `pypi-v0` or `cran-v0` to get a `meta.yaml` for `conda-build` instead

    - Python
      ```bash
      pixi run pypi PACKAGE_ON_PYPI_HERE [ANOTHER...]
      ```
    - R
      ```bash
      pixi run cran PACKAGE_ON_CRAN_HERE [ANOTHER...]
      ```

</details>

## Linting recipes with `conda-smithy`

The [`conda-smithy`](https://github.com/conda-forge/conda-smithy) package provides
helpful linters that can save CI resources by catching known issues up-front.

<details>
<summary>Learn more about <b>linting with <code>conda-smithy</code></b>...</summary>

Use one of:

- manually

  1. install `conda-smithy`:

     ```bash
     conda install -c conda-forge conda-smithy shellcheck
     ```

  2. lint recipes:

     ```bash
     conda-smithy recipe-lint --conda-forge recipes/*
     ```

- with [`pixi`](#pixi):
  1. lint recipes: `pixi run lint`

> **NOTES**
>
> - `conda-smithy` is
>   [frequently updated](https://github.com/conda-forge/conda-smithy/blob/main/CHANGELOG.rst)
>   with current best practices. Ensure using the latest with:
>
>   - `$CONDA_EXE upgrade conda-smithy shellcheck`
>   - or `pixi upgrade --feature conda-smithy`
>
> - to enable most [`shellcheck`](https://www.shellcheck.net/) [rules](https://www.shellcheck.net/wiki)
>   - create a [`conda-forge.yml`](https://conda-forge.org/docs/maintainer/conda_forge_yml)
>     next to your new recipe (and any `.sh` scripts):
>     ```yaml
>     # recipes/your-new-recipe/conda-forge.yml
>     shellcheck:
>       enabled: true
>     ```
>   - run the linter using your preferred method, as described above
>   - if committed and pushed, this will be checked in CI during the review process,
>     then merged into the defaults in the root of the rendered feedstock.

</details>

## FAQ

### 1. **How do I start editing the recipe?**

Look at one of [these examples](https://github.com/conda-forge/staged-recipes/tree/main/recipes)
in this repository and modify it as necessary.

Follow the order of the sections in the example recipe. If you make a copy of example recipe, please remove the example's explainer comments from your recipe. Add your own comments to the recipe and build scripts to explain unusual build behavior or recipe options.

_If there are details you are not sure about please open a pull request. The conda-forge team will be better able to answer questions about a failing build._

### 2. **How do I populate the `hash` field?**

If your package is on [PyPI](https://pypi.org), you can get the sha256 hash from your package's page on PyPI; look for the `SHA256` link next to the download link for your package.

You can also generate a hash from the command line on Linux (and Mac if you install the necessary tools below). If you go this route, the `sha256` hash is preferable to the `md5` hash.

To generate the `md5` hash: `md5 your_sdist.tar.gz`

To generate the `sha256` hash: `openssl sha256 your_sdist.tar.gz`

You may need the openssl package, available on conda-forge:
`conda install openssl -c conda-forge`

### 3. **How do I exclude a platform?**

Use the `skip` key in the `build` section along with a selector:

- v1 `recipe.yaml`
  ```yaml
  build:
    skip: win
  ```
  > a full description of selectors is [in the rattler-build docs](https://rattler.build/latest/selectors)
- v0 `meta.yaml`
  ```yaml
  build:
    skip: true # [win]
  ```
  > A full description of selectors is [in the conda docs](https://docs.conda.io/projects/conda-build/en/latest/resources/define-metadata.html#preprocessing-selectors).

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

### 12. My pull request passes all checks, but hasn't received any attention. How do I call attention to my PR? What is the customary amount of time to wait?

<!--
Keep this message in sync with the PR template.

https://raw.githubusercontent.com/conda-forge/staged-recipes/main/.github/pull_request_template.md
-->

Thank you very much for putting in this recipe PR!

This repository is very active, so if you need help with a PR, please let the
right people know.

#### Review teams

There are language-specific teams for reviewing recipes.

| Language        | Name of review team           |
| --------------- | ----------------------------- |
| c/c++           | `@conda-forge/help-c-cpp`     |
| go              | `@conda-forge/help-go`        |
| java            | `@conda-forge/help-java`      |
| Julia           | `@conda-forge/help-julia`     |
| nodejs          | `@conda-forge/help-nodejs`    |
| perl            | `@conda-forge/help-perl`      |
| python          | `@conda-forge/help-python`    |
| python/c hybrid | `@conda-forge/help-python-c`  |
| r               | `@conda-forge/help-r`         |
| ruby            | `@conda-forge/help-ruby`      |
| rust            | `@conda-forge/help-rust`      |
| other           | `@conda-forge/staged-recipes` |

Once the PR is ready for review, please mention one of the teams above in a
new comment. i.e. `@conda-forge/help-some-language, ready for review!`
Then, a bot will label the PR as 'review-requested'.

#### Review Bot Command

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
