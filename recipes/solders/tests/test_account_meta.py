import pickle

from solders.instruction import AccountMeta
from solders.pubkey import Pubkey

PUBKEY = Pubkey.default()


def test_eq() -> None:
    am1 = AccountMeta(PUBKEY, True, True)
    am2 = AccountMeta(PUBKEY, True, True)
    am3 = AccountMeta(PUBKEY, True, False)
    assert am1 == am2
    assert am1 != am3


def test_attributes() -> None:
    am = AccountMeta(PUBKEY, True, True)
    assert am.pubkey == PUBKEY
    assert am.is_signer
    assert am.is_writable


def test_pickle() -> None:
    obj = AccountMeta(PUBKEY, True, True)
    assert pickle.loads(pickle.dumps(obj)) == obj


def test_json() -> None:
    obj = AccountMeta(PUBKEY, True, True)
    assert AccountMeta.from_json(obj.to_json()) == obj
