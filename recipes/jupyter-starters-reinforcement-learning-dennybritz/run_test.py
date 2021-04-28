""" test a jupyter-starter

---

BSD 3-clause license
Copyright (c) 2021, conda-forge contributors
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors
may be used to endorse or promote products derived from this software without
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
"""

import json
import os
import pytest
import subprocess
import sys
from pathlib import Path

# TODO: parametrize most of the inputs

PREFIX = Path(os.environ["PREFIX"]).resolve()
PKG_NAME = os.environ["PKG_NAME"]
ROOT = PREFIX / f"share/jupyter/starters/{PKG_NAME}"
ETC = PREFIX / "etc/jupyter"
APPS = ["notebook", "server"]

# the solutions sometimes invoke big tensorflow calls
SKIP = ["Solution"]

NOTEBOOKS = sorted(
    [p for p in ROOT.rglob("*.ipynb") if not any(s in p.name for s in SKIP)]
)

# really just looking for broken imports
DISALLOWED_ERRORS = ["ModuleNotFoundError"]


@pytest.mark.parametrize("notebook,path", [[p.name, p] for p in NOTEBOOKS])
def test_nbconvert(notebook, path, capsys):
    print(str(path.relative_to(ROOT)))
    print("=" * 80)
    subprocess.call(
        [
            "jupyter",
            "nbconvert",
            "--execute",
            str(path),
            "--to",
            "html",
            "--ExecutePreprocessor.timeout=5",
        ]
    )
    captured = capsys.readouterr()
    print("=" * 80)
    print(captured.out)
    print("=" * 80)
    print(captured.err)
    for err in DISALLOWED_ERRORS:
        assert err not in captured.out, captured.out
        assert err not in captured.err, captured.err


@pytest.mark.parametrize("app", APPS)
def test_jupyter_config(app):
    conf_file = ETC / f"jupyter_{app}_config.d/{PKG_NAME}.json"
    conf_text = conf_file.read_text()
    print(conf_text)
    conf = json.loads(conf_text)
    for key, starter in conf["StarterManager"]["extra_starters"].items():
        src = Path(starter["src"]).resolve()
        assert src.exists()
        assert str(src).startswith(str(PREFIX))


if __name__ == "__main__":
    sys.exit(pytest.main([__file__, "-svv"]))
