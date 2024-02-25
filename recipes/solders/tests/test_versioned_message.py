from pytest import fixture, raises
from solders.address_lookup_table_account import AddressLookupTableAccount
from solders.hash import Hash
from solders.instruction import AccountMeta, CompiledInstruction, Instruction
from solders.message import MessageAddressTableLookup, MessageHeader, MessageV0
from solders.pubkey import Pubkey
from solders.transaction import SanitizeError


@fixture
def default_header_with_one_req_signature() -> MessageHeader:
    default = MessageHeader.default()
    return MessageHeader(
        num_required_signatures=1,
        num_readonly_signed_accounts=default.num_readonly_signed_accounts,
        num_readonly_unsigned_accounts=default.num_readonly_unsigned_accounts,
    )


@fixture
def default_message() -> MessageV0:
    return MessageV0.default()


def test_sanitize(
    default_header_with_one_req_signature: MessageHeader, default_message: MessageV0
) -> None:
    MessageV0(
        header=default_header_with_one_req_signature,
        account_keys=[Pubkey.new_unique()],
        recent_blockhash=default_message.recent_blockhash,
        instructions=default_message.instructions,
        address_table_lookups=default_message.address_table_lookups,
    ).sanitize()


def test_sanitize_with_instruction(
    default_header_with_one_req_signature: MessageHeader, default_message: MessageV0
) -> None:
    MessageV0(
        header=default_header_with_one_req_signature,
        account_keys=[Pubkey.new_unique(), Pubkey.new_unique()],
        instructions=[
            CompiledInstruction(program_id_index=1, accounts=bytes([0]), data=bytes([]))
        ],
        recent_blockhash=default_message.recent_blockhash,
        address_table_lookups=default_message.address_table_lookups,
    ).sanitize()


def test_sanitize_with_table_lookup(
    default_header_with_one_req_signature: MessageHeader, default_message: MessageV0
) -> None:
    MessageV0(
        header=default_header_with_one_req_signature,
        account_keys=[Pubkey.new_unique()],
        address_table_lookups=[
            MessageAddressTableLookup(
                account_key=Pubkey.new_unique(),
                writable_indexes=bytes([1, 2, 3]),
                readonly_indexes=bytes([0]),
            )
        ],
        recent_blockhash=default_message.recent_blockhash,
        instructions=default_message.instructions,
    ).sanitize()


def test_sanitize_with_table_lookup_and_ix_with_dynamic_program_id(
    default_header_with_one_req_signature: MessageHeader, default_message: MessageV0
) -> None:
    message = MessageV0(
        header=default_header_with_one_req_signature,
        account_keys=[Pubkey.new_unique()],
        address_table_lookups=[
            MessageAddressTableLookup(
                account_key=Pubkey.new_unique(),
                writable_indexes=bytes([1, 2, 3]),
                readonly_indexes=bytes([0]),
            )
        ],
        instructions=[
            CompiledInstruction(
                program_id_index=4,
                accounts=bytes([0, 1, 2, 3]),
                data=bytes([]),
            )
        ],
        recent_blockhash=default_message.recent_blockhash,
    )
    with raises(SanitizeError):
        message.sanitize()


def test_sanitize_with_table_lookup_and_ix_with_static_program_id(
    default_header_with_one_req_signature: MessageHeader, default_message: MessageV0
) -> None:
    MessageV0(
        header=default_header_with_one_req_signature,
        account_keys=[Pubkey.new_unique(), Pubkey.new_unique()],
        address_table_lookups=[
            MessageAddressTableLookup(
                account_key=Pubkey.new_unique(),
                writable_indexes=bytes([1, 2, 3]),
                readonly_indexes=bytes([0]),
            )
        ],
        instructions=[
            CompiledInstruction(
                program_id_index=1, accounts=bytes([2, 3, 4, 5]), data=bytes([])
            )
        ],
        recent_blockhash=default_message.recent_blockhash,
    ).sanitize()


def test_sanitize_without_signer(
    default_header_with_one_req_signature: MessageHeader, default_message: MessageV0
) -> None:
    msg = MessageV0(
        header=MessageHeader.default(),
        account_keys=[Pubkey.new_unique()],
        recent_blockhash=default_message.recent_blockhash,
        instructions=default_message.instructions,
        address_table_lookups=default_message.address_table_lookups,
    )
    with raises(SanitizeError):
        msg.sanitize()


def test_sanitize_without_writable_signer(
    default_header_with_one_req_signature: MessageHeader, default_message: MessageV0
) -> None:
    msg = MessageV0(
        header=MessageHeader(
            num_required_signatures=1,
            num_readonly_signed_accounts=1,
            num_readonly_unsigned_accounts=MessageHeader.default().num_readonly_unsigned_accounts,
        ),
        account_keys=[Pubkey.new_unique()],
        recent_blockhash=default_message.recent_blockhash,
        instructions=default_message.instructions,
        address_table_lookups=default_message.address_table_lookups,
    )
    with raises(SanitizeError):
        msg.sanitize()


def test_sanitize_with_empty_table_lookup(
    default_header_with_one_req_signature: MessageHeader, default_message: MessageV0
) -> None:
    msg = MessageV0(
        header=default_header_with_one_req_signature,
        account_keys=[Pubkey.new_unique()],
        address_table_lookups=[
            MessageAddressTableLookup(
                account_key=Pubkey.new_unique(),
                writable_indexes=bytes([]),
                readonly_indexes=bytes([]),
            )
        ],
        recent_blockhash=default_message.recent_blockhash,
        instructions=default_message.instructions,
    )
    with raises(SanitizeError):
        msg.sanitize()


