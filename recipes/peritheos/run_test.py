"""Exercise the installed native extension and packaged scientific data."""

import json
from importlib import resources
from importlib.metadata import version

import numpy as np
import peritheos
import peritheos._rust
from peritheos import get_material, get_material_document, list_material_documents
from peritheos.eos.rt import BM3

assert peritheos.__version__ == version("peritheos")

eos = BM3(V0=10.0, K0=120.0, K0_prime=4.0)
volumes = np.array([10.0, 9.0, 8.0])
pressures = eos.pressure(volumes)
np.testing.assert_allclose(pressures[0], 0.0, atol=1e-12)
assert np.all(np.diff(pressures) > 0)
np.testing.assert_allclose(eos.volume(pressures), volumes, rtol=1e-8)

package = resources.files("peritheos")
assert package.joinpath("py.typed").is_file()
manifest = json.loads(
    package.joinpath("data").joinpath("materials").joinpath("manifest.json").read_text()
)
documents = [
    get_material_document(identifier) for identifier in list_material_documents()
]
assert len(documents) == manifest["materials"]
assert sum(len(document["eos_records"]) for document in documents) == manifest["eos_records"]

dataset = get_material("coesite").get_dataset("coesite_levien_1981_table7_pv")
data = dataset.as_pressure_volume(pressure_unit="GPa")
assert dataset.checksum_verified is True
np.testing.assert_allclose(data.pressure[:3], [0.0001, 2.18, 2.24])
np.testing.assert_allclose(data.volume[:3], [546.46, 535.47, 535.1])

print("Peritheos native extension, EOS inversion, material catalog, and CSV data passed.")
