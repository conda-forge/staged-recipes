import base64
from typing import List

from solders import system_program as sp
from solders.hash import Hash
from solders.instruction import Instruction
from solders.keypair import Keypair
from solders.message import Message
from solders.presigner import Presigner
from solders.pubkey import Pubkey
from solders.transaction import Transaction


def test_id() -> None:
    assert Pubkey.from_string("11111111111111111111111111111111") == sp.ID


def get_keys(instruction: Instruction) -> List[Pubkey]:
    return [x.pubkey for x in instruction.accounts]


def test_move_many() -> None:
    alice_pubkey = Pubkey.new_unique()
    bob_pubkey = Pubkey.new_unique()
    carol_pubkey = Pubkey.new_unique()
    to_lamports = [(bob_pubkey, 1), (carol_pubkey, 2)]

    instructions = sp.transfer_many(alice_pubkey, to_lamports)
    assert len(instructions) == 2
    assert get_keys(instructions[0]) == [alice_pubkey, bob_pubkey]
    assert get_keys(instructions[1]) == [alice_pubkey, carol_pubkey]


def test_create_nonce_account() -> None:
    from_pubkey = Pubkey.new_unique()
    nonce_pubkey = Pubkey.new_unique()
    authorized = nonce_pubkey
    ixs = sp.create_nonce_account(from_pubkey, nonce_pubkey, authorized, 42)
    assert len(ixs) == 2
    ix = ixs[0]
    assert ix.program_id == sp.ID
    pubkeys = [am.pubkey for am in ix.accounts]
    assert from_pubkey in pubkeys
    assert nonce_pubkey in pubkeys


def test_create_account() -> None:
    """Test creating a transaction for create account."""
    params = sp.CreateAccountParams(
        from_pubkey=Keypair().pubkey(),
        to_pubkey=Keypair().pubkey(),
        lamports=123,
        space=1,
        owner=Pubkey.default(),
    )
    assert sp.decode_create_account(sp.create_account(params)) == params


def test_transfer() -> None:
    """Test creating a transaction for transfer."""
    params = sp.TransferParams(
        from_pubkey=Keypair().pubkey(), to_pubkey=Keypair().pubkey(), lamports=123
    )
    assert sp.decode_transfer(sp.transfer(params)) == params


def test_transfer_many() -> None:
    from_pubkey = Pubkey.new_unique()
    params = [
        sp.TransferParams(
            from_pubkey=from_pubkey, to_pubkey=Keypair().pubkey(), lamports=123
        )
        for i in range(3)
    ]
    to_lamports = [(p["to_pubkey"], p["lamports"]) for p in params]
    ixs = sp.transfer_many(from_pubkey, to_lamports)
    decoded = [sp.decode_transfer(ix) for ix in ixs]
    assert decoded == params


def test_assign() -> None:
    """Test creating a transaction for assign."""
    params = sp.AssignParams(
        pubkey=Keypair().pubkey(),
        owner=Pubkey(bytes([1]).rjust(Pubkey.LENGTH, b"\0")),
    )
    assert sp.decode_assign(sp.assign(params)) == params


def test_assign_with_seed() -> None:
    params = sp.AssignWithSeedParams(
        address=Pubkey.new_unique(),
        base=Pubkey.new_unique(),
        seed="你好",
        owner=Pubkey.new_unique(),
    )
    assert sp.decode_assign_with_seed(sp.assign_with_seed(params)) == params


def test_allocate() -> None:
    """Test creating a transaction for allocate."""
    params = sp.AllocateParams(
        pubkey=Keypair().pubkey(),
        space=12345,
    )
    assert sp.decode_allocate(sp.allocate(params)) == params


def test_allocate_with_seed() -> None:
    """Test creating a transaction for allocate with seed."""
    params = sp.AllocateWithSeedParams(
        address=Keypair().pubkey(),
        base=Pubkey(bytes([1]).rjust(Pubkey.LENGTH, b"\0")),
        seed="gqln",
        space=65537,
        owner=Pubkey(bytes([2]).rjust(Pubkey.LENGTH, b"\0")),
    )
    assert sp.decode_allocate_with_seed(sp.allocate_with_seed(params)) == params


def test_create_account_with_seed() -> None:
    """Test creating a an account with seed."""
    params = sp.CreateAccountWithSeedParams(
        from_pubkey=Keypair().pubkey(),
        to_pubkey=Pubkey(bytes([3]).rjust(Pubkey.LENGTH, b"\0")),
        base=Pubkey(bytes([1]).rjust(Pubkey.LENGTH, b"\0")),
        seed="gqln",
        lamports=123,
        space=4,
        owner=Pubkey(bytes([2]).rjust(Pubkey.LENGTH, b"\0")),
    )
    assert (
        sp.decode_create_account_with_seed(sp.create_account_with_seed(params))
        == params
    )


