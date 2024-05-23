# Copyright 2023 Isuru Fernando
# SPDX-License-Identifier: BSD-3-Clause
#
# Yes, this script is horrible but since it works I do not intend to
# spend any time 'improving' it.

from bs4 import BeautifulSoup
import requests
import subprocess
import os
import shutil
from ordered_set import OrderedSet as set

date = "20230914"
binary_index_url = (
    f"https://github.com/conda-forge/msys2-recipes/releases/download/{date}-ucrt64/"
)
source_url = (
    f"https://github.com/conda-forge/msys2-recipes/releases/download/{date}-ucrt64/"
)

pkg_prefix = "mingw-w64-ucrt-x86_64-"

to_process = set([f"{pkg_prefix}crt", f"{pkg_prefix}winpthreads", f"{pkg_prefix}headers", f"{pkg_prefix}windows-default-manifest"])

provides = {
  f"{pkg_prefix}winpthreads": f"{pkg_prefix}winpthreads-git",
  f"{pkg_prefix}crt": f"{pkg_prefix}crt-git",
  f"{pkg_prefix}headers": f"{pkg_prefix}headers-git",
  f"{pkg_prefix}libwinpthread": f"{pkg_prefix}libwinpthread-git",
  f"{pkg_prefix}tools": f"{pkg_prefix}tools-git",
}

seen = {}

def get_pkgs():
    directory_listing = requests.get(binary_index_url + "index.html").text
    s = BeautifulSoup(directory_listing, "html.parser")
    full_names = [
        node.get("href")
        for node in s.find_all("a")
        if node.get("href").endswith((".tar.zst", "tar.xz"))
    ]
    # format: msy2-w32api-headers-10.0.0.r16.g49a56d453-1-x86_64.pkg.tar.zst
    return list(
        sorted(
            [
                ("-".join(pkg.split("-")[:-3]), "-".join(pkg.split("-")[-3:]))
                for pkg in full_names
            ]
        )
    )


pkg_latest_ver = dict(get_pkgs())


def get_info(pkginfo, desc):
    return [
        line[len(f"{desc} = ") :].strip()
        for line in pkginfo
        if line.startswith(f"{desc} = ")
    ]


def get_depends(pkg):
    # download and extract binary
    info = pkg_latest_ver[pkg]
    basename = f"cache/{pkg}-{info}"
    url = f"{binary_index_url}/{pkg}-{info}"
    if not os.path.exists(basename):
        if "github" in url:
            subprocess.check_call(["wget", url.replace("~", "."), "-O", basename])
        else:
            subprocess.check_call(["wget", url, "-O", basename])
    subprocess.check_call(["mkdir", "-p", "cache/tmp"])
    subprocess.check_call(["bsdtar", "-xf", basename, "--directory=cache/tmp"])
    with open("cache/tmp/.PKGINFO") as f:
        pkginfo = f.readlines()

    # download source
    pkgbases = get_info(pkginfo, "pkgbase")
    pkgbase = pkgbases[0] if pkgbases else pkg
    pkgver = get_info(pkginfo, "pkgver")[0]
    src1 = f"{source_url}/{pkgbase}-{pkgver}.src.tar.zst"
    src2 = f"{source_url}/{pkgbase}-{pkgver}.src.tar.gz"
    if "github" in source_url:
        src1 = src1.replace("~", ".")
        src2 = src2.replace("~", ".")
    if not os.path.exists("src-cache/" + os.path.basename(src1)) and not os.path.exists(
        "src-cache/" + os.path.basename(src2)
    ):
        try:
            src_name = src1
            subprocess.check_call(
                [
                    "wget",
                    src1,
                    "-O",
                    "src-cache/" + os.path.basename(src1),
                    "--no-check-certificate",
                ]
            )
        except subprocess.CalledProcessError:
            os.remove("src-cache/" + os.path.basename(src1))
            try:
                src_name = src2
                subprocess.check_call(
                    [
                        "wget",
                        src2,
                        "-O",
                        "src-cache/" + os.path.basename(src2),
                        "--no-check-certificate",
                    ]
                )
            except subprocess.CalledProcessError:
                os.remove("src-cache/" + os.path.basename(src2))
                src_name = None
    elif os.path.exists("src-cache/" + os.path.basename(src1)):
        src_name = src1
    elif os.path.exists("src-cache/" + os.path.basename(src2)):
        src_name = src2
    else:
        src_name = None

    # get dependencies
    depends = get_info(pkginfo, "depend")
    depends = [dep for dep in depends if not dep.startswith("pacman")]
    license_text = get_info(pkginfo, "license")[0]
    spdx = license_text[5:] if license_text.startswith("spdx:") else license_text
    desc = get_info(pkginfo, "pkgdesc")[0]
    url = get_info(pkginfo, "url")[0]
    return depends, spdx, desc, url, src_name


