from pytest import mark
from solders.account import Account
from solders.bankrun import start
from solders.pubkey import Pubkey
from solders.token import ID as TOKEN_PROGRAM_ID
from solders.token.associated import get_associated_token_address
from solders.token.state import TokenAccount, TokenAccountState


@mark.asyncio
async def test_infinite_usdc_mint() -> None:
    owner = Pubkey.new_unique()
    usdc_mint = Pubkey.from_string("EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v")
    ata = get_associated_token_address(owner, usdc_mint)
    usdc_to_own = 1_000_000_000_000
    token_acc = TokenAccount(
        mint=usdc_mint,
        owner=owner,
        amount=usdc_to_own,
        delegate=None,
        state=TokenAccountState.Initialized,
        is_native=None,
        delegated_amount=0,
        close_authority=None,
    )
    context = await start(
        accounts=[
            (
                ata,
                Account(
                    lamports=1_000_000_000,
                    data=bytes(token_acc),
                    owner=TOKEN_PROGRAM_ID,
                    executable=False,
                ),
            )
        ]
    )
    client = context.banks_client
    raw_account = await client.get_account(ata)
    assert raw_account is not None
    raw_account_data = raw_account.data
    assert TokenAccount.from_bytes(raw_account_data).amount == usdc_to_own
