# Release-build (`-Werror`) patches for Wire-Cell Toolkit 0.36.1

When WCT is built from a release version (digit-leading `version.txt`), its
`wscript` enters release mode (`is_development()` is false) and `waft/wcb.py`
appends strict flags:

    -Werror -Wall -Werror=return-type -pedantic -Wno-unused-local-typedefs

Under conda-forge's GCC 14, upstream 0.36.1 is not clean under these flags. A
full `./wcb -k` release build surfaces **four** distinct `-Werror` sites in
**three** categories. We resolve them honestly — genuine issues are fixed by
the source patches in this directory (each is upstream-PR-ready), and the one
remaining compiler **false positive** is demoted by a single targeted
`-Wno-error=` in `recipe/build.sh` (it stays a warning; `-Werror` is otherwise
left fully on). The dev-only `dev-` version prefix trick is **not** used — a
shipped package must build under real release strictness.

## Enumerated sites

| Site | Category | Treatment |
|------|----------|-----------|
| `quickhull/src/QuickHull.cxx:214` | `pessimizing-move` | patch 0001 (genuine) |
| `clus/src/Graphs.cxx:225` | `dangling-reference` | patch 0002 (genuine — real UB) |
| `util/test/test_eigen2.cxx:14` | `unused-variable` | patch 0003 (genuine) |
| `aux/src/ClusterArrays.cxx:595,596` | `dangling-reference` | CXXFLAGS downgrade (false positive) |

## The patches (each = one upstream commit)

### 0001 — quickhull: drop pessimizing `std::move` on a prvalue return
`Mesh::disableFace()` returns `std::unique_ptr<...>` by value. Wrapping the call
in `std::move()` forces a move and defeats guaranteed copy elision
(`-Wpessimizing-move`). Remove the redundant move. No behavior change.

### 0002 — clus: fix dangling reference to BGL named-parameter temporaries
`const auto& param = weight_map(...).predecessor_map(...).distance_map(...);`
binds a reference to the last link of a Boost.Graph `bgl_named_params` chain;
that link references the earlier temporaries in the chain, which die at the end
of the statement, so `param` dangles before it reaches
`dijkstra_shortest_paths()` on the next line. This is a **genuine latent
use-after-free**, not a false positive. Fix: pass the named-parameter chain
directly as the call argument so all temporaries live for the call's duration.

### 0003 — util/test: drop unused `mat5`
`Matrix3f ... mat5;` is declared but only referenced in a commented-out line;
`-Wunused-variable` flags it. Remove `mat5` from the declaration; the comment
stays.

## Not patched — `aux/src/ClusterArrays.cxx` (handled by build.sh)
`const auto& tind = earr[ind][tail_col];` (and the `hind` line below it).
`earr` is a `boost::multi_array`; `earr[ind]` yields a transient subview proxy
and `[col]` returns a reference **into the array's own backing storage**, not
into the proxy — so the reference is valid. GCC 13+ `-Wdangling-reference`
mis-fires on this multi_array access pattern (a known compiler false positive).
Rather than alter correct code, `recipe/build.sh` exports
`CXXFLAGS="-Wno-error=dangling-reference ..."`, demoting only this category back
to a warning while `-Werror` stays on for everything else.

## Provenance / how to refresh
Patches are generated against the **0.36.1 release tarball** source (the recipe's
`source.url`), verified to differ from the working dev clone only in line
numbers at the ClusterArrays (non-patched) site. To regenerate after a version
bump: re-run a release `./wcb -k` build, re-enumerate `-Werror=` sites, and
re-diff against the new tag.
