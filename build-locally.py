#!/bin/sh
"""exec" "python3" "$0" "$@" #"""  # fmt: off # fmt: on
# The line above this comment is a bash / sh / zsh guard
# to stop people from running it with the wrong interpreter

import glob
import os
import platform
import subprocess
import sys
from argparse import ArgumentParser
from subprocess import check_output


def verify_system():
    branch_name = check_output(
        ["git", "rev-parse", "--abbrev-ref", "HEAD"], text=True
    ).strip()
    if branch_name == "main":
        raise RuntimeError(
            "You should run build-locally from a new branch, not 'main'. "
            "Create a new one with:\n\n"
            "    git checkout -b your-chosen-branch-name\n"
        )


def setup_environment(ns):
    os.environ["CONFIG"] = ns.config
    os.environ["UPLOAD_PACKAGES"] = "False"
    os.environ["IS_PR_BUILD"] = "True"
    if ns.debug:
        os.environ["BUILD_WITH_CONDA_DEBUG"] = "1"
        if ns.output_id:
            os.environ["BUILD_OUTPUT_ID"] = ns.output_id
    if "MINIFORGE_HOME" not in os.environ:
        os.environ["MINIFORGE_HOME"] = os.path.join(
            os.path.dirname(__file__), "miniforge3"
        )
    if "OSX_SDK_DIR" not in os.environ:
        os.environ["OSX_SDK_DIR"] = os.path.join(os.path.dirname(__file__), "SDKs")

    # The default cache location might not be writable using docker on macOS.
    if ns.config.startswith("linux") and platform.system() == "Darwin":
        os.environ["CONDA_FORGE_DOCKER_RUN_ARGS"] = (
            "-e RATTLER_CACHE_DIR=/tmp/rattler_cache"
        )


def run_docker_build(ns):
    script = ".scripts/run_docker_build.sh"
    subprocess.check_call([script])


def run_osx_build(ns):
    script = ".scripts/run_osx_build.sh"
    subprocess.check_call([script])


def run_win_build(ns):
    script = ".scripts/run_win_build.bat"
    subprocess.check_call(["cmd", "/D", "/Q", "/C", f"CALL {script}"])


def verify_config(ns):
    choices_filter = ns.filter or "*"
    valid_configs = {
        os.path.basename(f)[:-5]
        for f in glob.glob(f".ci_support/{choices_filter}.yaml")
    }
    if choices_filter != "*":
        print(f"filtering for '{choices_filter}.yaml' configs")
    print(f"valid configs are {valid_configs}")
    if ns.config in valid_configs:
        print("Using " + ns.config + " configuration")
        return
    elif len(valid_configs) == 1:
        ns.config = valid_configs.pop()
        print("Found " + ns.config + " configuration")
    elif ns.config is None:
        print("config not selected, please choose from the following:\n")
        selections = list(enumerate(sorted(valid_configs), 1))
        for i, c in selections:
            print(f"{i}. {c}")
        try:
            s = input("\n> ")
        except KeyboardInterrupt:
            print("\nno option selected, bye!", file=sys.stderr)
            sys.exit(1)
        idx = int(s) - 1
        ns.config = selections[idx][1]
        print(f"selected {ns.config}")
    else:
        raise ValueError("config " + ns.config + " is not valid")
    if ns.config.startswith("osx") and platform.system() == "Darwin":
        if "OSX_SDK_DIR" not in os.environ:
            raise RuntimeError(
                "Need OSX_SDK_DIR env variable set. Run 'export OSX_SDK_DIR=/opt'"
                "to download the SDK automatically to '/opt/MacOSX<ver>.sdk'"
            )


def main(args=None):
    p = ArgumentParser("build-locally")
    p.add_argument("config", default=None, nargs="?")
    p.add_argument(
        "--filter",
        default=None,
        help="Glob string to filter which build choices are presented in interactive mode.",
    )
    p.add_argument(
        "--debug",
        action="store_true",
        help="Setup debug environment using `conda debug`",
    )
    p.add_argument("--output-id", help="If running debug, specify the output to setup.")

    ns = p.parse_args(args=args)
    verify_system()
    verify_config(ns)
    setup_environment(ns)

    if ns.config.startswith("linux") or (
        ns.config.startswith("osx") and platform.system() == "Linux"
    ):
        run_docker_build(ns)
    elif ns.config.startswith("osx"):
        run_osx_build(ns)
    elif ns.config.startswith("win"):
        run_win_build(ns)


if __name__ == "__main__":
    main()
