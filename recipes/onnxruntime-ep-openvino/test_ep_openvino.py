import os
import sys

import numpy as np
import onnxruntime as ort
from onnx import TensorProto, helper, numpy_helper

device = sys.argv[1] if len(sys.argv) > 1 else "CPU"
if sys.platform == "win32":
    lib = os.path.join(sys.prefix, "Library", "bin", "onnxruntime_providers_openvino_plugin.dll")
else:
    lib = os.path.join(sys.prefix, "lib", "libonnxruntime_providers_openvino_plugin.so")
ort.register_execution_provider_library("OpenVINO", lib)

ov_devices = [d for d in ort.get_ep_devices() if d.ep_name == "OpenVINOExecutionProvider"]
print("OpenVINO EP devices:", [(d.device.type.name, dict(d.ep_metadata)) for d in ov_devices])
if not ov_devices:
    vendors = {hex(d.device.vendor_id) for d in ort.get_ep_devices()}
    assert "0x8086" not in vendors, vendors
    print(f"No Intel device ({vendors}), skipping inference")
    sys.exit(0)

rng = np.random.default_rng(0)
w = numpy_helper.from_array((rng.standard_normal((8, 3, 3, 3)) * 0.1).astype(np.float32), "w")
fc = numpy_helper.from_array((rng.standard_normal((8, 4)) * 0.1).astype(np.float32), "fc")
graph = helper.make_graph(
    [
        helper.make_node("Conv", ["x", "w"], ["c"], pads=[1, 1, 1, 1]),
        helper.make_node("Relu", ["c"], ["r"]),
        helper.make_node("GlobalAveragePool", ["r"], ["p"]),
        helper.make_node("Flatten", ["p"], ["f"]),
        helper.make_node("MatMul", ["f", "fc"], ["y"]),
    ],
    "ov_ep_test",
    [helper.make_tensor_value_info("x", TensorProto.FLOAT, [1, 3, 16, 16])],
    [helper.make_tensor_value_info("y", TensorProto.FLOAT, [1, 4])],
    initializer=[w, fc],
)
model = helper.make_model(graph, opset_imports=[helper.make_opsetid("", 17)])
model.ir_version = 9
data = model.SerializeToString()

x = rng.standard_normal((1, 3, 16, 16)).astype(np.float32)
ref = ort.InferenceSession(data, providers=["CPUExecutionProvider"]).run(None, {"x": x})[0]

chosen = [d for d in ov_devices if d.device.type.name == device]
assert chosen, (device, [d.device.type.name for d in ov_devices])
so = ort.SessionOptions()
so.add_provider_for_devices(chosen[:1], {})
so.add_session_config_entry("session.disable_cpu_ep_fallback", "1")
sess = ort.InferenceSession(data, sess_options=so)
out = sess.run(None, {"x": x})[0]
print("providers:", sess.get_providers(), "max abs diff:", float(np.abs(out - ref).max()))
assert "OpenVINOExecutionProvider" in sess.get_providers()
np.testing.assert_allclose(out, ref, rtol=1e-2, atol=1e-3)
print(f"OpenVINO EP plugin on {device} OK")
