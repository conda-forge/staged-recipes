"""build an (increasingly general) repository of notebooks into a conda package

Usage in meta.yaml:

build:
  noarch: python
  number: 0
  script: {{ PYTHON }} {{ RECIPE_DIR | replace('\\\\', '/') }}/build_starter.py {{ repo }} {{ author }}

---

BSD 3-clause license
Copyright (c) 2021, conda-forge contributors
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors
may be used to endorse or promote products derived from this software without
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
"""
import json
import os
import re
import shutil
import sys
from pathlib import Path

REPO = sys.argv[1]
AUTHOR = sys.argv[2]

RECIPE_DIR = Path(os.environ["RECIPE_DIR"])
SRC_DIR = Path(os.environ["SRC_DIR"])
PREFIX = Path(os.environ["PREFIX"])

PKG_NAME = os.environ["PKG_NAME"]
PKG_VERSION = os.environ["PKG_VERSION"]

CONFIG = RECIPE_DIR / "jupyter_config.json"
SHARE = PREFIX / "share/jupyter"
ETC = PREFIX / "etc/jupyter"
APPS = ["notebook", "server"]
ENC = dict(encoding="utf-8")


def build():
    src = SRC_DIR / PKG_NAME
    readme = src / "README.md"
    readme_txt = readme.read_text(**ENC)

    print("fixing README links to folders...")
    readme.write_text(
        re.sub(r"\]\((.*?)/\)", "](\\1/README.md)", readme_txt, flags=re.M), **ENC
    )

    dest = SHARE / f"starters/{PKG_NAME}"
    print(f"ensuring {dest.parent}")
    dest.parent.mkdir(parents=True, exist_ok=True)
    shutil.copytree(src, dest)

    config = json.loads(CONFIG.read_text(**ENC))
    extra_starters = config["StarterManager"].pop("extra_starters")
    starter = extra_starters["TODO"]

    contents_path = f"{REPO}-{AUTHOR}"

    starter.update(
        label=f"{REPO} [{AUTHOR}]",
        description=f"{REPO}. {AUTHOR}, {PKG_VERSION}",
        src=str(dest),
        dest=contents_path,
        icon=starter["icon"].replace(
            "TODO", "".join([b[0] for b in REPO.split("-")] + [AUTHOR[0]]).upper()
        ),
        commands=[
            {
                "id": "filebrowser:open-path",
                "args": {"path": contents_path},
            },
            {
                "id": "markdownviewer:open",
                "args": {"path": f"{contents_path}/README.md"},
            },
        ],
    )

    starter["schema"].update(
        description=re.sub(r"\[(.*?)\]\(.*?\)", "_\\1_", readme_txt, flags=re.M),
        title=f"# {REPO}\n> {AUTHOR} `{PKG_VERSION}` [GitHub](https://github.com/{AUTHOR}/{REPO})",
    )

    starter["schema"]["properties"]["ready"].update(
        description=f"This will make a copy in {contents_path}"
    )

    config["StarterManager"]["extra_starters"] = {PKG_NAME: starter}

    text = json.dumps(config, indent=2, sort_keys=True)

    print(f"config:\n{text}")
    assert "TODO" not in text

    for app in APPS:
        dest = ETC / f"jupyter_{app}_config.d" / f"{PKG_NAME}.json"
        print(f"ensuring {dest.parent}")
        dest.parent.mkdir(exist_ok=True, parents=True)
        print(f"writing {dest}")
        dest.write_text(text, **ENC)


if __name__ == "__main__":
    build()
