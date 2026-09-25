"""Exercise the installed package and its bundled native runtime."""

from __future__ import annotations

import math
import os
import sys
from pathlib import Path

from riftco_transformer import Context, Tensor
from riftco_transformer.native import bindings


def native_filename() -> str:
    if sys.platform == "darwin":
        return "libriftco_transformer_c.dylib"
    if os.name == "nt":
        return "riftco_transformer_c.dll"
    return "libriftco_transformer_c.so"


def main() -> int:
    if os.environ.get("RIFTCO_TRANSFORMER_LIBRARY"):
        raise RuntimeError(
            "package smoke test must not use RIFTCO_TRANSFORMER_LIBRARY"
        )

    package_directory = Path(bindings.__file__).resolve().parents[1]
    bundled_library = package_directory / ".libs" / native_filename()
    if not bundled_library.is_file():
        raise RuntimeError(f"bundled native library is missing: {bundled_library}")

    candidates = bindings._candidate_libraries()
    if not candidates:
        raise RuntimeError("native loader found no candidate libraries")
    if Path(candidates[0]).resolve() != bundled_library.resolve():
        raise RuntimeError(
            "bundled library is not the loader's first candidate: "
            f"{candidates[0]}"
        )

    with Context("cpu") as context:
        if context.backend != "cpu":
            raise RuntimeError(f"unexpected backend: {context.backend}")
        with Tensor.from_data(context, (1, 2), (1.0, 2.0)) as left:
            with Tensor.from_data(context, (2, 1), (3.0, 4.0)) as right:
                with left.matmul(right) as product:
                    if product.shape != (1, 1):
                        raise RuntimeError(f"unexpected shape: {product.shape}")
                    values = product.tolist()
                    if len(values) != 1 or not math.isclose(values[0], 11.0):
                        raise RuntimeError(f"unexpected matmul result: {values}")

    library = bindings._native()
    loaded_path = Path(str(library._name)).resolve()
    if loaded_path != bundled_library.resolve():
        raise RuntimeError(
            f"loaded {loaded_path}, expected bundled {bundled_library.resolve()}"
        )
    if int(library.rt_abi_version()) != bindings.ABI_VERSION:
        raise RuntimeError("bundled native ABI does not match the Python client")

    print(f"package smoke test passed with {loaded_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
