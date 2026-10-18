#!/usr/bin/env python3
"""Turn a list of opam `name.version` lines into rattler-build `source:` items.

usage: gen_sources.py LIST.txt OPAM_REPO [--prefix duniverse]
                      [--extra NAME=URL=SHA256 ...]

OPAM_REPO is a checkout containing packages/<name>/<name>.<ver>/opam.
Packages sharing one URL are emitted once (target dir named after the repo
or tarball). Warnings go to stderr; YAML goes to stdout.
Stdlib only.
"""
import os
import re
import sys
from urllib.parse import urlparse

ARCHIVE_EXT = re.compile(r"\.(tar\.gz|tgz|tar\.bz2|tbz|tar\.xz|txz|tar|zip)$")

# Target dirs whose archive is kept as-is (file_name set) and unpacked by
# build_semgrep_core.sh: pecu's tests have ':' in file names (not creatable on non-unix).
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
    """Return (src_url, {algo: hash}) from the url { } section."""
    m = re.search(r"^url\s*\{(.*?)^\}", text, re.S | re.M)
    if not m:
        return None, {}
    body = m.group(1)
    s = re.search(r'\b(?:src|archive):\s*"([^"]+)"', body)
    sums = {}
    c = re.search(r"checksum:\s*(\[[^\]]*\]|\"[^\"]*\")", body, re.S)
    if c:
        for algo, val in re.findall(r'"(sha256|sha512|md5)=([0-9a-fA-F]+)"', c.group(1)):
            sums[algo] = val
    return (s.group(1) if s else None), sums


def dir_name(url, pkg):
    u = urlparse(url)
    parts = [p for p in u.path.split("/") if p]
    if "opam-source-archives" in parts[:2] or u.netloc == "gitlab.inria.fr":
        # raw tarballs in a shared repo / gitlab ".../-/archive/<tag>/archive.tar.gz":
        # name after the project (gitlab) or the tarball (opam-source-archives)
        if u.netloc == "gitlab.inria.fr":
            return parts[1]
        base = ARCHIVE_EXT.sub("", parts[-1])
        m = re.match(r"^(.*?)[-_.]v?\d[\w.+~-]*$", base)
        return m.group(1) if m else base
    if u.netloc in ("github.com", "gitlab.com", "codeberg.org") and len(parts) >= 2:
        return parts[1]
    base = ARCHIVE_EXT.sub("", parts[-1]) if parts else pkg
    m = re.match(r"^(.*?)[-_.]v?\d[\w.+~-]*$", base)
    return m.group(1) if m else base or pkg


def main(argv):
    args = argv[1:]
    prefix = "duniverse"
    extra = {}
    pos = []
    i = 0
    while i < len(args):
        if args[i] == "--prefix":
            prefix = args[i + 1]
            i += 2
        elif args[i] == "--extra":
            n, url, sha = args[i + 1].split("=", 2)
            extra[n] = (url, {"sha256": sha} if sha else {})
            i += 2
        else:
            pos.append(args[i])
            i += 1
    if len(pos) != 2:
        sys.exit(__doc__)
    listfile, repo = pos
    repo = find_repo(repo)

    entries = {}  # url -> dict(pkgs, sums)
    order = []
    with open(listfile) as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            name, _, ver = line.partition(".")
            if name in extra:
                url, sums = extra[name]
            else:
                p = os.path.join(repo, "packages", name, line, "opam")
                if not os.path.isfile(p):
                    warn("%s: no opam file at %s" % (line, p))
                    continue
                with open(p) as fh:
                    url, sums = parse_opam(fh.read())
                if not url:
                    warn("%s: no url in opam file" % line)
                    continue
            if url not in entries:
                entries[url] = {"pkgs": [], "sums": sums}
                order.append(url)
            entries[url]["pkgs"].append(line)

    used = {}
    print("source:")
    for url in order:
        e = entries[url]
        first = e["pkgs"][0].partition(".")[0]
        d = dir_name(url, first)
        if d in used and used[d] != url:
            d = first
            n = 2
            while d in used and used[d] != url:
                d = "%s-%d" % (first, n)
                n += 1
        used[d] = url
        sums = e["sums"]
        print("  # provides: %s" % ", ".join(e["pkgs"]))
        print("  - url: %s" % url)
        if "sha256" in sums:
            print("    sha256: %s" % sums["sha256"])
        elif "md5" in sums:
            warn("%s: md5 only" % ", ".join(e["pkgs"]))
            print("    md5: %s  # WARNING md5 only" % sums["md5"])
        elif "sha512" in sums:
            warn("%s: sha512 only (rattler-build needs sha256/md5)" % ", ".join(e["pkgs"]))
            print("    # WARNING sha512 only, compute sha256: sha512=%s" % sums["sha512"])
            print("    sha256: TODO")
        else:
            warn("%s: no checksum" % ", ".join(e["pkgs"]))
            print("    sha256: TODO  # WARNING no checksum")
        if d in NO_EXTRACT:
            print("    file_name: %s" % urlparse(url).path.rsplit("/", 1)[-1])
        print("    target_directory: %s/%s" % (prefix, d))
    sys.stderr.write("%d source entries from %d packages\n" % (len(order), sum(len(e["pkgs"]) for e in entries.values())))


if __name__ == "__main__":
    main(sys.argv)
