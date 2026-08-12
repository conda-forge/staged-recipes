"""
patch_lv2.py  <path-to-tuxguitar-linux-swt/pom.xml>

Remove all traces of the tuxguitar-synth-lv2-linux module from the
tuxguitar-linux-swt build POM so that the conda-forge build does not
attempt to compile it.  lilv, suil, and Qt5 are not available on
conda-forge, so the lv2 native module cannot be built.

Three things are removed:
  1. The <module> element that lists tuxguitar-synth-lv2-linux.
  2. The <copy> block (opening tag + <fileset> + closing tag) that
     collects the lv2 build artefacts into the final distribution.
  3. The <chmod> element that marks the lv2-client binary executable.
"""

import re
import sys


def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <pom.xml>", file=sys.stderr)
        sys.exit(1)

    pom_path = sys.argv[1]
    with open(pom_path, encoding="utf-8") as fh:
        text = fh.read()

    # 1. Remove the <module> line referencing tuxguitar-synth-lv2-linux.
    text = re.sub(
        r"[ \t]*<module>[^<]*tuxguitar-synth-lv2-linux[^<]*</module>[ \t]*\n",
        "",
        text,
    )

    # 2. Remove the three-line <copy> block whose <fileset> points at the
    #    lv2 native-module build output directory.  The block looks like:
    #
    #        <copy todir="...">
    #            <fileset dir=".../tuxguitar-synth-lv2-linux/target/build" />
    #        </copy>
    #
    text = re.sub(
        r"[ \t]*<copy todir=\"[^\"]*\">[ \t]*\n"
        r"[ \t]*<fileset dir=\"[^\"]*tuxguitar-synth-lv2-linux[^\"]*\"[ \t]*/>"
        r"[ \t]*\n"
        r"[ \t]*</copy>[ \t]*\n",
        "",
        text,
    )

    # 3. Remove the <chmod> line for the lv2-client binary.
    text = re.sub(
        r"[ \t]*<chmod file=\"[^\"]*lv2-client[^\"]*\"[^/]*/>"
        r"[ \t]*\n",
        "",
        text,
    )

    with open(pom_path, "w", encoding="utf-8") as fh:
        fh.write(text)

    print(f"patch_lv2.py: lv2 entries removed from {pom_path}")


if __name__ == "__main__":
    main()
