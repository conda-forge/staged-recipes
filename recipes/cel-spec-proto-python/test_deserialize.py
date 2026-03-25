"""Test that CEL protobuf stubs can deserialize expressions from cel-expr-python."""

from cel_expr_python.cel import NewEnv
from cel_spec_proto_python.expr.checked_pb2 import CheckedExpr
from google.protobuf.any_pb2 import Any

env = NewEnv()
ast = env.compile("1 + 2")
data = ast.serialize()

wrapper = Any()
wrapper.ParseFromString(data)
checked = CheckedExpr()
wrapper.Unpack(checked)

assert checked.expr.ByteSize() > 0, "expr should be populated"
assert checked.source_info.ByteSize() > 0, "source_info should be populated"
assert len(checked.type_map) > 0, "type_map should have entries"
assert len(checked.reference_map) > 0, "reference_map should have entries"

root = checked.expr
assert root.call_expr.function == "_+_", f"expected _+_, got {root.call_expr.function}"
assert len(root.call_expr.args) == 2
assert root.call_expr.args[0].const_expr.int64_value == 1
assert root.call_expr.args[1].const_expr.int64_value == 2

print("All assertions passed.")
