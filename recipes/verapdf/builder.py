import os, sys, subprocess, zipfile, tempfile, shutil, textwrap, stat
from pprint import pprint
from pathlib import Path
import platform

UTF8 = dict(encoding="utf-8")
EXE_NAMES = ["verapdf", "verapdf-gui"]

CI = os.environ.get("CI")

WIN = platform.system() == "Windows"
INSTALL_SCRIPT = "verapdf-install.bat" if WIN else "verapdf-install"
RG_PATH = Path(r"C:\Miniforge\Library\bin\rg.exe")

SRC_DIR = Path(os.environ["SRC_DIR"])
PKG_VERSION = os.environ["PKG_VERSION"]
PREFIX = Path(os.environ["PREFIX"])
DEST = PREFIX / ("Library/verapdf" if WIN else "share/verapdf")

MVN_EXE = Path(
    shutil.which("mvn")
    or shutil.which("mvn.exe")
    or shutil.which("mvn.bat")
    or shutil.which("mvn.cmd")
)
MVN_OPTS = [str(MVN_EXE), "--batch-mode"]


def mvn(args):
    final_args = list(map(str, [*MVN_OPTS, *args]))
    print(">>>", "\t".join(final_args), flush=True)
    rc = subprocess.call(final_args)
    if rc:
        sys.exit(1)
    print("...  OK", "\t".join(final_args), flush=True)


def build():
    mvn(["versions:set", f"-DnewVersion={PKG_VERSION}"])
    mvn(["clean"])
    mvn(["install", "-DskipTests"])


def install():
    src_auto_install = SRC_DIR / "auto-install-tmp.xml"

    zip_name = f"verapdf-greenfield-{PKG_VERSION}-installer.zip"

    with tempfile.TemporaryDirectory() as td:
        tdp = Path(td)
        zip_path = SRC_DIR / "installer/target" / zip_name
        print("... extracting", zip_path)
        print("   -->", td, flush=True)
        with zipfile.ZipFile(str(zip_path)) as zf:
            zf.extractall(td)
        pprint(sorted(tdp.rglob("*")))
        inst_dir = tdp / f"verapdf-greenfield-{PKG_VERSION}"
        tmp_auto_install = inst_dir / "auto-install.xml"
        print("... updating", tmp_auto_install, flush=True)
        tmp_auto_install.write_text(
            src_auto_install.read_text(**UTF8).replace(
                "/tmp/verapdf",
                DEST.resolve().as_posix(),
            ),
            **UTF8,
        )
        print(textwrap.indent(tmp_auto_install.read_text(**UTF8), "\t\t"), flush=True)

        script = inst_dir / INSTALL_SCRIPT
        script.chmod(script.stat().st_mode | stat.S_IEXEC)

        rc = subprocess.call([str(script), tmp_auto_install.name], cwd=str(inst_dir))
        if rc:
            sys.exit(rc)


def deploy():
    for exe_name in EXE_NAMES:
        if WIN:
            script_src = DEST / f"{exe_name}.bat"
            script_dest = PREFIX / "Scripts" / script_src.name
        else:
            script_src = DEST / exe_name
            script_dest = PREFIX / "bin" / script_src.name

        script_dest.parent.mkdir(parents=True, exist_ok=True)

        print("... linking", script_src)
        print("   -->", script_dest)

        if WIN:
            make_bat_wrapper(script_src, script_dest)
        else:
            script_dest.symlink_to(script_src)


def make_bat_wrapper(script_src: Path, script_dest: Path):
    lines = [
        "@ECHO OFF",
        f"""CALL "{script_src.resolve()}" %* || EXIT 1""",
    ]

    script_dest.write_bytes(rb"\r\n".join([line.encode("utf-8") for line in lines]))


def clean():
    for path in [DEST / "Uninstaller"]:
        print("... cleaning", path, flush=True)
        shutil.rmtree(path)

    if CI and WIN and RG_PATH.exists():
        print(
            "... removing ripgrep for https://github.com/conda/conda-build/issues/4357"
        )
        RG_PATH.unlink()


def main() -> int:
    build()
    install()
    deploy()
    clean()
    return 0


if __name__ == "__main__":
    sys.exit(main())