def test_sanitize_with_max_account_keys(
    default_header_with_one_req_signature: MessageHeader, default_message: MessageV0
) -> None:
    MessageV0(
        header=default_header_with_one_req_signature,
        account_keys=[Pubkey.new_unique() for i in range(256)],
        recent_blockhash=default_message.recent_blockhash,
        instructions=default_message.instructions,
        address_table_lookups=default_message.address_table_lookups,
    ).sanitize()


def test_sanitize_with_too_many_account_keys(
    default_header_with_one_req_signature: MessageHeader, default_message: MessageV0
) -> None:
    message = MessageV0(
        header=default_header_with_one_req_signature,
        account_keys=[Pubkey.new_unique() for i in range(257)],
        recent_blockhash=default_message.recent_blockhash,
        instructions=default_message.instructions,
        address_table_lookups=default_message.address_table_lookups,
    )
    with raises(SanitizeError):
        message.sanitize()


def test_sanitize_with_max_table_loaded_keys(
    default_header_with_one_req_signature: MessageHeader, default_message: MessageV0
) -> None:
    MessageV0(
        header=default_header_with_one_req_signature,
        account_keys=[Pubkey.new_unique()],
        address_table_lookups=[
            MessageAddressTableLookup(
                account_key=Pubkey.new_unique(),
                writable_indexes=bytes(range(0, 255, 2)),
                readonly_indexes=bytes(range(1, 255, 2)),
            )
        ],
        recent_blockhash=default_message.recent_blockhash,
        instructions=default_message.instructions,
    ).sanitize()


def test_sanitize_with_too_many_table_loaded_keys(
    default_header_with_one_req_signature: MessageHeader, default_message: MessageV0
) -> None:
    message = MessageV0(
        header=default_header_with_one_req_signature,
        account_keys=[Pubkey.new_unique()],
        address_table_lookups=[
            MessageAddressTableLookup(
                account_key=Pubkey.new_unique(),
                writable_indexes=bytes(range(0, 256, 2)),
                readonly_indexes=bytes(range(1, 256, 2)),
            )
        ],
        recent_blockhash=default_message.recent_blockhash,
        instructions=default_message.instructions,
    )
    with raises(SanitizeError):
        message.sanitize()


def test_sanitize_with_invalid_ix_program_id(
    default_header_with_one_req_signature: MessageHeader, default_message: MessageV0
) -> None:
    message = MessageV0(
        header=default_header_with_one_req_signature,
        account_keys=[Pubkey.new_unique()],
        address_table_lookups=[
            MessageAddressTableLookup(
                account_key=Pubkey.new_unique(),
                writable_indexes=bytes([0]),
                readonly_indexes=bytes([]),
            )
        ],
        instructions=[
            CompiledInstruction(
                program_id_index=2,
                accounts=bytes([]),
                data=bytes([]),
            )
        ],
        recent_blockhash=default_message.recent_blockhash,
    )
    with raises(SanitizeError):
        message.sanitize()
    with raises(SanitizeError):
        message.sanitize()


def test_sanitize_with_invalid_ix_account(
    default_header_with_one_req_signature: MessageHeader, default_message: MessageV0
) -> None:
    message = MessageV0(
        header=default_header_with_one_req_signature,
        account_keys=[Pubkey.new_unique(), Pubkey.new_unique()],
        address_table_lookups=[
            MessageAddressTableLookup(
                account_key=Pubkey.new_unique(),
                writable_indexes=bytes([]),
                readonly_indexes=bytes([0]),
            )
        ],
        instructions=[
            CompiledInstruction(program_id_index=1, accounts=bytes([3]), data=bytes([]))
        ],
        recent_blockhash=default_message.recent_blockhash,
    )
    with raises(SanitizeError):
        message.sanitize()


def test_try_compile() -> None:
    keys = [Pubkey.new_unique() for i in range(7)]
    payer = keys[0]
    program_id = keys[6]
    instructions = [
        Instruction(
            program_id,
            accounts=[
                AccountMeta(keys[1], True, True),
                AccountMeta(keys[2], True, False),
                AccountMeta(keys[3], False, True),
                AccountMeta(keys[4], False, True),
                AccountMeta(keys[5], False, False),
            ],
            data=bytes([]),
        )
    ]
    address_lookup_table_accounts = [
        AddressLookupTableAccount(
            key=Pubkey.new_unique(),
            addresses=[keys[4], keys[5], keys[6]],
        ),
        AddressLookupTableAccount(
            key=Pubkey.new_unique(),
            addresses=[],
        ),
    ]

    recent_blockhash = Hash.new_unique()
    assert MessageV0.try_compile(
        payer, instructions, address_lookup_table_accounts, recent_blockhash
    ) == MessageV0(
        header=MessageHeader(
            num_required_signatures=3,
            num_readonly_signed_accounts=1,
            num_readonly_unsigned_accounts=1,
        ),
        recent_blockhash=recent_blockhash,
        account_keys=[keys[0], keys[1], keys[2], keys[3], program_id],
        instructions=[
            CompiledInstruction(
                program_id_index=4,
                accounts=bytes([1, 2, 3, 5, 6]),
                data=bytes([]),
            ),
        ],
        address_table_lookups=[
            MessageAddressTableLookup(
                account_key=address_lookup_table_accounts[0].key,
                writable_indexes=bytes([0]),
                readonly_indexes=bytes([1]),
            )
        ],
    )
