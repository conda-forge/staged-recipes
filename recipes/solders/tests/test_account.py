import pickle

from pytest import fixture
from solders.account import Account
from solders.pubkey import Pubkey


@fixture
def account() -> Account:
    return Account(1, b"123", Pubkey.default(), True, 1)


def test_bytes(account: Account) -> None:
    assert Account.from_bytes(bytes(account))


def test_pickle(account: Account) -> None:
    assert pickle.loads(pickle.dumps(account)) == account


def test_json(account: Account) -> None:
    assert Account.from_json(account.to_json()) == account


def test_account_from_json() -> None:
    # https://github.com/kevinheavey/solders/issues/69
    raw = """{
    "lamports": 16258560,
    "data": "error: data too large for bs58 encoding",
    "owner": "675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8",
    "executable": false,
    "rentEpoch": 0,
    "space": 2208
}
    """
    parsed = Account.from_json(raw)
    assert parsed.rent_epoch == 0
    assert parsed.data == b"error: data too large for bs58 encoding"