while to_process:
    pkg = to_process.pop()
    pkg = provides.get(pkg, pkg)
    depends, spdx, desc, url, src_name = get_depends(pkg)
    for i, full_dep in enumerate(depends):
        dep = full_dep.split(">")[0].split("=")[0].split("<")[0]
        cond = full_dep[len(dep) :]
        dep = provides.get(dep, dep)
        if cond:
            depends[i] = f"{dep} {cond.replace('~', '!')}"
        else:
            depends[i] = dep
        if dep not in seen:
            to_process.add(dep)
    seen[pkg] = depends, spdx, desc, url, src_name


meta = f"""# This file is automatically generated by recipe/msys2-pkgs.py
package:
  name: m2w64-gcc
  version: {date}

source:"""

sources_template = """
  - url:
      - https://repo.msys2.org/mingw/{{ msys_type }}/{{ url_base }}
      - https://github.com/conda-forge/msys2-recipes/releases/download/{{ date }}-ucrt64/{{ url_base }}
    sha256: {{ sha256 }}
    folder: {{ type }}-{{ name }}{{ patches }}
"""

sources = {}

for pkg, (depends, spdx, desc, url, src_url) in seen.items():
    print(f"{pkg} {pkg_latest_ver[pkg]} {' '.join(depends)}")
    info = pkg_latest_ver[pkg]

    for t in ["binary", "source"]:
        if t == "source" and not src_url:
            continue
        patches = ""

        if t == "source":
            sha256 = (
                subprocess.check_output(
                    ["sha256sum", "src-cache/" + os.path.basename(src_url)]
                )
                .decode("utf-8")
                .split(" ")[0]
            )
            msys_type = "sources"
            url_base = os.path.basename(src_url)
        else:
            sha256 = (
                subprocess.check_output(["sha256sum", f"cache/{pkg}-{info}"])
                .decode("utf-8")
                .split(" ")[0]
            )
            msys_type = "x86_64"
            url_base = f"{pkg}-{info}"

        info = {
            "name": pkg.lower(),
            "tarname": f"{pkg}-{info}",
            "url_base": url_base,
            "sha256": sha256,
            "type": t,
            "msys_type": msys_type,
            "patches": patches,
            "date": date,
        }

        text = sources_template
        for k, v in info.items():
            text = text.replace(f"{{{{ {k} }}}}", v)
        sources[text] = True


meta += "".join(sources.keys())

meta += """
build:
  number: 4
  error_overlinking: false

outputs:"""

output_template = """
  - name: {{ name }}
    version: {{ version }}
    script: install_pkg.bat  # [build_platform.startswith("win-")]
    script: install_pkg.sh   # [not build_platform.startswith("win-")]
    build:
      noarch: generic
    requirements:
      host:
{{ depends }}
      run:
        - __unix   # [unix]
        - __win    # [win]
{{ depends }}
    about:
      home: {{ url }}
      license: {{ license }}
      summary: |
        {{ summary }}
"""


dep_map = {}

def get_version_from_info(info):
    return ".".join(info.split("-")[:2]).replace("~", "!")

for pkg, (depends, spdx, desc, url, src_url) in seen.items():
    print(f"{pkg} {pkg_latest_ver[pkg]} {' '.join(depends)}")
    info = pkg_latest_ver[pkg]
    text = output_template
    info = {
        "name": pkg.lower(),
        "version": get_version_from_info(info),
        "depends": "\n".join(f"        - {dep.lower()}" for dep in depends),
        "license": spdx,
        "summary": desc,
        "url": url,
    }
    dep_map[pkg] = depends
    for k, v in info.items():
        text = text.replace(f"{{{{ {k} }}}}", v)
    meta += text

# print(dep_map)

sysroot_version = get_version_from_info(pkg_latest_ver["mingw-w64-ucrt-x86_64-crt-git"])

meta += f"""
  - name: m2w64-sysroot_win-64
    version: {sysroot_version}
    build:
      noarch: generic
    requirements:
      run:
        - __unix   # [unix]
        - __win    # [win]
        - mingw-w64-ucrt-x86_64-windows-default-manifest
        - mingw-w64-ucrt-x86_64-crt-git
        - mingw-w64-ucrt-x86_64-headers-git
        - mingw-w64-ucrt-x86_64-winpthreads-git
    about:
      home: https://mingw-w64.sourceforge.io/
      summary: |
        MinGW-w64 sysroot for Windows

about:
  home: https://github.com/conda-forge/m2w64-gcc-feedstock
  summary: Repackaged mingw-w64 binaries

extra:
  recipe-maintainers:
    - isuruf
"""

recipe_dir = (
    "recipes/m2w64-gcc"
    if os.path.exists(os.path.join("recipes", "m2w64-gcc"))
    else "recipe"
)

with open(os.path.join(recipe_dir, "meta.yaml"), "w") as f:
    f.write(meta)
