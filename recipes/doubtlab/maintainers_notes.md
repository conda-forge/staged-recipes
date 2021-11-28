# Maintainers' Notes

> NOTE: Use https://www.marcelotrevisani.com/grayskull to generate 
        a similar meta.yml file online. You may have to change it a 
        little though.

---

## About License File

- When you use "license_file: LICENSE", you are essencially telling 
  the build process to look for the license file (LICENSE) in the 
  package root directory in the source (such as, PyPI).
  > license_file: LICENSE

- If your PyPI source does not have any LICENSE file, but you have 
  copied the LICENSE file to your recipe-directory (for example, 
  recipes/doubtlab/LICENSE), then you could refer to this path with 
  an environment variable ("RECIPE_DIR") as follows:
  > license_file: `{{ environ["RECIPE_DIR"] }}/LICENSE`

  **Refer to**
  
  - https://gitter.im/conda-forge/conda-forge.github.io?at=5cdb01530f381d0a76b68504

### Example of a License File Error

```sh
> ValueError: License file given in about/license_file 
              (/home/conda/staged-recipes-copy/recipes/doubtlab/LICENCE) does not 
              exist in source root dir or in recipe root dir (with meta.yaml).
> [error]Bash exited with code '1'.
> Finishing: Run docker build
```

The error shown above typically happens in the step "docker build". See the 
following as an example.

**Source**:

- only screenshot: https://i.imgur.com/hs545l7.png
- screenshot + notes: https://imgur.com/a/OWCJZ6z

---

## Notes on Feedstock Version Update Process Flow

Basically, a version update works like this:

 1. A new version is published on PyPI.
 2. The conda-forge bot picks this up (note, this can take  
    a couple of hours sometimes). The status page for this is: 
    conda-forge.org/status/#version_updates.
 3. The bot opens a new PR, updating the version and sha256. 
    If a re-rendering is required, the bot will do that too.
 4. The maintainer verifies that no requirements changed and  
    that the license and, if provided, URLs are still the same.
 5. The maintainer merges the PR.

**Reference**:

- https://github.com/conda-forge/staged-recipes/pull/16940#discussion_r749568652

---

## TODO for Maintainers

> After each PyPI release of the package (doublab):

1. **THIS GETS TAKEN CARE OF BY A BOT**: _NO ACTION NEEDED_

    Get the corresponding "version" and "sha256" of the latest 
    release and update the following (line number: 2 and 33).
    - version
    - source.sha256

2. **THIS IS A MANUAL PROCESS**

    Crosscheck and update the package dependency versions under:
    - requirements.host
    - requirements.run

## See this example

- This is an example of how "pysteps" is maintaining `conda-forge/pysteps-feedstock`.

  https://pysteps.readthedocs.io/en/latest/developer_guide/update_conda_forge.html

---

## Other ToDo Items

### NOTE

`tqdm` is a dependency of cleanlab. But currently 
(2021-11-15) `conda-forge/cleanlab-feedstock`  
(CLFS) does not include it.

A PR ([#3][#cleanlab-feedstock-pr-3]) has been opened to address this issue.

- https://github.com/conda-forge/cleanlab-feedstock/pull/3

[#cleanlab-feedstock-pr-3]: https://github.com/conda-forge/cleanlab-feedstock/pull/3

So, for now, tqdm is being included here in the 
run-requirements. Also, tqdm is necessary for 
passing pip check. However, once PR([#3][#cleanlab-feedstock-pr-3]) is merged
with cleanlab-feedstock (`CLFS`), `tqdm` can be removed
from the run-requirements.

### TODO

- :bulb: Remove `tqdm` after cleanlab-feedstock (`CLFS`) [PR#3][#cleanlab-feedstock-pr-3] is merged.
