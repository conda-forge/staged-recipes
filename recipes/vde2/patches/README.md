vde-2 git repo was imported from subversion (which was imported from cvs)

It used to have other things in the same repo that were removed and vde-2/ was made
the toplevel.

To be able to apply patches to the last 'officially released' tarball from sourceforge,
I did the following rewrites to the git history:
```
     2092  git filter-repo --invert-paths --path ipn/ --path kernel-patch-ipn/ --path vdetelweb/ --force
     2126  git filter-repo --filename-callback '
    if filename.startswith(b"vde-2/"):
      return filename[6:]
    else:
      return filename
    '
```
And then I tagged the commit that had message '2.3.2 frozen' as 2.3.2 because it is and I generated
the patches with `git format-patch 2.3.2` (while having master checked out)


One method of sanity checking that my patches should apply is by continuing the rewriting,
incrementally collapsing the 'release commits' on the `vde-2` branch with the following
rewrites:

```
     2127  git filter-repo --filename-callback '
    if filename.startswith(b"2.2.1/"):
      return filename[6:]
    else:
      return filename
    '
     2128  git filter-repo --filename-callback '
    if filename.startswith(b"2.2.2/"):
      return filename[6:]
    else:
      return filename
    '
     2129  git filter-repo --invert-paths --path ipn/ --path kernel-patch-ipn/ --path vdetelweb/ --force
     2130  git filter-repo --filename-callback '
    if filename.startswith(b"vde-2/"):
      return filename[6:]
    else:
      return filename
    '
     2131  git filter-repo --filename-callback '
    if filename.startswith(b"2.2.3/"):
      return filename[6:]
    else:
      return filename
    '
     2132  git filter-repo --filename-callback '
    if filename.startswith(b"2.3/"):
      return filename[4:]
    else:
      return filename
    '
     2133  git filter-repo --filename-callback '
    if filename.startswith(b"2.3.1/"):
      return filename[6:]
    else:
      return filename
    '
     2134  git filter-repo --filename-callback '
    if filename.startswith(b"2.3.2/"):
      return filename[6:]
    else:
      return filename
    '
```

And then diffing the two trees, the one I tagged 2.3.2 and the one at the tip of the vde-2 branch
that says it is 2.3.2.

```
-bash-4.2$ git diff 2.3.2 vde-2 --raw
:000000 100644 000000000 2809d2ec6 A    src/slirpvde/ctl.h
:000000 100644 000000000 925da11b6 A    src/slirpvde/debug.c
:000000 100644 000000000 03fc8c3ac A    src/slirpvde/icmp_var.h
```

Not too bad, only the slirpvde files were added somehow in the release on the vde-2 branch.
As long as the patches apply, it shouldn't matter and I have something that I can call 2.3.2-65 with
confidence (starting the build number with the number of patches I have to indicate that it isn't 
really that close to 2.3.2.
