from solders.pubkey import Pubkey
from solders.token.state import Mint, TokenAccount, TokenAccountState


def test_unpack_token_account() -> None:
    token_account_bytes = b"\xc6\xfaz\xf3\xbe\xdb\xad:=e\xf3j\xab\xc9t1\xb1\xbb\xe4\xc2\xd2\xf6\xe0\xe4|\xa6\x02\x03E/]a`e\x01\xb3\x02\xe1\x80\x18\x92\xf8\n)y\xf5\x85\xf8\x85]\x0f 4y\n$U\xf7D\xfa\xc5\x03\xd7\xb5\xb5V:\xc4}\x98\x0f\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
    parsed = TokenAccount.from_bytes(token_account_bytes)
    expected = TokenAccount(
        mint=Pubkey.from_string("EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v"),
        owner=Pubkey.from_string("7VHUFJHWu2CuExkJcJrzhQPJ2oygupTWkL2A2For4BmE"),
        amount=4389790581151413,
        delegate=None,
        state=TokenAccountState.Initialized,
        is_native=None,
        delegated_amount=0,
        close_authority=None,
    )
    assert parsed == expected
    assert bytes(parsed) == token_account_bytes


def test_unpack_mint_account() -> None:
    mint_acc_bytes = b'\x01\x00\x00\x00\x1c\xe3Y\xedZ\x01.\x04\xfa\x14+\x9cu\x1a\x1c^\x87\xcf\xd0\xa0\x16\x1b\x9c\x85\xff\xd3\x1bx\xcd\xfc\xd8\xf6A*\xff\x1cA\xe3\x11\x00\x06\x01\x01\x00\x00\x00*\x9e^\xdb\xb5<\x04g\x90\x98\xff{\x12e\x17\x14CO\xc0\x8cV*\x9a;\x86\x11\x05\xe6r\xd4"s'
    parsed = Mint.from_bytes(mint_acc_bytes)
    expected = Mint(
        mint_authority=Pubkey.from_string(
            "2wmVCSfPxGPjrnMMn7rchp4uaeoTqN39mXFC2zhPdri9"
        ),
        supply=5034943402945089,
        decimals=6,
        is_initialized=True,
        freeze_authority=Pubkey.from_string(
            "3sNBr7kMccME5D55xNgsmYpZnzPgP2g12CixAajXypn6"
        ),
    )
    assert parsed == expected
