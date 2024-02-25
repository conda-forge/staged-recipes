from typing import Tuple

from pytest import raises
from solders.errors import SignerError
from solders.hash import Hash
from solders.instruction import AccountMeta, Instruction
from solders.keypair import Keypair
from solders.message import Message, MessageV0, to_bytes_versioned
from solders.null_signer import NullSigner
from solders.pubkey import Pubkey
from solders.system_program import (
    advance_nonce_account,
    transfer,
    withdraw_nonce_account,
)
from solders.transaction import (
    Legacy,
    Transaction,
    TransactionError,
    VersionedTransaction,
)


def test_try_new() -> None:
    keypair0 = Keypair()
    keypair1 = Keypair()
    keypair2 = Keypair()

    message = Message(
        [
            Instruction(
                Pubkey.new_unique(),
                b"",
                [
                    AccountMeta(keypair1.pubkey(), True, False),
                    AccountMeta(keypair2.pubkey(), False, False),
                ],
            )
        ],
        keypair0.pubkey(),
    )

    with raises(SignerError) as excinfo:
        VersionedTransaction(message, [keypair0])
    assert "not enough signers" in str(excinfo)
    with raises(SignerError) as excinfo:
        VersionedTransaction(message, [keypair0, keypair0])
    assert "keypair-pubkey mismatch" in str(excinfo)
    with raises(SignerError) as excinfo:
        VersionedTransaction(message, [keypair1, keypair2])
    assert "keypair-pubkey mismatch" in str(excinfo)

    tx = VersionedTransaction(message, [keypair0, keypair1])
    assert tx.verify_with_results() == [True, True]

    tx = VersionedTransaction(message, [keypair1, keypair0])
    assert tx.verify_with_results() == [True, True]


def nonced_transfer_tx() -> Tuple[Pubkey, Pubkey, VersionedTransaction]:
    from_keypair = Keypair()
    from_pubkey = from_keypair.pubkey()
    nonce_keypair = Keypair()
    nonce_pubkey = nonce_keypair.pubkey()
    instructions = [
        advance_nonce_account(
            {"nonce_pubkey": nonce_pubkey, "authorized_pubkey": nonce_pubkey}
        ),
        transfer(
            {"from_pubkey": from_pubkey, "to_pubkey": nonce_pubkey, "lamports": 42}
        ),
    ]
    message = Message(instructions, nonce_pubkey)
    tx = Transaction([from_keypair, nonce_keypair], message, Hash.default())
    return (from_pubkey, nonce_pubkey, VersionedTransaction.from_legacy(tx))


def test_tx_uses_nonce_ok() -> None:
    _, _, tx = nonced_transfer_tx()
    assert tx.uses_durable_nonce()


def test_tx_uses_nonce_empty_ix_fail() -> None:
    assert not VersionedTransaction.default().uses_durable_nonce()


def test_tx_uses_nonce_first_prog_id_not_nonce_fail() -> None:
    from_keypair = Keypair()
    from_pubkey = from_keypair.pubkey()
    nonce_keypair = Keypair()
    nonce_pubkey = nonce_keypair.pubkey()
    instructions = [
        transfer(
            {"from_pubkey": from_pubkey, "to_pubkey": nonce_pubkey, "lamports": 42}
        ),
        advance_nonce_account(
            {"nonce_pubkey": nonce_pubkey, "authorized_pubkey": nonce_pubkey}
        ),
    ]
    message = Message(instructions, from_pubkey)
    tx = Transaction([from_keypair, nonce_keypair], message, Hash.default())
    versioned = VersionedTransaction.from_legacy(tx)
    assert not versioned.uses_durable_nonce()


def test_tx_uses_nonce_wrong_first_nonce_ix_fail() -> None:
    from_keypair = Keypair()
    from_pubkey = from_keypair.pubkey()
    nonce_keypair = Keypair()
    nonce_pubkey = nonce_keypair.pubkey()
    instructions = [
        withdraw_nonce_account(
            {
                "nonce_pubkey": nonce_pubkey,
                "authorized_pubkey": nonce_pubkey,
                "to_pubkey": from_pubkey,
                "lamports": 42,
            }
        ),
        transfer(
            {"from_pubkey": from_pubkey, "to_pubkey": nonce_pubkey, "lamports": 42}
        ),
    ]
    message = Message(instructions, nonce_pubkey)
    tx = Transaction([from_keypair, nonce_keypair], message, Hash.default())
    versioned = VersionedTransaction.from_legacy(tx)
    assert not versioned.uses_durable_nonce()