def test_initialize_nonce_account() -> None:
    params = sp.InitializeNonceAccountParams(
        nonce_pubkey=Keypair().pubkey(), authority=Keypair().pubkey()
    )
    assert (
        sp.decode_initialize_nonce_account(sp.initialize_nonce_account(params))
        == params
    )


def test_advance_nonce_account() -> None:
    params = sp.AdvanceNonceAccountParams(
        nonce_pubkey=Keypair().pubkey(), authorized_pubkey=Keypair().pubkey()
    )
    assert sp.decode_advance_nonce_account(sp.advance_nonce_account(params)) == params


def test_withdraw_nonce_account() -> None:
    params = sp.WithdrawNonceAccountParams(
        nonce_pubkey=Keypair().pubkey(),
        authorized_pubkey=Keypair().pubkey(),
        to_pubkey=Keypair().pubkey(),
        lamports=42,
    )
    assert sp.decode_withdraw_nonce_account(sp.withdraw_nonce_account(params)) == params


def test_authorize_nonce_account() -> None:
    params = sp.AuthorizeNonceAccountParams(
        nonce_pubkey=Keypair().pubkey(),
        authorized_pubkey=Keypair().pubkey(),
        new_authority=Keypair().pubkey(),
    )
    assert (
        sp.decode_authorize_nonce_account(sp.authorize_nonce_account(params)) == params
    )


def test_create_nonce_account2() -> None:
    from_keypair = Keypair.from_bytes(
        bytes(
            [
                134,
                123,
                27,
                208,
                227,
                175,
                253,
                99,
                4,
                81,
                170,
                231,
                186,
                141,
                177,
                142,
                197,
                139,
                94,
                6,
                157,
                2,
                163,
                89,
                150,
                121,
                235,
                86,
                185,
                22,
                1,
                233,
                58,
                133,
                229,
                39,
                212,
                71,
                254,
                72,
                246,
                45,
                160,
                156,
                129,
                199,
                18,
                189,
                53,
                143,
                98,
                72,
                182,
                106,
                69,
                29,
                38,
                145,
                119,
                190,
                13,
                105,
                157,
                112,
            ]
        )
    )
    nonce_keypair = Keypair.from_bytes(
        bytes(
            [
                139,
                81,
                72,
                75,
                252,
                57,
                73,
                247,
                63,
                130,
                201,
                76,
                183,
                43,
                60,
                197,
                65,
                154,
                28,
                240,
                134,
                0,
                232,
                108,
                61,
                123,
                56,
                26,
                35,
                201,
                13,
                39,
                188,
                128,
                179,
                175,
                136,
                5,
                89,
                185,
                92,
                183,
                175,
                131,
                56,
                53,
                228,
                11,
                20,
                34,
                138,
                148,
                51,
                27,
                205,
                76,
                75,
                148,
                184,
                34,
                74,
                129,
                238,
                225,
            ]
        )
    )

    cli_wire_txn = base64.b64decode(
        b"AtZYPHSaLIQsFnHm4O7Lk0YdQRzovtsp0eKbKRPknDvZINd62tZaLPRzhm6N1LeINLzy31iHY6QE0bGW5c9aegu9g9SQqwsj"
        b"dKfNTYI0JLmzQd98HCUczjMM5H/gvGx+4k+sM/SreWkC3y1X+I1yh4rXehtVW5Sqo5nyyl7z88wOAgADBTqF5SfUR/5I9i2g"
        b"nIHHEr01j2JItmpFHSaRd74NaZ1wvICzr4gFWblct6+DODXkCxQiipQzG81MS5S4IkqB7uEGp9UXGSxWjuCKhF9z0peIzwNc"
        b"MUWyGrNE2AYuqUAAAAan1RcZLFxRIYzJTD1K8X9Y2u4Im6H9ROPb2YoAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
        b"AAAAAABXbYHxIfw3Z5Qq1LH8aj6Sj6LuqbCuwFhAmo21XevlfwIEAgABNAAAAACAhB4AAAAAAFAAAAAAAAAAAAAAAAAAAAAA"
        b"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAwECAyQGAAAAOoXlJ9RH/kj2LaCcgccSvTWPYki2akUdJpF3vg1pnXA="
    )
    js_wire_txn = base64.b64decode(
        b"AkBAiPTJfOYZRLOZUpH7vIxyJQovMxO7X8FxXyRzae8CECBZ9LS5G8hxZVMdVL6uSIzLHb/0aLYhO5FEVmfhwguY5ZtOCOGqjwyAOVr8L2eBXgX482L/rcmF6ELORIcD1GdAFBQ/1Hc/LByer9TbJfNqzjesdzTJEHohnStduU4OAgADBTqF5SfUR/5I9i2gnIHHEr01j2JItmpFHSaRd74NaZ1wvICzr4gFWblct6+DODXkCxQiipQzG81MS5S4IkqB7uEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAan1RcZLFaO4IqEX3PSl4jPA1wxRbIas0TYBi6pQAAABqfVFxksXFEhjMlMPUrxf1ja7gibof1E49vZigAAAABXbYHxIfw3Z5Qq1LH8aj6Sj6LuqbCuwFhAmo21XevlfwICAgABNAAAAACAhB4AAAAAAFAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAwEDBCQGAAAAOoXlJ9RH/kj2LaCcgccSvTWPYki2akUdJpF3vg1pnXA="
    )
    cli_expected_txn = Transaction.from_bytes(cli_wire_txn)  # noqa: F841
    js_expected_txn = Transaction.from_bytes(js_wire_txn)

    create_account_ixs = sp.create_nonce_account(
        from_pubkey=from_keypair.pubkey(),
        nonce_pubkey=nonce_keypair.pubkey(),
        authority=from_keypair.pubkey(),
        lamports=2000000,
    )

    blockhash = Hash.from_string("6tHKVLgLBEm25jaDsmatPTfoeHqSobTecJMESteTkPS6")
    create_account_message = Message.new_with_blockhash(
        create_account_ixs, None, blockhash
    )
    create_account_txn = Transaction.new_unsigned(create_account_message)
    create_account_bytes = bytes(create_account_message)

    create_account_txn.partial_sign(
        [
            Presigner(
                from_keypair.pubkey(), from_keypair.sign_message(create_account_bytes)
            )
        ],
        blockhash,
    )
    create_account_txn.partial_sign(
        [
            Presigner(
                nonce_keypair.pubkey(), nonce_keypair.sign_message(create_account_bytes)
            )
        ],
        blockhash,
    )
    assert create_account_txn == js_expected_txn
    # XXX:  Cli message serialization do not sort on account metas producing discrepency
    # assert create_account_txn == cli_expected_txn


