"""Install the generated buf.validate module that protovalidate imports.

The PyPI wheel ships only the protovalidate package, but protovalidate does
`from buf.validate import validate_pb2`. Upstream keeps that generated code in
gen/buf/validate in the sdist, so install it next to protovalidate.
"""

import shutil
import sysconfig
from pathlib import Path

src = Path("gen", "buf", "validate")
dst = Path(sysconfig.get_paths()["purelib"], "buf", "validate")
dst.mkdir(parents=True, exist_ok=True)
for name in ("validate_pb2.py", "validate_pb2.pyi"):
    shutil.copy2(src / name, dst / name)
