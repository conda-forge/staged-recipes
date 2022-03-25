# Special Notes

The `setup.py` file had a problem of non-existing (invalid) `entry_points`. 
An issue [`#95`](https://github.com/huggingface/optimum/issues/95) was opened 
for the same and the fix was implemented through 
PR [`#96`](https://github.com/huggingface/optimum/pull/96)
in [optimum's repository](https://github.com/huggingface/omptimum).

The conda-forge recipe earlier (in its making) had used a jinja2 workaround to 
circumvent the conflict in question. But since, the fix was already implemented, 
as suggested in the review the git patch for PR `#96` was used to mitigate the 
issue with the `setup.py` file in `v1.0.0` of `optimum` package, hosted on PyPI.

However, there was a problem: the `setup.py` file used in PR `#96` was different 
from that found in the package source of `v1.0.0` on PyPI.

As a workaround for this, the patch for PR `#96` (file: `assets/pr_96.patch`) was 
modified (file: `adapted_pr_96.patch`) to match the `setup.py` file for `v1.0.0`.

This fixed the build failure with the patch.

Since a few ad-hoc steps were necessary, this `README` is supposed to capture what was 
done. Also, the original files are being stored here for reference in future.

```sh
# List of files in the recipe directory
meta.yaml
adapted_pr_96.patch
assets/pr_96.patch
assets/README.md
assets/setup_pr96.py
assets/setup_v1.0.0
```
