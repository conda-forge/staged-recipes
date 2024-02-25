from pathlib import Path

from pytest import mark
from solders.bankrun import start_anchor
from solders.pubkey import Pubkey


@mark.asyncio
async def test_anchor() -> None:
    ctx = await start_anchor(Path("tests/bankrun/anchor-example"))
    program_id = Pubkey.from_string("Fg6PaFpoGXkYsidMpWTK6W2BeZ7FEfcYkg476zPFsLnS")
    executable_account = await ctx.banks_client.get_account(program_id)
    assert executable_account is not None
    assert executable_account.executable
