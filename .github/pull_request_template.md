<!--
Thank you very much for putting in this recipe PR!

This repository is very active, so if you need help with
a PR or once it's ready for review, please let the right people know.
There are language-specific teams for reviewing recipes.

Currently available teams are:
- python `@conda-forge/help-python`
- python/c hybrid `@conda-forge/help-python-c`
- r `@conda-forge/help-r`
- java `@conda-forge/help-java`
- nodejs `@conda-forge/help-nodejs`
- c/c++ `@conda-forge/help-c-cpp`
- perl `@conda-forge/help-perl`
- Julia `@conda-forge/help-julia`
- ruby `@conda-forge/help-ruby`

If your PR doesn't fall into those categories please contact
the full review team `@conda-forge/staged-recipes`.

Due to GitHub limitations first time contributors to conda-forge are unable
to ping these teams. You can [ping the team](https://conda-forge.org/docs/maintainer/infrastructure.html#conda-forge-admin-please-ping-team) using a special command in
a comment on the PR to get the attention of the `staged-recipes` team. You can
also consider asking on our [Gitter channel](https://gitter.im/conda-forge/conda-forge.github.io)
or on our [Keybase chat](https://keybase.io/team/condaforge.chat)
if your recipe isn't reviewed promptly.
-->

Checklist
- [ ] Title of this PR is meaningful: e.g. "Adding my_nifty_package", not "updated meta.yaml"
- [ ] License file is packaged (see [here](https://github.com/conda-forge/staged-recipes/blob/master/recipes/example/meta.yaml#L57-L66) for an example)
- [ ] Source is from official source
- [ ] Package does not vendor other packages. (If a package uses the source of another package, they should be separate packages or the licenses of all packages need to be packaged)
- [ ] If static libraries are linked in, the license of the static library is packaged.
- [ ] Build number is 0
- [ ] A tarball (`url`) rather than a repo (e.g. `git_url`) is used in your recipe (see [here](https://conda-forge.org/docs/maintainer/adding_pkgs.html#build-from-tarballs-not-repos) for more details)
- [ ] GitHub users listed in the maintainer section have posted a comment confirming they are willing to be listed there