def test_partial_signing() -> None:
    keypair0 = Keypair()
    keypair1 = Keypair()

    message = Message(
        [
            Instruction(
                Pubkey.new_unique(), b"", [AccountMeta(keypair1.pubkey(), True, False)]
            )
        ],
        keypair0.pubkey(),
    )
    signers = (keypair0, NullSigner(keypair1.pubkey()))
    partially_signed = VersionedTransaction(message, signers)
    serialized = bytes(partially_signed)
    deserialized = VersionedTransaction.from_bytes(serialized)
    assert deserialized == partially_signed
    deserialized_message = deserialized.message
    keypair1_sig_index = next(
        i
        for i, key in enumerate(deserialized_message.account_keys)
        if key == keypair1.pubkey()
    )
    sigs = deserialized.signatures
    sigs[keypair1_sig_index] = keypair1.sign_message(bytes(deserialized_message))
    deserialized.signatures = sigs
    fully_signed = VersionedTransaction(message, [keypair0, keypair1])
    assert deserialized.signatures == fully_signed.signatures
    assert deserialized == fully_signed
    assert bytes(deserialized) == bytes(fully_signed)


def test_partial_signing_messageV0() -> None:
    keypair0 = Keypair()
    keypair1 = Keypair()

    message = MessageV0.try_compile(
        keypair0.pubkey(),
        [
            Instruction(
                Pubkey.new_unique(), b"", [AccountMeta(keypair1.pubkey(), True, False)]
            )
        ],
        [],
        Hash.default(),
    )
    signers = (keypair0, NullSigner(keypair1.pubkey()))
    partially_signed = VersionedTransaction(message, signers)
    serialized = bytes(partially_signed)
    deserialized = VersionedTransaction.from_bytes(serialized)
    assert deserialized == partially_signed
    deserialized_message = deserialized.message
    keypair1_sig_index = next(
        i
        for i, key in enumerate(deserialized_message.account_keys)
        if key == keypair1.pubkey()
    )
    sigs = deserialized.signatures
    sigs[keypair1_sig_index] = keypair1.sign_message(
        to_bytes_versioned(deserialized_message)
    )
    deserialized.signatures = sigs
    fully_signed = VersionedTransaction(message, [keypair0, keypair1])
    assert deserialized.signatures == fully_signed.signatures
    assert deserialized == fully_signed
    assert bytes(deserialized) == bytes(fully_signed)


def test_legacy_version() -> None:
    assert Legacy.Legacy == Legacy.Legacy
    assert (
        Legacy.Legacy != 0
    )  # we don't want implicit int conversion because it clashes with versioned transaction versions
    assert isinstance(Legacy.Legacy, Legacy)


def test_message_missing_byte() -> None:
    # https://github.com/kevinheavey/solders/issues/43
    # randomly generated key
    private_key = Keypair.from_base58_string(
        "3KWC65p6AvMjvpR2r1qLTC4HVSH4jEFr5TMQxagMLo1o3j4yVYzKsfbB3jKtu3yGEHjx2Cc3L5t8wSo91vpjT63t"
    )
    public_key = private_key.pubkey()
    program_key = Pubkey.from_string("HQ2UUt18uJqKaQFJhgV9zaTdQxUZjNrsKFgoEDquBkcx")
    instruction = Instruction(program_key, bytes("123", "utf-8"), [])

    original_msg = MessageV0.try_compile(
        public_key,
        [instruction],
        [],
        Hash.from_string("4uQeVj5tqViQh7yWWGStvkEG1Zmhx6uasJtWCJziofM"),
    )

    signed_tx = VersionedTransaction(original_msg, [private_key])
    signed_tx.verify_and_hash_message()  # ok
    bad_bytes = bytes(original_msg)
    good_bytes = to_bytes_versioned(original_msg)
    bad_signature = private_key.sign_message(bad_bytes)
    good_signature = private_key.sign_message(good_bytes)
    signed_tx_populate_bad = VersionedTransaction.populate(
        original_msg, [bad_signature]
    )
    signed_tx_populate_good = VersionedTransaction.populate(
        original_msg, [good_signature]
    )
    with raises(TransactionError):
        signed_tx_populate_bad.verify_and_hash_message()
    signed_tx_populate_good.verify_and_hash_message()


def test_versioned_transaction_json() -> None:
    signer = Keypair()
    msg = MessageV0.try_compile(signer.pubkey(), [], [], Hash.default())
    tx = VersionedTransaction(msg, [signer])
    json = tx.to_json()
    parsed = VersionedTransaction.from_json(json)
    assert parsed == tx
