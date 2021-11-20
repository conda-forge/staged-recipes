from typing import Dict
import os
import argparse
import json

DEFAULT_REQUIREMENTS_FILEPATH = "requirements.txt"

def load_requirements(path: str="requirements.txt") -> Dict[str, Dict[str, str]]:
    reqs = open(path, "r").readlines()

    lines = []
    for req in reqs:
        req = req.strip()
        if req and all(not req.startswith(x) for x in ["#", "//", "<!--"]):
            lines.append(req.strip().replace('"','').split(' = '))

    libs = dict((k,{'name': k, 'version': v}) for (k,v) in lines)
    del reqs, lines

    return libs

def main():

    parser = argparse.ArgumentParser(
        # prog="compose", # sys.argv[0]
        description='Fetch package dependencies from a file.',
        allow_abbrev=True,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
        add_help=True,
    )

    parser.add_argument(
        "-p", "--path", 
        type=str,
        default=DEFAULT_REQUIREMENTS_FILEPATH,
        help="Path to requirements' file.",
    )

    parser.add_argument(
        "-v", "--verbose",
        # when not specified, defaults to False: "store_true"
        action="store_true",
        help="Increase output verbosity."
    )

    args = parser.parse_args()

    return args

if __name__ == "__main__":
    
    args = main()
    libs = load_requirements(path=args.path)
    os.environ["PACKAGE_REQUIREMENTS_SPEC"] = libs
    if args.verbose:
        print(json.dumps(libs, indent=2))
