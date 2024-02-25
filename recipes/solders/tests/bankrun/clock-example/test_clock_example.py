from pytest import mark, raises
from solders.bankrun import start
from solders.clock import Clock
from solders.instruction import Instruction
from solders.message import Message
from solders.pubkey import Pubkey
from solders.transaction import TransactionError, VersionedTransaction


@mark.asyncio
async def test_set_clock() -> None:
    program_id = Pubkey.new_unique()
    context = await start(programs=[("solders_clock_example", program_id)])
    client = context.banks_client
    payer = context.payer
    blockhash = context.last_blockhash
    ixs = [Instruction(program_id=program_id, data=b"", accounts=[])]
    msg = Message.new_with_blockhash(ixs, payer.pubkey(), blockhash)
    tx = VersionedTransaction(msg, [payer])
    # this will fail because it's not January 1970 anymore
    with raises(TransactionError):
        await client.process_transaction(tx)
    # so let's turn back time
    current_clock = await client.get_clock()
    context.set_clock(
        Clock(
            slot=current_clock.slot,
            epoch_start_timestamp=current_clock.epoch_start_timestamp,
            epoch=current_clock.epoch,
            leader_schedule_epoch=current_clock.leader_schedule_epoch,
            unix_timestamp=50,
        )
    )
    ixs2 = [
        Instruction(
            program_id=program_id,
            data=b"foobar",  # unused, this is just to dedup the transaction
            accounts=[],
        )
    ]
    msg2 = Message.new_with_blockhash(ixs2, payer.pubkey(), blockhash)
    tx2 = VersionedTransaction(msg2, [payer])
    # now the transaction goes through
    await client.process_transaction(tx2)
