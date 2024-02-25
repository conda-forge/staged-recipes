from pytest import mark
from solders.bankrun import start
from solders.instruction import AccountMeta, Instruction
from solders.message import Message
from solders.pubkey import Pubkey
from solders.transaction import VersionedTransaction


@mark.asyncio
async def test_logging() -> None:
    program_id = Pubkey.from_string("Logging111111111111111111111111111111111111")
    ix = Instruction(
        program_id,
        bytes([5, 10, 11, 12, 13, 14]),
        [AccountMeta(Pubkey.new_unique(), is_signer=False, is_writable=True)],
    )
    context = await start(programs=[("spl_example_logging", program_id)])
    payer = context.payer
    blockhash = context.last_blockhash
    client = context.banks_client
    msg = Message.new_with_blockhash([ix], payer.pubkey(), blockhash)
    tx = VersionedTransaction(msg, [payer])
    # let's sim it first
    sim_res = await client.simulate_transaction(tx)
    meta = await client.process_transaction(tx)
    assert sim_res.meta == meta
    assert meta is not None
    assert meta.log_messages[1] == "Program log: static string"
    assert (
        meta.compute_units_consumed < 10_000
    )  # not being precise here in case it changes
