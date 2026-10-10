"""Cross-platform build script for ppt-master conda recipe.

Called by both build.sh (Linux/macOS) and bld.bat (Windows).
All file operations use Python so encoding is handled correctly on every OS.
"""
import os
import shutil
import subprocess
import sys
from pathlib import Path

RECIPE_DIR = Path(os.environ["RECIPE_DIR"])
PREFIX = Path(os.environ["PREFIX"])
PYTHON = os.environ["PYTHON"]
SRC = Path(".")  # rattler-build cds into the source tree before running

SKILL = SRC / "skills" / "ppt-master"
SHARE = PREFIX / "share" / "ppt-master"

ASCII_LAYOUTS = [
    "academic_defense", "ai_ops", "anthropic", "china_telecom_template",
    "exhibit", "google_style", "government_blue", "government_red",
    "mckinsey", "medical_university", "pixel_retro", "psychology_attachment",
    "smart_red",
]


def patch_config() -> None:
    """Make config.py find data at $PREFIX/share/ppt-master when installed."""
    path = SKILL / "scripts" / "config.py"
    text = path.read_text(encoding="utf-8")

    if "\nimport sys\n" not in text:
        text = text.replace(
            "from pathlib import Path\n",
            "import sys\nfrom pathlib import Path\n",
            1,
        )

    old = "PROJECT_ROOT = Path(__file__).parent.parent"
    new = (
        '_SCRIPTS_DIR = Path(__file__).parent\n'
        '_INSTALLED_SHARE = Path(sys.prefix) / "share" / "ppt-master"\n'
        'PROJECT_ROOT = (\n'
        '    _SCRIPTS_DIR.parent\n'
        '    if (_SCRIPTS_DIR.parent / "templates").exists()\n'
        '    else _INSTALLED_SHARE\n'
        ')\n'
        'del _INSTALLED_SHARE, _SCRIPTS_DIR'
    )
    assert old in text, f"Expected pattern not found in config.py: {old!r}"
    text = text.replace(old, new, 1)
    path.write_text(text, encoding="utf-8")
    print("Patched config.py")


def copy_skill_data() -> None:
    """Copy ASCII-named skill files to $PREFIX/share/ppt-master/."""
    SHARE.mkdir(parents=True, exist_ok=True)

    shutil.copy2(SKILL / "SKILL.md", SHARE / "SKILL.md")

    for subdir in ("references", "workflows", "scripts"):
        dest = SHARE / subdir
        if dest.exists():
            shutil.rmtree(dest)
        shutil.copytree(str(SKILL / subdir), str(dest))

    templates_src = SKILL / "templates"
    templates_dst = SHARE / "templates"
    templates_dst.mkdir(exist_ok=True)

    for fname in ("README.md", "design_spec_reference.md", "spec_lock_reference.md"):
        src = templates_src / fname
        if src.exists():
            shutil.copy2(str(src), str(templates_dst / fname))

    for subdir in ("charts", "icons"):
        dst = templates_dst / subdir
        if dst.exists():
            shutil.rmtree(dst)
        shutil.copytree(str(templates_src / subdir), str(dst))

    layouts_src = templates_src / "layouts"
    layouts_dst = templates_dst / "layouts"
    layouts_dst.mkdir(exist_ok=True)

    for fname in ("README.md", "layouts_index.json"):
        src = layouts_src / fname
        if src.exists():
            shutil.copy2(str(src), str(layouts_dst / fname))

    for name in ASCII_LAYOUTS:
        src = layouts_src / name
        dst = layouts_dst / name
        if src.is_dir():
            if dst.exists():
                shutil.rmtree(dst)
            shutil.copytree(str(src), str(dst))

    print(f"Copied skill data to {SHARE}")


def main() -> None:
    os.environ["PYTHONIOENCODING"] = "utf-8"

    print("==> Copying packaging files from recipe dir")
    shutil.copy2(str(RECIPE_DIR / "pyproject.toml"), "pyproject.toml")
    shutil.copy2(
        str(RECIPE_DIR / "ppt_master_install.py"),
        str(SKILL / "scripts" / "ppt_master_install.py"),
    )

    print("==> Creating source_to_md/__init__.py")
    init = SKILL / "scripts" / "source_to_md" / "__init__.py"
    init.touch()

    print("==> Patching config.py")
    patch_config()

    print("==> Running pip install")
    subprocess.run(
        [PYTHON, "-m", "pip", "install", ".", "--no-deps", "--no-build-isolation", "-vv"],
        check=True,
    )

    print("==> Copying skill data to share/")
    copy_skill_data()

    print("==> Build complete")


if __name__ == "__main__":
    main()
