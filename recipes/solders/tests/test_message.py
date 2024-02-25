import pickle
from typing import List

from solders.hash import Hash
from solders.instruction import AccountMeta, CompiledInstruction, Instruction
from solders.keypair import Keypair
from solders.message import Message, MessageHeader, MessageV0
from solders.pubkey import Pubkey
from solders.transaction import Transaction

from .utils import ZERO_BYTES


def test_message_signed_keys_len() -> None:
    program_id = Pubkey.default()
    id0 = Pubkey.default()
    ix = Instruction(program_id, ZERO_BYTES, [AccountMeta(id0, False, True)])
    message = Message([ix], None)
    assert message.header.num_required_signatures == 0

    ix = Instruction(program_id, ZERO_BYTES, [AccountMeta(id0, True, True)])
    message = Message([ix], id0)
    assert message.header.num_required_signatures == 1


def test_message_kitchen_sink() -> None:
    program_id0 = Pubkey.new_unique()
    program_id1 = Pubkey.new_unique()
    id0 = Pubkey.default()
    id1 = Pubkey.new_unique()
    message = Message(
        [
            Instruction(program_id0, ZERO_BYTES, [AccountMeta(id0, False, True)]),
            Instruction(program_id1, ZERO_BYTES, [AccountMeta(id1, True, True)]),
            Instruction(program_id0, ZERO_BYTES, [AccountMeta(id1, False, True)]),
        ],
        id1,
    )
    assert message.instructions[0] == CompiledInstruction(2, ZERO_BYTES, bytes([1]))
    assert message.instructions[1] == CompiledInstruction(3, ZERO_BYTES, bytes([0]))
    assert message.instructions[2] == CompiledInstruction(2, ZERO_BYTES, bytes([0]))


def test_message_payer_first() -> None:
    program_id = Pubkey.default()
    payer = Pubkey.new_unique()
    id0 = Pubkey.default()

    ix = Instruction(program_id, ZERO_BYTES, [AccountMeta(id0, False, True)])
    message = Message([ix], payer)
    assert message.header.num_required_signatures == 1

    ix = Instruction(program_id, ZERO_BYTES, [AccountMeta(id0, True, True)])
    message = Message([ix], payer)
    assert message.header.num_required_signatures == 2

    ix = Instruction(
        program_id,
        ZERO_BYTES,
        [AccountMeta(payer, True, True), AccountMeta(id0, True, True)],
    )
    message = Message([ix], payer)
    assert message.header.num_required_signatures == 2


def test_program_position() -> None:
    program_id0 = Pubkey.default()
    program_id1 = Pubkey.new_unique()
    id_ = Pubkey.new_unique()
    message = Message(
        [
            Instruction(program_id0, ZERO_BYTES, [AccountMeta(id_, False, True)]),
            Instruction(program_id1, ZERO_BYTES, [AccountMeta(id_, True, True)]),
        ],
        id_,
    )
    assert message.program_position(0) is None
    assert message.program_position(1) == 0
    assert message.program_position(2) == 1


def test_is_writable() -> None:
    key0 = Pubkey.new_unique()
    key1 = Pubkey.new_unique()
    key2 = Pubkey.new_unique()
    key3 = Pubkey.new_unique()
    key4 = Pubkey.new_unique()
    key5 = Pubkey.new_unique()

    message = Message.new_with_compiled_instructions(
        num_required_signatures=3,
        num_readonly_signed_accounts=2,
        num_readonly_unsigned_accounts=1,
        account_keys=[key0, key1, key2, key3, key4, key5],
        recent_blockhash=Hash.default(),
        instructions=[],
    )
    assert message.is_writable(0)
    assert not message.is_writable(1)
    assert not message.is_writable(2)
    assert message.is_writable(3)
    assert message.is_writable(4)
    assert not message.is_writable(5)


def test_program_ids() -> None:
    key0 = Pubkey.new_unique()
    key1 = Pubkey.new_unique()
    loader2 = Pubkey.new_unique()
    instructions = [CompiledInstruction(2, b"", bytes([0, 1]))]
    message = Message.new_with_compiled_instructions(
        1,
        0,
        2,
        [key0, key1, loader2],
        Hash.default(),
        instructions,
    )
    assert message.program_ids() == [loader2]


