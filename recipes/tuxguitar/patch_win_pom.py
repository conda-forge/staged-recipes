"""
patch_win_pom.py  <path-to-pom.xml>  <absolute-desktop-path>

Replace ${project.parent.relativePath} in the given pom.xml with an
absolute path to the desktop source directory.

The Windows build pom defines:

    <project.rootPath>${project.parent.relativePath}</project.rootPath>

where <relativePath> is "../../" (with a trailing slash).  When Maven
appends "/../common/resources/" to form an Ant fileset dir, the result
is "../..//../common/resources/".  On Windows, Java converts the forward
slashes to backslashes, yielding "..\\..\\..\\" — a double backslash in
the middle of a relative path — which Windows treats as a UNC path
prefix.  UNC paths with ".." components are illegal and Windows rejects
them with ERROR_INVALID_NAME (code 123).

Replacing ${project.parent.relativePath} with an absolute path (e.g.
"D:\\...\\work\\src\\desktop") avoids the double-slash entirely:
"D:\\...\\src\\desktop/../common/resources/" normalises cleanly to
"D:\\...\\src\\common\\resources\\".

Using a Python script instead of a PowerShell one-liner avoids the
fragile nested quoting that cmd.exe and PowerShell each apply when
passing strings through powershell -Command.
"""

import sys


def main():
    if len(sys.argv) != 3:
        print(
            f"Usage: {sys.argv[0]} <pom.xml> <absolute-desktop-path>",
            file=sys.stderr,
        )
        sys.exit(1)

    pom_path = sys.argv[1]
    desktop_path = sys.argv[2]

    with open(pom_path, encoding="utf-8") as fh:
        text = fh.read()

    placeholder = "${project.parent.relativePath}"
    if placeholder not in text:
        print(
            f"patch_win_pom.py: '{placeholder}' not found in {pom_path} — nothing to do",
            file=sys.stderr,
        )
        sys.exit(1)

    text = text.replace(placeholder, desktop_path)

    with open(pom_path, "w", encoding="utf-8") as fh:
        fh.write(text)

    print(
        f"patch_win_pom.py: replaced '{placeholder}' with '{desktop_path}' in {pom_path}"
    )

    # Diagnostic: print the resulting project.rootPath line so it appears in
    # the build log and confirms both that the script ran and what value was written.
    for line in text.splitlines():
        if "project.rootPath" in line:
            print(f"patch_win_pom.py: resulting line: {line.strip()}")


if __name__ == "__main__":
    main()
