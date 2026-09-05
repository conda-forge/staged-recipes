import importlib.util
from pathlib import Path
from tempfile import TemporaryDirectory

import drjit as dr
import mitsuba as mi


available_variants = mi.variants()
assert "llvm_ad_rgb" in available_variants
assert ("cuda_ad_rgb" in available_variants) == (
    importlib.util.find_spec("drjit.cuda") is not None
)

mi.set_variant("llvm_ad_rgb")
values = mi.Float([1, 2, 3]) + 1
dr.eval(values)
assert dr.all(values == [2, 3, 4])

mi.set_variant("scalar_rgb")

scene = mi.load_dict(
    {
        "type": "scene",
        "integrator": {"type": "path", "max_depth": 2},
        "sensor": {
            "type": "perspective",
            "to_world": mi.ScalarTransform4f().look_at(
                origin=[0, 0, 4], target=[0, 0, 0], up=[0, 1, 0]
            ),
            "film": {
                "type": "hdrfilm",
                "width": 8,
                "height": 8,
                "rfilter": {"type": "box"},
            },
            "sampler": {"type": "independent", "sample_count": 2},
        },
        "shape": {
            "type": "sphere",
            "bsdf": {
                "type": "diffuse",
                "reflectance": {"type": "rgb", "value": [0.7, 0.2, 0.1]},
            },
        },
        "emitter": {
            "type": "constant",
            "radiance": {"type": "rgb", "value": [1.0, 1.0, 1.0]},
        },
    }
)

image = mi.render(scene, seed=1)
assert tuple(image.shape) == (8, 8, 3)
assert float(dr.sum(image.array)) > 0

with TemporaryDirectory() as directory:
    exr_path = Path(directory) / "roundtrip.exr"
    mi.Bitmap(image).write(str(exr_path))
    bitmap = mi.Bitmap(str(exr_path))
    assert bitmap.width() == 8
    assert bitmap.height() == 8

# These libraries must come from their conda-forge packages, not from private
# copies installed into the Mitsuba package directory.
package_dir = Path(mi.__file__).resolve().parent
vendored_prefixes = (
    "libembree",
    "libHalf-mitsuba",
    "libIex-mitsuba",
    "libIexMath-mitsuba",
    "libIlmImf-mitsuba",
    "libIlmThread-mitsuba",
    "libImath-mitsuba",
    "libjpeg-mitsuba",
    "libOpenEXR",
    "libpng-mitsuba",
    "libpugixml",
)
vendored_libraries = sorted(
    path.name
    for path in package_dir.rglob("*")
    if path.is_file() and path.name.startswith(vendored_prefixes)
)
assert not vendored_libraries, f"Unexpected vendored libraries: {vendored_libraries}"
