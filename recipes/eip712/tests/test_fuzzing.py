import string

import pytest
from eth_abi.tools._strategies import get_abi_strategy
from hypothesis import given, settings
from hypothesis import strategies as st

from eip712 import EIP712Message  # noqa: F401

abi_types = ["address"]
abi_types.extend(f"int{i}" for i in range(8, 256 + 8, 8))
abi_types.extend(f"uint{i}" for i in range(8, 256 + 8, 8))
abi_types = (
    abi_types  # all other types
    + [f"{t}[]" for t in abi_types]  # dynamic arrays
    + [f"{t}[{i}]" for i, t in zip(range(1, 10), abi_types)]  # static arrays
)


@settings(max_examples=5000)
@pytest.mark.fuzzing
@given(types=st.lists(st.sampled_from(abi_types), min_size=1, max_size=10), data=st.data())
def test_random_message_def(types, data):
    members = string.ascii_lowercase[: len(types)]
    members_str = "\n    ".join(f'{k}: "{t}"' for k, t in zip(members, types))

    exec(
        f"""class Msg(EIP712Message):
    _name_="test def"
    {members_str}""",
        globals(),
    )  # Creates `Msg` definition

    values = [data.draw(get_abi_strategy(t), label=t) for t in types]
    msg_dict = dict(zip(members, values))
    instance = Msg(**msg_dict)  # noqa: F821

    for k, v in msg_dict.items():
        assert getattr(instance, k) == v
