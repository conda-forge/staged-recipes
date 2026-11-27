"""Check that the installed Bilt package can evaluate a model in both directions."""

from bilt import Implementation, Interface, equation, field, system


@system
class Motion(metaclass=Interface):
    distance: float = field()
    speed: float = field()
    time: float = field()


@equation
def motion_relation(distance: float, speed: float, time: float) -> bool:
    return distance == speed * time


model = Implementation(Motion, [motion_relation])
with model:
    assert Motion(speed=20.0, time=5.0).distance == 100.0
    assert Motion(distance=100.0, time=5.0).speed == 20.0