def test_is_key_passed_to_program() -> None:
    key0 = Pubkey.new_unique()
    key1 = Pubkey.new_unique()
    loader2 = Pubkey.new_unique()
    instructions = [CompiledInstruction(2, b"", bytes([0, 1]))]
    message = Message.new_with_compiled_instructions(
        1,
        0,
        2,
        [key0, key1, loader2],
        Hash.default(),
        instructions,
    )

    assert message.is_key_passed_to_program(0)
    assert message.is_key_passed_to_program(1)
    assert not message.is_key_passed_to_program(2)


def test_is_non_loader_key() -> None:
    key0 = Pubkey.new_unique()
    key1 = Pubkey.new_unique()
    loader2 = Pubkey.new_unique()
    instructions = [CompiledInstruction(2, b"", bytes([0, 1]))]
    message = Message.new_with_compiled_instructions(
        1,
        0,
        2,
        [key0, key1, loader2],
        Hash.default(),
        instructions,
    )
    assert message.is_non_loader_key(0)
    assert message.is_non_loader_key(1)
    assert not message.is_non_loader_key(2)


def test_message_header_len_constant() -> None:
    assert MessageHeader.LENGTH == 3


def test_message_header_eq() -> None:
    assert MessageHeader.default() == MessageHeader.default()


def test_message_header_bytes() -> None:
    msg = MessageHeader.default()
    assert MessageHeader.from_bytes(bytes(msg)) == msg


def test_message_hash() -> None:
    # when this test fails, it's most likely due to a new serialized format of a message.
    # in this case, the domain prefix `solana-tx-message-v1` should be updated.
    program_id0 = Pubkey.from_string("4uQeVj5tqViQh7yWWGStvkEG1Zmhx6uasJtWCJziofM")
    program_id1 = Pubkey.from_string("8opHzTAnfzRpPEx21XtnrVTX28YQuCpAjcn1PczScKh")
    id0 = Pubkey.from_string("CiDwVBFgWV9E5MvXWoLgnEgn2hK7rJikbvfWavzAQz3")
    id1 = Pubkey.from_string("GcdayuLaLyrdmUu324nahyv33G5poQdLUEZ1nEytDeP")
    id2 = Pubkey.from_string("LX3EUdRUBUa3TbsYXLEUdj9J3prXkWXvLYSWyYyc2Jj")
    id3 = Pubkey.from_string("QRSsyMWN1yHT9ir42bgNZUNZ4PdEhcSWCrL2AryKpy5")
    instructions = [
        Instruction(program_id0, ZERO_BYTES, [AccountMeta(id0, False, True)]),
        Instruction(program_id0, ZERO_BYTES, [AccountMeta(id1, True, True)]),
        Instruction(
            program_id1,
            ZERO_BYTES,
            [AccountMeta(id2, False, False)],
        ),
        Instruction(
            program_id1,
            ZERO_BYTES,
            [AccountMeta(id3, True, False)],
        ),
    ]

    message = Message(instructions, id1)
    assert message.hash() == Hash.from_string(
        "7VWCF4quo2CcWQFNUayZiorxpiR5ix8YzLebrXKf3fMF"
    )


def test_new_with_nonce() -> None:
    program_id = Pubkey.default()
    arbitrary_instruction_data = bytes([1])
    accounts: List[AccountMeta] = []
    instruction = Instruction(program_id, arbitrary_instruction_data, accounts)
    payer = Keypair()
    nonce_account = Pubkey.default()
    message = Message.new_with_nonce(
        [instruction], payer.pubkey(), nonce_account, payer.pubkey()
    )
    Transaction.new_unsigned(message)
    # just check that no exceptions are raised


def test_pickle_msg_header() -> None:
    obj = MessageHeader.default()
    assert pickle.loads(pickle.dumps(obj)) == obj


def test_pickle_msg() -> None:
    obj = Message.default()
    assert pickle.loads(pickle.dumps(obj)) == obj


def test_json_msg_header() -> None:
    obj = MessageHeader.default()
    assert MessageHeader.from_json(obj.to_json()) == obj


def test_json_msg() -> None:
    obj = Message.default()
    assert Message.from_json(obj.to_json()) == obj


def test_pickle_msg_v0() -> None:
    obj = MessageV0.default()
    assert pickle.loads(pickle.dumps(obj)) == obj


def test_json_msg_v0() -> None:
    obj = MessageV0.default()
    assert MessageV0.from_json(obj.to_json()) == obj
