import pickle

from pytest import mark, raises
from solders.pubkey import Pubkey

on_curve_data = [
    (
        b"\xc1M\xce\x1e\xa4\x86<\xf1\xbc\xfc\x12\xf4\xf2\xe2Y"
        b"\xf4\x8d\xe4V\xb7\xf9\xd4\\!{\x04\x89j\x1f\xfeA\xdc",
        True,
    ),
    (
        b"6\x8d-\x96\xcf\xe7\x93G~\xe0\x17r\\\x9c%\x9a\xab\xa6"
        b"\xa9\xede\x02\xbf\x83=\x10,P\xfbh\x8ev",
        True,
    ),
    (
        b"\x00y\xf0\x82\xa6\x1c\xc7N\xa5\xe2\xab\xedd\xbb\xf7_2"
        b"\xfb\xddSz\xff\xf7RW\xedg\x16\xc9\xe3r\x99",
        False,
    ),
]


def test_wrong_size() -> None:
    with raises(ValueError) as excinfo:
        Pubkey(bytes([0] * 33))
    msg = "expected a sequence of length 32 (got 33)"
    assert excinfo.value.args[0] == msg


@mark.parametrize("test_input,expected", on_curve_data)
def test_is_on_curve_method(test_input: bytes, expected: bool) -> None:
    pubkey = Pubkey(test_input)
    result = pubkey.is_on_curve()
    assert result is expected


def test_length_classattr() -> None:
    assert Pubkey.LENGTH == 32


def test_bytes_representation() -> None:
    data = (
        b"6\x8d-\x96\xcf\xe7\x93G~\xe0\x17r\\\x9c%\x9a\xab\xa6"
        b"\xa9\xede\x02\xbf\x83=\x10,P\xfbh\x8ev"
    )
    pubkey = Pubkey(data)
    assert bytes(pubkey) == data


def test_equality() -> None:
    assert Pubkey.default() == Pubkey.default()


def test_create_with_seed() -> None:
    """Test create with seed."""
    default_public_key = Pubkey.default()
    derived_key = Pubkey.create_with_seed(
        default_public_key, "limber chicken: 4/45", default_public_key
    )
    expected = Pubkey.from_string("9h1HyLCW5dZnBVap8C5egQ9Z6pHyjsh5MNy83iPqqRuq")
    assert derived_key == expected


def test_create_program_address() -> None:
    """Test create program address."""
    program_id = Pubkey.from_string("BPFLoader1111111111111111111111111111111111")
    program_address = Pubkey.create_program_address([b"", bytes([1])], program_id)
    assert program_address == Pubkey.from_string(
        "3gF2KMe9KiC6FNVBmfg9i267aMPvK37FewCip4eGBFcT"
    )

    program_address = Pubkey.create_program_address([bytes("☉", "utf-8")], program_id)
    assert program_address == Pubkey.from_string(
        "7ytmC1nT1xY4RfxCV2ZgyA7UakC93do5ZdyhdF3EtPj7"
    )

    seeds = [bytes("Talking", "utf8"), bytes("Squirrels", "utf8")]
    program_address = Pubkey.create_program_address(seeds, program_id)
    assert program_address == Pubkey.from_string(
        "HwRVBufQ4haG5XSgpspwKtNd3PC9GM9m1196uJW36vds"
    )

    program_address = Pubkey.create_program_address(
        [bytes(Pubkey.from_string("SeedPubey1111111111111111111111111111111111"))],
        program_id,
    )
    assert program_address == Pubkey.from_string(
        "GUs5qLUfsEHkcMB9T38vjr18ypEhRuNWiePW2LoK4E3K"
    )

    program_address_2 = Pubkey.create_program_address(
        [bytes("Talking", "utf8")], program_id
    )
    assert program_address_2 != program_address

    # https://github.com/solana-labs/solana/issues/11950
    seeds = [
        bytes(Pubkey.from_string("H4snTKK9adiU15gP22ErfZYtro3aqR9BTMXiH3AwiUTQ")),
        bytes.fromhex("0200000000000000"),
    ]
    program_address = Pubkey.create_program_address(
        seeds, Pubkey.from_string("4ckmDgGdxQoPDLUkDT3vHgSAkzA3QRdNq5ywwY4sUSJn")
    )
    assert program_address == Pubkey.from_string(
        "12rqwuEgBYiGhBrDJStCiqEtzQpTTiZbh7teNVLuYcFA"
    )


def to_uint8_bytes(val: int) -> bytes:
    """Convert an integer to uint8."""
    return val.to_bytes(1, byteorder="little")


def test_find_program_address() -> None:
    """Test create associated_token_address."""
    program_id = Pubkey.from_string("BPFLoader1111111111111111111111111111111111")
    program_address, nonce = Pubkey.find_program_address([b""], program_id)
    assert program_address == Pubkey.create_program_address(
        [b"", to_uint8_bytes(nonce)], program_id
    )


def test_set_operations() -> None:
    """Tests that a publickey is now hashable with the appropriate set operations."""
    public_key_primary = Pubkey(bytes([0] * 32))
    public_key_secondary = Pubkey(bytes([1] * 32))
    public_key_duplicate = Pubkey(bytes(public_key_secondary))
    public_key_set = {public_key_primary, public_key_secondary, public_key_duplicate}
    assert isinstance(hash(public_key_primary), int)
    assert hash(public_key_primary) != hash(public_key_secondary)
    assert hash(public_key_secondary) == hash(public_key_duplicate)
    assert len(public_key_set) == 2


def test_pickle() -> None:
    key = Pubkey.new_unique()
    ser = pickle.dumps(key)
    deser = pickle.loads(ser)
    assert deser == key


def test_json() -> None:
    key = Pubkey.new_unique()
    ser = key.to_json()
    deser = Pubkey.from_json(ser)
    assert deser == key
