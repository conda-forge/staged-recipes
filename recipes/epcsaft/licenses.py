from importlib import metadata
from pathlib import Path
import nanobind
Path("licenses").mkdir(exist_ok=True)
dist = metadata.distribution("nanobind")
license_path = next(p for p in dist.files if str(p).endswith("/licenses/LICENSE"))
Path("licenses/nanobind-LICENSE").write_text(dist.locate_file(license_path).read_text())
header = Path(nanobind.__file__).parent / "ext/robin_map/include/tsl/robin_map.h"
Path("licenses/robin-map-LICENSE").write_text(header.read_text().split("*/", 1)[0] + "*/\n")
