import os
from subprocess import Popen, PIPE
import pytest
import re
import sys
import shutil
import time
import textwrap
import socket
from urllib.request import urlopen
from pathlib import Path

WIN = os.name == "nt"

UTF8 = dict(encoding="utf-8")

BAD_HTML = """
<html/>
"""

GOOD_HTML = """<!DOCTYPE html>
<html lang="en-US">
    <head>
        <title>hello world</title>
        <meta charset="utf-8">
    </head>
    <body>
        <h1>hello world</h1>
    </body>
</html>
"""

HTML = {"bad": BAD_HTML, "good": GOOD_HTML}

VNU = shutil.which("vnu") or shutil.which("vnu.cmd")
JAVA = Path(shutil.which("java") or shutil.which("java.exe"))
JAR = Path(sys.prefix) / ("Library/lib" if WIN else "lib") / "vnu.jar"


def test_version():
    """Can it report its version?"""
    vnu("--version", expect_stdout=re.escape(os.environ["PKG_VERSION"]))


def test_help():
    """Can it provide help?"""
    vnu("--help")


@pytest.mark.parametrize("http", [True, False])
@pytest.mark.parametrize(
    "keys,rc,stdout,stderr",
    [
        ("good", 0, r"^$", r"^$"),
        ("bad", 1, r"^$", r"Start tag seen"),
        ("bad,good", 1, r"^$", r"Start tag seen"),
    ],
)
def test_files_cli(
    tmp_path: Path,
    a_vnu_client_http_args: list[str],
    keys: list[str],
    rc: int,
    stdout: str | None,
    stderr: str | None,
    http: bool,
):
    """Can it validate?"""
    htmls = []
    for key in keys.split(","):
        html = tmp_path / f"{key}.html"
        html.write_text(HTML[key].strip(), **UTF8)
        htmls.append(html)

    vnu(
        *htmls,
        expect_rc=rc,
        expect_stdout=stdout,
        expect_stderr=stderr,
        http=http,
        http_args=a_vnu_client_http_args,
    )


def vnu(
    *args,
    expect_rc=0,
    expect_stdout=None,
    expect_stderr=None,
    http=False,
    http_args=None,
):
    """Run vnu and look for output."""
    vnu_args = [str(VNU)]
    if http:
        vnu_args = http_args
        if expect_stderr is not None:
            # only writes to stdout
            expect_stdout = expect_stderr
            expect_stderr = None
    str_args = list(map(str, [*vnu_args, *args]))
    print("\t".join(str_args))
    proc = Popen(str_args, stdout=PIPE, stderr=PIPE, **UTF8)
    stdout, stderr = proc.communicate()
    proc.wait()
    rc = proc.returncode
    _indent_some(rc=rc, stdout=stdout, stderr=stderr)
    assert rc == expect_rc, f"vnu unexpectedly returned code: {rc}"
    if expect_stdout is not None:
        assert re.findall(expect_stdout, str(stdout if stdout else "").strip())
    if expect_stderr is not None:
        assert re.findall(expect_stderr, str(stderr if stderr else "").strip())
    return rc, stdout, stderr


@pytest.fixture()
def an_unused_port() -> int:
    """Find an unused network port (could still create race conditions)."""
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.bind(("127.0.0.1", 0))
    s.listen(1)
    port = s.getsockname()[1]
    s.close()
    return port


@pytest.fixture()
def a_vnu_client_http_args(an_unused_port: int):
    java = [str(JAVA), "-cp", str(JAR)]
    host = "127.0.0.1"
    server_args = [
        *java,
        f"-Dnu.validator.servlet.bind-address={host}",
        "nu.validator.servlet.Main",
        str(an_unused_port),
    ]
    server = Popen(server_args)

    retries = 5
    started = False
    last_error = None

    time.sleep(5)

    for retry in range(retries):
        try:
            urlopen(f"http://{host}:{an_unused_port}/", timeout=10)
            started = True
            break
        except Exception as err:
            last_error = err
            time.sleep(1)
            pass

    assert started, f"{last_error}"

    client_args = [
        *java,
        f"-Dnu.validator.client.port={an_unused_port}",
        f"-Dnu.validator.client.host={host}",
        "nu.validator.client.HttpClient",
    ]

    yield client_args
    server.terminate()
    server.kill()


def _indent_some(**label_text):
    for label, text in label_text.items():
        print("=" * 8, label, "=" * 8)
        print(textwrap.indent(str(text), " " * 8))


if __name__ == "__main__":
    pytest.main(["-vv", "--color=yes", __file__])
