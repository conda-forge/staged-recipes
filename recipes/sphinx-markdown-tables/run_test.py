import re
import sys
import subprocess


def run(command):
    print(" ".join(command))
    rc = subprocess.run(
        command, capture_output=False, stderr=subprocess.STDOUT
    )
    if rc.returncode != 0:
        sys.exit(rc.returncode)


run(
    [
        "sphinx-quickstart",
        "--quiet",
        "-p",
        "test",
        "-a",
        "tester",
        "--extension",
        "sphinx_markdown_tables",
        "--extension",
        "recommonmark",
        ".",
    ]
)

run(["sphinx-build", "-M", "html", ".", "_build"])

error = None
try:
    with open("_build/html/test.html", "r") as f:
        contents = f.read()
        # check for expected table elements
        if not re.search("^<table ", contents, re.MULTILINE):
            error = "Missing <table> element"
        elif not re.search("^</table>", contents, re.MULTILINE):
            error = "Missing </table> element"
        else:
            matches = re.findall("^<tr>", contents, re.MULTILINE)
            if len(matches) != 4:
                error = "Incorrect number of <tr> elements"
            matches = re.findall("^</tr>", contents, re.MULTILINE)
            if len(matches) != 4:
                error = "Incorrect number of </tr> elements"
            matches = re.findall("^<td>", contents, re.MULTILINE)
            if len(matches) != 9:
                error = "Incorrect number of <td> elements"
            matches = re.findall("^<td>", contents, re.MULTILINE)
            if len(matches) != 9:
                error = "Incorrect number of </td> elements"
except Exception as e:
    error = "Error '{0}' occured. Arguments {1}.".format(e.message, e.args)

if error:
    print("Failure:", error)
    sys.exit(1)
else:
    print("Success")
    sys.exit(0)
