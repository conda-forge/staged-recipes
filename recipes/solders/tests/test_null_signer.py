import pickle

from solders.keypair import Keypair
from solders.null_signer import NullSigner
from solders.signature import Signature


def test_null_signer() -> None:
    msg = b"hi"
    pubkey = Keypair().pubkey()
    ns = NullSigner(pubkey)
    assert ns.sign_message(msg) == Signature.default()
    assert NullSigner.from_bytes(bytes(ns)) == ns
    assert isinstance(hash(ns), int)


def test_pickle() -> None:
    obj = NullSigner.default()
    assert pickle.loads(pickle.dumps(obj)) == obj


def test_json() -> None:
    obj = NullSigner.default()
    assert NullSigner.from_json(obj.to_json()) == obj