def test_create_nonce_account_with_seed() -> None:
    from_pubkey = Keypair().pubkey()
    nonce_pubkey = Pubkey(bytes([3]).rjust(Pubkey.LENGTH, b"\0"))
    base = Pubkey(bytes([1]).rjust(Pubkey.LENGTH, b"\0"))
    seed = "gqln"
    lamports = 123
    create_account_with_seed_params = sp.CreateAccountWithSeedParams(
        from_pubkey=from_pubkey,
        to_pubkey=nonce_pubkey,
        base=base,
        seed=seed,
        lamports=lamports,
        space=80,
        owner=sp.ID,
    )
    authority = Pubkey.new_unique()
    initialize_nonce_account_params = sp.InitializeNonceAccountParams(
        authority=authority, nonce_pubkey=nonce_pubkey
    )
    ixs = sp.create_nonce_account_with_seed(
        from_pubkey, nonce_pubkey, base, seed, authority, lamports
    )
    assert sp.decode_create_account_with_seed(ixs[0]) == create_account_with_seed_params
    assert sp.decode_initialize_nonce_account(ixs[1]) == initialize_nonce_account_params


def test_advance_nonce_and_transfer() -> None:
    from_keypair = Keypair.from_bytes(
        bytes(
            [
                134,
                123,
                27,
                208,
                227,
                175,
                253,
                99,
                4,
                81,
                170,
                231,
                186,
                141,
                177,
                142,
                197,
                139,
                94,
                6,
                157,
                2,
                163,
                89,
                150,
                121,
                235,
                86,
                185,
                22,
                1,
                233,
                58,
                133,
                229,
                39,
                212,
                71,
                254,
                72,
                246,
                45,
                160,
                156,
                129,
                199,
                18,
                189,
                53,
                143,
                98,
                72,
                182,
                106,
                69,
                29,
                38,
                145,
                119,
                190,
                13,
                105,
                157,
                112,
            ]
        )
    )
    nonce_keypair = Keypair.from_bytes(
        bytes(
            [
                139,
                81,
                72,
                75,
                252,
                57,
                73,
                247,
                63,
                130,
                201,
                76,
                183,
                43,
                60,
                197,
                65,
                154,
                28,
                240,
                134,
                0,
                232,
                108,
                61,
                123,
                56,
                26,
                35,
                201,
                13,
                39,
                188,
                128,
                179,
                175,
                136,
                5,
                89,
                185,
                92,
                183,
                175,
                131,
                56,
                53,
                228,
                11,
                20,
                34,
                138,
                148,
                51,
                27,
                205,
                76,
                75,
                148,
                184,
                34,
                74,
                129,
                238,
                225,
            ]
        )
    )
    to_keypair = Keypair.from_bytes(
        bytes(
            [
                56,
                246,
                74,
                56,
                168,
                158,
                189,
                97,
                126,
                149,
                175,
                70,
                23,
                14,
                251,
                206,
                172,
                69,
                61,
                247,
                39,
                226,
                8,
                68,
                97,
                159,
                11,
                196,
                212,
                57,
                2,
                1,
                252,
                124,
                54,
                3,
                18,
                109,
                223,
                27,
                225,
                28,
                59,
                202,
                49,
                248,
                244,
                17,
                165,
                33,
                101,
                59,
                217,
                79,
                234,
                217,
                251,
                85,
                9,
                6,
                40,
                0,
                221,
                10,
            ]
        )
    )

    cli_wire_txn = base64.b64decode(
        b"Abh4hJNaP/IUJlHGpQttaGNWkjOZx71uLEnVpT0SBaedmThsTogjsh87FW+EHeuJrsZii+tJbrq3oJ5UYXPzXwwBAAIFOoXl"
        b"J9RH/kj2LaCcgccSvTWPYki2akUdJpF3vg1pnXC8gLOviAVZuVy3r4M4NeQLFCKKlDMbzUxLlLgiSoHu4fx8NgMSbd8b4Rw7"
        b"yjH49BGlIWU72U/q2ftVCQYoAN0KBqfVFxksVo7gioRfc9KXiM8DXDFFshqzRNgGLqlAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
        b"AAAAAAAAAAAAAAAAAE13Mu8zaQSpG0zzGHpG62nK56DbGhuS4kXMF/ChHY1jAgQDAQMABAQAAAAEAgACDAIAAACAhB4AAAAA"
        b"AA=="
    )
    js_wire_txn = base64.b64decode(
        b"Af67rLfP5WxsOgvZWndq34S2KbQq++x03eZkZagzbVQ2tRyfFyn6OWByp8q3P2a03HDeVtpUWhq1y1a6R0DcPAIBAAIFOoXlJ9RH/kj2LaCcgccSvTWPYki2akUdJpF3vg1pnXC8gLOviAVZuVy3r4M4NeQLFCKKlDMbzUxLlLgiSoHu4fx8NgMSbd8b4Rw7yjH49BGlIWU72U/q2ftVCQYoAN0KAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAGp9UXGSxWjuCKhF9z0peIzwNcMUWyGrNE2AYuqUAAAE13Mu8zaQSpG0zzGHpG62nK56DbGhuS4kXMF/ChHY1jAgMDAQQABAQAAAADAgACDAIAAACAhB4AAAAAAA=="
    )

    cli_expected_txn = Transaction.from_bytes(cli_wire_txn)  # noqa: F841
    js_expected_txn = Transaction.from_bytes(js_wire_txn)
    instructions = [
        sp.advance_nonce_account(
            sp.AdvanceNonceAccountParams(
                nonce_pubkey=nonce_keypair.pubkey(),
                authorized_pubkey=from_keypair.pubkey(),
            )
        ),
        sp.transfer(
            sp.TransferParams(
                from_pubkey=from_keypair.pubkey(),
                to_pubkey=to_keypair.pubkey(),
                lamports=2000000,
            )
        ),
    ]
    blockhash = Hash.from_string("6DPp9aRRX6cLBqj5FepEvoccHFs3s8gUhd9t9ftTwAta")
    msg = Message.new_with_blockhash(instructions, from_keypair.pubkey(), blockhash)
    txn = Transaction.new_unsigned(msg)

    msg_bytes = bytes(msg)

    txn.partial_sign(
        [Presigner(from_keypair.pubkey(), from_keypair.sign_message(msg_bytes))],
        blockhash,
    )

    assert txn == js_expected_txn
    # XXX:  Cli message serialization do not sort on account metas producing discrepency
    # assert txn == cli_expected_txn
