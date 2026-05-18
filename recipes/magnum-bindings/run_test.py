from magnum import Deg, Matrix3x3, Vector3, math


assert Deg(30.0) + Deg(15.0) == Deg(45.0)
assert math.div(16, 5) == (3, 1)

vector = Vector3(1.0, 2.0, 3.0)
assert vector + Vector3.y_axis() == Vector3(1.0, 3.0, 3.0)

matrix = Matrix3x3.identity_init(2.0)
assert matrix[0] == Vector3(2.0, 0.0, 0.0)
assert matrix[1] == Vector3(0.0, 2.0, 0.0)
assert matrix[2] == Vector3(0.0, 0.0, 2.0)
