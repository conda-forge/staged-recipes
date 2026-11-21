#!/usr/bin/env python
# Drop-in replacement for the upstream common/xsltproc.py that runs the XSLT
# transformations with Saxon-HE (Java, from the saxon-he conda package)
# instead of the saxonche Python bindings, which are not available on
# conda-forge. It accepts the same command line as the upstream script (which
# itself imitates net.sf.saxon.Transform):
#
#   xsltproc.py -xsl <stylesheet> -s <source> [-o <output>] [key=value ...]

import argparse
import glob
import os
import subprocess
import sys


def find_classpath() -> str:
    """Locate the Saxon-HE jars from the saxon-he conda package."""
    classpath = os.environ.get("SAXON_CLASSPATH") or os.environ.get("CLASSPATH")
    if classpath:
        return classpath
    for prefix_var in ("BUILD_PREFIX", "PREFIX", "CONDA_PREFIX"):
        prefix = os.environ.get(prefix_var)
        if not prefix:
            continue
        jars = glob.glob(os.path.join(prefix, "lib", "SaxonHE", "*.jar"))
        jars += glob.glob(os.path.join(prefix, "lib", "SaxonHE", "lib", "*.jar"))
        if jars:
            return os.pathsep.join(jars)
    raise RuntimeError(
        "Could not locate the Saxon-HE jars: set SAXON_CLASSPATH or CLASSPATH"
    )


def main() -> int:
    parser = argparse.ArgumentParser(
        prog="xsltproc.py",
        description="Runs net.sf.saxon.Transform from the saxon-he package.",
        epilog="Additional arguments in format key=value are passed through "
        "as stylesheet parameters",
    )
    parser.add_argument("-xsl", "--stylesheet_file", type=str, required=True)
    parser.add_argument("-s", "--source_file", type=str, required=True)
    parser.add_argument("-o", "--output_file", type=str, default=None)
    args, params = parser.parse_known_args()

    command = [
        "java",
        "-cp",
        find_classpath(),
        "net.sf.saxon.Transform",
        f"-xsl:{args.stylesheet_file}",
        f"-s:{args.source_file}",
    ]
    if args.output_file:
        command.append(f"-o:{args.output_file}")
    for param in params:
        if "=" not in param:
            parser.error(f"Unrecognized argument: {param}")
        command.append(param)

    # Without -o, Saxon writes the primary output to stdout; discard it, as
    # such invocations produce their real outputs via xsl:result-document
    stdout = None if args.output_file else subprocess.DEVNULL
    result = subprocess.run(command, stdout=stdout)
    return result.returncode


if __name__ == "__main__":
    sys.exit(main())
