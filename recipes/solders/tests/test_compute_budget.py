from solders.compute_budget import (
    request_heap_frame,
    set_compute_unit_limit,
    set_compute_unit_price,
)
from solders.instruction import Instruction


def test_compute_budget() -> None:
    assert isinstance(request_heap_frame(2048), Instruction)
    assert isinstance(set_compute_unit_limit(1_000_000), Instruction)
    assert isinstance(set_compute_unit_price(1000), Instruction)
