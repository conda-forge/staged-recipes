#!/usr/bin/env python3
import os
import glob
import subprocess
from argparse import ArgumentParser
import platform

def setup_environment(ns):
    # Set environment variables for the build configuration
    os.environ["CONFIG"] = ns.config
    os.environ["UPLOAD_PACKAGES"] = "False"
    os.environ["IS_PR_BUILD"] = "True"
    
    if ns.debug:
        os.environ["BUILD_WITH_CONDA_DEBUG"] = "1"
        if ns.output_id:
            os.environ["BUILD_OUTPUT_ID"] = ns.output_id

    # Set default paths for Miniforge and SDK on Linux/macOS
    if "MINIFORGE_HOME" not in os.environ:
        os.environ["MINIFORGE_HOME"] = os.path.join(os.path.dirname(__file__), "miniforge3")
    if "OSX_SDK_DIR" not in os.environ and ns.config.startswith("osx") and platform.system() == "Darwin":
        os.environ["OSX_SDK_DIR"] = os.path.join(os.path.dirname(__file__), "SDKs")

def run_docker_build(ns):
    # Run a Docker build using the specified script
    script = ".scripts/run_docker_build.sh"
    subprocess.check_call([script])

def run_osx_build(ns):
    # Run an OS X build using the specified script
    script = ".scripts/run_osx_build.sh"
    subprocess.check_call([script])

def verify_config(ns):
    # Validate the selected configuration against available options
    valid_configs = {os.path.basename(f)[:-5] for f in glob.glob(".ci_support/*.yaml")}
    print(f"Valid configurations are {valid_configs}")

    if ns.config in valid_configs:
        print("Using " + ns.config + " configuration")
        return
    elif len(valid_configs) == 1:
        ns.config = valid_configs.pop()
        print("Found " + ns.config + " configuration")
    elif ns.config is None:
        print("Configuration not selected. Please choose from the following:\n")
        selections = list(enumerate(sorted(valid_configs), 1))
        for i, c in selections:
            print(f"{i}. {c}")
        s = input("\n> ")
        idx = int(s) - 1
        ns.config = selections[idx][1]
        print(f"Selected {ns.config}")
    else:
        raise ValueError("Configuration " + ns.config + " is not valid")

    # Additional validation can be added here

def main(args=None):
    p = ArgumentParser("build-locally")
    p.add_argument("config", default=None, nargs="?")
    p.add_argument(
        "--debug",
        action="store_true",
        help="Setup a debug environment using `conda debug`",
    )
    p.add_argument(
        "--output-id", help="If running in debug mode, specify the output to set up."
    )

    ns = p.parse_args(args=args)
    verify_config(ns)
    setup_environment(ns)

    if ns.config.startswith("linux") or (ns.config.startswith("osx") and platform.system() == "Linux"):
        run_docker_build(ns)
    elif ns.config.startswith("osx"):
        run_osx_build(ns)

if __name__ == "__main__":
    main()
