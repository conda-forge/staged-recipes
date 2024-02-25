import pickle
from typing import Union, cast

from pytest import fixture, mark, raises
from solders.instruction import AccountMeta, CompiledInstruction, Instruction
from solders.pubkey import Pubkey


@fixture
def ix() -> Instruction:
    return Instruction(
        Pubkey.default(), b"1", [AccountMeta(Pubkey.new_unique(), True, True)]
    )


@fixture
def compiled_ix() -> CompiledInstruction:
    return CompiledInstruction(0, b"1", b"123")


@fixture
def am() -> AccountMeta:
    return AccountMeta(Pubkey.new_unique(), True, True)


def test_account_meta_hashable(am: AccountMeta) -> None:
    assert isinstance(hash(am), int)


def test_accounts_setter(ix: Instruction, am: AccountMeta) -> None:
    new_accounts = [am]
    ix.accounts = new_accounts
    assert ix.accounts == new_accounts


def test_ix_from_bytes(ix: Instruction) -> None:
    assert Instruction.from_bytes(bytes(ix)) == ix


def test_am_from_bytes(am: AccountMeta) -> None:
    assert AccountMeta.from_bytes(bytes(am)) == am


def test_accounts_setter_compiled_ix(compiled_ix: CompiledInstruction) -> None:
    ix = compiled_ix
    new_accounts = b"456"
    ix.accounts = new_accounts
    assert ix.accounts == new_accounts
    new_accounts_as_list = list(b"foo")
    ix.accounts = cast(bytes, new_accounts_as_list)
    assert ix.accounts == bytes(new_accounts_as_list)


def test_compiled_accounts_eq(compiled_ix: CompiledInstruction) -> None:
    assert (
        CompiledInstruction(
            compiled_ix.program_id_index, compiled_ix.data, compiled_ix.accounts
        )
        == compiled_ix
    )


@mark.parametrize("to_deserialize", [Instruction, CompiledInstruction])
def test_bincode_error(to_deserialize: Union[Instruction, CompiledInstruction]) -> None:
    with raises(ValueError) as excinfo:
        Instruction.from_bytes(b"foo")
    assert excinfo.value.args[0] == "io error: unexpected end of file"


def test_pickle_ix(ix: Instruction) -> None:
    assert pickle.loads(pickle.dumps(ix)) == ix


def test_pickle_compiled_ix(compiled_ix: CompiledInstruction) -> None:
    assert pickle.loads(pickle.dumps(compiled_ix)) == compiled_ix


def test_json_ix(ix: Instruction) -> None:
    assert Instruction.from_json(ix.to_json()) == ix


def test_json_compiled_ix(compiled_ix: CompiledInstruction) -> None:
    assert CompiledInstruction.from_json(compiled_ix.to_json()) == compiled_ix
