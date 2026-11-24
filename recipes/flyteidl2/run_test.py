"""Import every generated module and check the buf.validate rules are enforced.

flyteidl2 is generated protobuf code with no Python tests upstream. Its
messages carry buf.validate annotations that resolve against protovalidate's
buf.validate module (see use-protovalidate-buf.patch).
"""

import importlib
import pkgutil

import protovalidate

import flyteidl2
from flyteidl2.common.identifier_pb2 import ProjectIdentifier

modules = [
    m.name
    for m in pkgutil.walk_packages(flyteidl2.__path__, "flyteidl2.")
    if m.name.endswith("_pb2")
]
assert len(modules) > 50, modules
for name in modules:
    importlib.import_module(name)
print(f"imported {len(modules)} modules")

protovalidate.validate(ProjectIdentifier(organization="o", domain="d", name="n"))

try:
    protovalidate.validate(ProjectIdentifier(organization="o", domain="d"))
except protovalidate.ValidationError as e:
    assert [v.proto.field.elements[0].field_name for v in e.violations] == ["name"]
else:
    raise AssertionError("empty name should fail validation")
