from pathlib import Path

import pypestutils
from pypestutils.pestutilslib import PestUtilsLib

lib = PestUtilsLib()
lib_path = Path(lib.pestutils._name)
print(f"loaded {lib_path}")
assert lib_path.parent == Path(pypestutils.__file__).parent / "lib", lib_path
lib.initialize_randgen(1234)
lib.free_all_memory()
