import re
import subprocess
from importlib.util import find_spec
from pathlib import Path

package_root = Path(find_spec("epcsaft").origin).parent
generic_sonames = {"libblas.so.3", "liblapack.so.3", "libcblas.so.3"}
blas_library = re.compile(r"lib.*(?:blas|lapack|blis|mkl|atlas|acml|essl|aocl)")
for library in sorted(package_root.rglob("*.so*")):
    dynamic = subprocess.check_output(["readelf", "-d", library], text=True)
    for soname in re.findall(r"\(NEEDED\).*?\[([^\]]+)\]", dynamic):
        assert not blas_library.match(soname) or soname in generic_sonames, (
            f"{library.name} needs {soname}; expected a generic BLAS/LAPACK SONAME"
        )
