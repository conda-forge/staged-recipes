#!/usr/bin/env python3
"""Turn a list of opam `name.version` lines into rattler-build `source:` items.

usage: gen_sources.py LIST.txt OPAM_REPO [--prefix duniverse]

OPAM_REPO is an opam-repository checkout (packages/<name>/<name>.<ver>/opam).
YAML goes to stdout, warnings to stderr. Stdlib only.

Bump procedure (recipe.yaml is the source of truth; its generated block is hand-edited):
  1. opam-solve the new semgrep.opam; drop conda-provided and conf-* packages; write the rest to LIST.txt.
  2. gen_sources.py LIST.txt OPAM_REPO --prefix semgrep/duniverse; paste between the BEGIN/END markers.
  3. Drop hmap, jsonm, num, zarith, ocamlfind (published or built privately); merge alcotest and testo
     into one entry each (same tarball); add the dune tarball by hand (target semgrep/duniverse/dune).
  4. A missing sha256 aborts the run: add it to the opam file by hand. pecu must keep its file_name (NO_EXTRACT).
"""
import os
import re
import sys
from urllib.parse import urlparse

ARCHIVE_EXT = re.compile(r"\.(tar\.gz|tgz|tar\.bz2|tbz|tar\.xz|txz|tar|zip)$")

# Archives kept packed (file_name set) and unpacked by build_semgrep_core.sh:
# pecu's tests have ':' in file names (not creatable on non-unix).
NO_EXTRACT = {"pecu"}


def warn(msg):
    sys.stderr.write("WARNING: %s\n" % msg)


def find_repo(path):
    if os.path.isdir(os.path.join(path, "packages")):
        return path
    for root, dirs, _ in os.walk(path):
        if "packages" in dirs:
            return root
        if root.count(os.sep) - path.count(os.sep) > 2:
            dirs[:] = []
    sys.exit("no packages/ dir under %s" % path)


def parse_opam(text):
    """Return (src_url, sha256) from the url { } section."""
    m = re.search(r"^url\s*\{(.*?)^\}", text, re.S | re.M)
    if not m:
        return None, None
    body = m.group(1)
    s = re.search(r'\b(?:src|archive):\s*"([^"]+)"', body)
    h = re.search(r'"sha256=([0-9a-fA-F]+)"', body)
    return (s.group(1) if s else None), (h.group(1) if h else None)


def strip_version(base):
    """foo-1.2.3 -> foo."""
    m = re.match(r"^(.*?)[-_.]v?\d[\w.+~-]*$", base)
    return m.group(1) if m else base


def dir_name(url, pkg):
    u = urlparse(url)
    parts = [p for p in u.path.split("/") if p]
    if u.netloc == "gitlab.inria.fr":
        return parts[1]  # ".../-/archive/<tag>/archive.tar.gz": name after the project
    if "opam-source-archives" in parts[:2]:
        return strip_version(ARCHIVE_EXT.sub("", parts[-1]))
    if u.netloc in ("github.com", "gitlab.com", "codeberg.org") and len(parts) >= 2:
        return parts[1]
    return strip_version(ARCHIVE_EXT.sub("", parts[-1])) if parts else pkg


def main(argv):
    args = argv[1:]
    prefix = "duniverse"
    if "--prefix" in args:
        i = args.index("--prefix")
        prefix = args[i + 1]
        del args[i:i + 2]
    if len(args) != 2:
        sys.exit(__doc__)
    listfile, repo = args
    repo = find_repo(repo)

    entries = {}  # url -> dict(pkgs, sha256)
    with open(listfile) as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            name = line.partition(".")[0]
            p = os.path.join(repo, "packages", name, line, "opam")
            if not os.path.isfile(p):
                warn("%s: no opam file at %s" % (line, p))
                continue
            with open(p) as fh:
                url, sha = parse_opam(fh.read())
            if not url:
                warn("%s: no url in opam file" % line)
                continue
            entries.setdefault(url, {"pkgs": [], "sha256": sha})["pkgs"].append(line)

    used = {}
    print("source:")
    for url, e in entries.items():
        first = e["pkgs"][0].partition(".")[0]
        d = dir_name(url, first)
        if d in used and used[d] != url:
            d = first
            n = 2
            while d in used and used[d] != url:
                d = "%s-%d" % (first, n)
                n += 1
        used[d] = url
        print("  # provides: %s" % ", ".join(e["pkgs"]))
        print("  - url: %s" % url)
        if not e["sha256"]:
            sys.exit("%s: no sha256 in opam file" % ", ".join(e["pkgs"]))
        print("    sha256: %s" % e["sha256"])
        if d in NO_EXTRACT:
            print("    file_name: %s" % urlparse(url).path.rsplit("/", 1)[-1])
        print("    target_directory: %s/%s" % (prefix, d))
    sys.stderr.write("%d source entries from %d packages\n" % (len(entries), sum(len(e["pkgs"]) for e in entries.values())))


if __name__ == "__main__":
    main(sys.argv)
