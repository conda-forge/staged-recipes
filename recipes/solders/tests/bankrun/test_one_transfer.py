from pytest import mark
from solders.bankrun import start
from solders.message import Message
from solders.pubkey import Pubkey
from solders.system_program import transfer
from solders.transaction import VersionedTransaction


@mark.asyncio
async def test_transfer() -> None:
    context = await start()
    receiver = Pubkey.new_unique()
    client = context.banks_client
    payer = context.payer
    blockhash = context.last_blockhash
    transfer_lamports = 1_000_000
    ixs = [
        transfer(
            {
                "from_pubkey": context.payer.pubkey(),
                "to_pubkey": receiver,
                "lamports": transfer_lamports,
            }
        )
    ]
    msg = Message.new_with_blockhash(ixs, payer.pubkey(), blockhash)
    tx = VersionedTransaction(msg, [payer])
    await client.process_transaction(tx)
    balance_after = await client.get_balance(receiver)
    assert balance_after == transfer_lamports
