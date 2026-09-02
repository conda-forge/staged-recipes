import drjit as dr
import mitsuba as mi


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
