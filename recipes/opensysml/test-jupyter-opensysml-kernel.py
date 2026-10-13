import subprocess
import sys
import re
import os

PKG_VERSION = os.environ["PKG_VERSION"]
CMD_HELP = ["jupyter-opensysml-kernel", "--help"]
CMD_VERSION = ["jupyter-opensysml-kernel", "--version"]
CMD_KERNELS = ["jupyter", "kernelspec", "list", "--json"]
CMD_EXT_LIST = ["jupyter", "labextension", "list"]
RE_EXT_OK = rf"jupyterlab-opensysml.*v{re.escape(PKG_VERSION)}.*enabled.*ok"


def do(cmd: list[str]) -> int:
    print("\n>>>", *cmd, flush=True)
    rc = subprocess.call(cmd)
    print("rc", rc, *cmd, "\n", flush=True)
    return rc


def check_kernel() -> int:
    res = subprocess.run(CMD_KERNELS, stdout=subprocess.PIPE, encoding="utf-8")
    assert "sysml-jupyter-kernel" in res.stdout
    return 0


def check_extension() -> int:
    res = subprocess.run(
        CMD_EXT_LIST, stdout=subprocess.PIPE, stderr=subprocess.PIPE, encoding="utf-8"
    )
    out = f"{res.stderr}{res.stdout}".lower()
    found = re.search(RE_EXT_OK, out)
    assert found, f"{RE_EXT_OK} not in {out}"
    return 0


if __name__ == "__main__":
    sys.exit(
        do(["pip", "check"])
        or do(CMD_HELP)
        or do(CMD_VERSION)
        or do(CMD_KERNELS)
        or do(CMD_EXT_LIST)
        or check_kernel()
        or check_extension()
    )
