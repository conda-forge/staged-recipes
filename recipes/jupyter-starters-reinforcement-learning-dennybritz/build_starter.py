"""build a jupyter-starter
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
