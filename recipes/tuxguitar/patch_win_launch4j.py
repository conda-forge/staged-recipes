"""
patch_win_launch4j.py  <path-to-pom.xml>  <phase>

Rebind the launch4j-maven-plugin's "l4j-clui" execution to <phase>.

build.bat needs to run the "tuxguitar-windows-swt-x86_64" reactor's build
twice: once to compile/install the jars (with maven-antrun-plugin's
resource-copy skipped via -Dmaven.antrun.skip=true, because Ant's fileset
resolution fails on Windows), and once -- after a robocopy step fills in
dist/ by hand -- to actually produce tuxguitar.exe.

launch4j-maven-plugin 2.1.2 only reads its <jar>/<icon>/<outfile>/etc.
configuration when its execution is triggered through a bound lifecycle
phase; invoking `mvn ...:launch4j` directly from the command line creates
an unconfigured synthetic "default-cli" execution that silently ignores
the pom's <configuration> and falls back to the plugin's built-in
defaults (e.g. target/<artifactId>-<version>.jar), which don't exist.

So this script is called twice: first with phase "none" to unbind
l4j-clui for the initial build (it would otherwise run during the
package phase before dist/tuxguitar.ico exists and fail with "Icon
doesn't exist."), then with phase "package" to rebind it before the
second, --non-recursive `mvn package` call that builds tuxguitar.exe.
"""

import re
import sys


def main():
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <pom.xml> <phase>", file=sys.stderr)
        sys.exit(1)

    pom_path = sys.argv[1]
    phase = sys.argv[2]

    with open(pom_path, encoding="utf-8") as fh:
        text = fh.read()

    pattern = re.compile(r"(<id>l4j-clui</id>\s*<phase>)[^<]*(</phase>)")
    text, count = pattern.subn(rf"\g<1>{phase}\g<2>", text, count=1)

    if count == 0:
        print(
            f"patch_win_launch4j.py: expected l4j-clui block not found in {pom_path}",
            file=sys.stderr,
        )
        sys.exit(1)

    with open(pom_path, "w", encoding="utf-8") as fh:
        fh.write(text)

    print(f"patch_win_launch4j.py: rebound l4j-clui execution phase to '{phase}' in {pom_path}")


if __name__ == "__main__":
    main()
