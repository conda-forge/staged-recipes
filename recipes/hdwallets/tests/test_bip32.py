import os

import base58
import pytest

from hdwallets import BIP32, HARDENED_INDEX, _utils


def test_vector_1():
    # fmt: off
    seed = bytes.fromhex("000102030405060708090a0b0c0d0e0f")
    bip32 = BIP32.from_seed(seed)
    # Chain m
    assert bip32.get_master_xpub() == base58.b58decode_check("xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8")
    assert bip32.get_master_xpriv() == base58.b58decode_check("xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi")
    # Chain m/0H
    assert (bip32.get_xpub_from_path([HARDENED_INDEX]) ==
            base58.b58decode_check("xpub68Gmy5EdvgibQVfPdqkBBCHxA5htiqg55crXYuXoQRKfDBFA1WEjWgP6LHhwBZeNK1VTsfTFUHCdrfp1bgwQ9xv5ski8PX9rL2dZXvgGDnw"))
    assert (bip32.get_xpriv_from_path([HARDENED_INDEX]) == base58.b58decode_check("xprv9uHRZZhk6KAJC1avXpDAp4MDc3sQKNxDiPvvkX8Br5ngLNv1TxvUxt4cV1rGL5hj6KCesnDYUhd7oWgT11eZG7XnxHrnYeSvkzY7d2bhkJ7"))
    assert (bip32.get_xpub_from_path("m/0H") == bip32.get_xpub_from_path([HARDENED_INDEX]))
    assert (bip32.get_xpriv_from_path("m/0H") == bip32.get_xpriv_from_path([HARDENED_INDEX]))
    # m/0H/1
    assert (bip32.get_xpub_from_path([HARDENED_INDEX, 1]) == base58.b58decode_check("xpub6ASuArnXKPbfEwhqN6e3mwBcDTgzisQN1wXN9BJcM47sSikHjJf3UFHKkNAWbWMiGj7Wf5uMash7SyYq527Hqck2AxYysAA7xmALppuCkwQ"))
    assert (bip32.get_xpriv_from_path([HARDENED_INDEX, 1]) == base58.b58decode_check("xprv9wTYmMFdV23N2TdNG573QoEsfRrWKQgWeibmLntzniatZvR9BmLnvSxqu53Kw1UmYPxLgboyZQaXwTCg8MSY3H2EU4pWcQDnRnrVA1xe8fs"))
    assert (bip32.get_xpub_from_path("m/0'/1") == bip32.get_xpub_from_path([HARDENED_INDEX, 1]))
    assert (bip32.get_xpriv_from_path("m/0'/1") == bip32.get_xpriv_from_path([HARDENED_INDEX, 1]))
    # m/0H/1/2H
    assert (bip32.get_xpub_from_path([HARDENED_INDEX, 1, HARDENED_INDEX + 2]) == base58.b58decode_check("xpub6D4BDPcP2GT577Vvch3R8wDkScZWzQzMMUm3PWbmWvVJrZwQY4VUNgqFJPMM3No2dFDFGTsxxpG5uJh7n7epu4trkrX7x7DogT5Uv6fcLW5"))
    assert (bip32.get_xpriv_from_path([HARDENED_INDEX, 1, HARDENED_INDEX + 2]) == base58.b58decode_check("xprv9z4pot5VBttmtdRTWfWQmoH1taj2axGVzFqSb8C9xaxKymcFzXBDptWmT7FwuEzG3ryjH4ktypQSAewRiNMjANTtpgP4mLTj34bhnZX7UiM"))
    assert (bip32.get_xpub_from_path("m/0h/1/2h") == bip32.get_xpub_from_path([HARDENED_INDEX, 1, HARDENED_INDEX + 2]))
    assert (bip32.get_xpriv_from_path("m/0h/1/2h") == bip32.get_xpriv_from_path([HARDENED_INDEX, 1, HARDENED_INDEX + 2]))
    # m/0H/1/2H/2
    assert (bip32.get_xpub_from_path([HARDENED_INDEX, 1, HARDENED_INDEX + 2, 2]) == base58.b58decode_check("xpub6FHa3pjLCk84BayeJxFW2SP4XRrFd1JYnxeLeU8EqN3vDfZmbqBqaGJAyiLjTAwm6ZLRQUMv1ZACTj37sR62cfN7fe5JnJ7dh8zL4fiyLHV"))
    assert (bip32.get_xpriv_from_path([HARDENED_INDEX, 1, HARDENED_INDEX + 2, 2]) == base58.b58decode_check("xprvA2JDeKCSNNZky6uBCviVfJSKyQ1mDYahRjijr5idH2WwLsEd4Hsb2Tyh8RfQMuPh7f7RtyzTtdrbdqqsunu5Mm3wDvUAKRHSC34sJ7in334"))
    assert (bip32.get_xpub_from_path("m/0'/1/2'/2") == base58.b58decode_check("xpub6FHa3pjLCk84BayeJxFW2SP4XRrFd1JYnxeLeU8EqN3vDfZmbqBqaGJAyiLjTAwm6ZLRQUMv1ZACTj37sR62cfN7fe5JnJ7dh8zL4fiyLHV"))
    assert (bip32.get_xpriv_from_path("m/0'/1/2'/2") == base58.b58decode_check("xprvA2JDeKCSNNZky6uBCviVfJSKyQ1mDYahRjijr5idH2WwLsEd4Hsb2Tyh8RfQMuPh7f7RtyzTtdrbdqqsunu5Mm3wDvUAKRHSC34sJ7in334"))
    # m/0H/1/2H/2/1000000000
    assert (bip32.get_xpub_from_path([HARDENED_INDEX, 1, HARDENED_INDEX + 2, 2, 1000000000]) == base58.b58decode_check("xpub6H1LXWLaKsWFhvm6RVpEL9P4KfRZSW7abD2ttkWP3SSQvnyA8FSVqNTEcYFgJS2UaFcxupHiYkro49S8yGasTvXEYBVPamhGW6cFJodrTHy"))
    assert (bip32.get_xpriv_from_path([HARDENED_INDEX, 1, HARDENED_INDEX + 2, 2, 1000000000]) == base58.b58decode_check("xprvA41z7zogVVwxVSgdKUHDy1SKmdb533PjDz7J6N6mV6uS3ze1ai8FHa8kmHScGpWmj4WggLyQjgPie1rFSruoUihUZREPSL39UNdE3BBDu76"))
    assert (bip32.get_xpub_from_path("m/0H/1/2H/2/1000000000") == bip32.get_xpub_from_path([HARDENED_INDEX, 1, HARDENED_INDEX + 2, 2, 1000000000]))
    assert (bip32.get_xpriv_from_path("m/0H/1/2H/2/1000000000") == bip32.get_xpriv_from_path([HARDENED_INDEX, 1, HARDENED_INDEX + 2, 2, 1000000000]))
    # fmt: on


def test_vector_2():
    # fmt: off
    seed = bytes.fromhex("fffcf9f6f3f0edeae7e4e1dedbd8d5d2cfccc9c6c3c0bdbab7b4b1aeaba8a5a29f9c999693908d8a8784817e7b7875726f6c696663605d5a5754514e4b484542")
    bip32 = BIP32.from_seed(seed)
    # Chain m
    assert (bip32.get_master_xpub() == base58.b58decode_check("xpub661MyMwAqRbcFW31YEwpkMuc5THy2PSt5bDMsktWQcFF8syAmRUapSCGu8ED9W6oDMSgv6Zz8idoc4a6mr8BDzTJY47LJhkJ8UB7WEGuduB"))
    assert (bip32.get_master_xpriv() == base58.b58decode_check("xprv9s21ZrQH143K31xYSDQpPDxsXRTUcvj2iNHm5NUtrGiGG5e2DtALGdso3pGz6ssrdK4PFmM8NSpSBHNqPqm55Qn3LqFtT2emdEXVYsCzC2U"))
    # Chain m/0
    assert (bip32.get_xpub_from_path([0]) == base58.b58decode_check("xpub69H7F5d8KSRgmmdJg2KhpAK8SR3DjMwAdkxj3ZuxV27CprR9LgpeyGmXUbC6wb7ERfvrnKZjXoUmmDznezpbZb7ap6r1D3tgFxHmwMkQTPH"))
    assert (bip32.get_xpriv_from_path([0]) == base58.b58decode_check("xprv9vHkqa6EV4sPZHYqZznhT2NPtPCjKuDKGY38FBWLvgaDx45zo9WQRUT3dKYnjwih2yJD9mkrocEZXo1ex8G81dwSM1fwqWpWkeS3v86pgKt"))
    assert (bip32.get_xpriv_from_path("m/0") == bip32.get_xpriv_from_path([0]))
    assert (bip32.get_xpub_from_path("m/0") == bip32.get_xpub_from_path([0]))
    # Chain m/0/2147483647H
    assert (bip32.get_xpub_from_path([0, HARDENED_INDEX + 2147483647]) == base58.b58decode_check("xpub6ASAVgeehLbnwdqV6UKMHVzgqAG8Gr6riv3Fxxpj8ksbH9ebxaEyBLZ85ySDhKiLDBrQSARLq1uNRts8RuJiHjaDMBU4Zn9h8LZNnBC5y4a"))
    assert (bip32.get_xpriv_from_path([0, HARDENED_INDEX + 2147483647]) == base58.b58decode_check("xprv9wSp6B7kry3Vj9m1zSnLvN3xH8RdsPP1Mh7fAaR7aRLcQMKTR2vidYEeEg2mUCTAwCd6vnxVrcjfy2kRgVsFawNzmjuHc2YmYRmagcEPdU9"))
    assert (bip32.get_xpub_from_path("m/0/2147483647H") == bip32.get_xpub_from_path([0, HARDENED_INDEX + 2147483647]))
    assert (bip32.get_xpriv_from_path("m/0/2147483647H") == bip32.get_xpriv_from_path([0, HARDENED_INDEX + 2147483647]))
    # Chain m/0/2147483647H/1
    assert (bip32.get_xpub_from_path([0, HARDENED_INDEX + 2147483647, 1]) == base58.b58decode_check("xpub6DF8uhdarytz3FWdA8TvFSvvAh8dP3283MY7p2V4SeE2wyWmG5mg5EwVvmdMVCQcoNJxGoWaU9DCWh89LojfZ537wTfunKau47EL2dhHKon"))
    assert (bip32.get_xpriv_from_path([0, HARDENED_INDEX + 2147483647, 1]) == base58.b58decode_check("xprv9zFnWC6h2cLgpmSA46vutJzBcfJ8yaJGg8cX1e5StJh45BBciYTRXSd25UEPVuesF9yog62tGAQtHjXajPPdbRCHuWS6T8XA2ECKADdw4Ef"))
    assert (bip32.get_xpub_from_path("m/0/2147483647H/1") == bip32.get_xpub_from_path([0, HARDENED_INDEX + 2147483647, 1]))
    assert (bip32.get_xpriv_from_path("m/0/2147483647H/1") == bip32.get_xpriv_from_path([0, HARDENED_INDEX + 2147483647, 1]))
    # Chain m/0/2147483647H/1/2147483646H
    assert (bip32.get_xpub_from_path([0, HARDENED_INDEX + 2147483647, 1, HARDENED_INDEX + 2147483646]) == base58.b58decode_check("xpub6ERApfZwUNrhLCkDtcHTcxd75RbzS1ed54G1LkBUHQVHQKqhMkhgbmJbZRkrgZw4koxb5JaHWkY4ALHY2grBGRjaDMzQLcgJvLJuZZvRcEL"))
    assert (bip32.get_xpriv_from_path([0, HARDENED_INDEX + 2147483647, 1, HARDENED_INDEX + 2147483646]) == base58.b58decode_check("xprvA1RpRA33e1JQ7ifknakTFpgNXPmW2YvmhqLQYMmrj4xJXXWYpDPS3xz7iAxn8L39njGVyuoseXzU6rcxFLJ8HFsTjSyQbLYnMpCqE2VbFWc"))
    assert (bip32.get_xpub_from_path("m/0/2147483647H/1/2147483646H") == bip32.get_xpub_from_path([0, HARDENED_INDEX + 2147483647, 1, HARDENED_INDEX + 2147483646]))
    assert (bip32.get_xpriv_from_path("m/0/2147483647H/1/2147483646H") == bip32.get_xpriv_from_path([0, HARDENED_INDEX + 2147483647, 1, HARDENED_INDEX + 2147483646]))
    # Chain m/0/2147483647H/1/2147483646H/2
    assert (bip32.get_xpub_from_path([0, HARDENED_INDEX + 2147483647, 1, HARDENED_INDEX + 2147483646, 2]) == base58.b58decode_check("xpub6FnCn6nSzZAw5Tw7cgR9bi15UV96gLZhjDstkXXxvCLsUXBGXPdSnLFbdpq8p9HmGsApME5hQTZ3emM2rnY5agb9rXpVGyy3bdW6EEgAtqt"))
    assert (bip32.get_xpriv_from_path([0, HARDENED_INDEX + 2147483647, 1, HARDENED_INDEX + 2147483646, 2]) == base58.b58decode_check("xprvA2nrNbFZABcdryreWet9Ea4LvTJcGsqrMzxHx98MMrotbir7yrKCEXw7nadnHM8Dq38EGfSh6dqA9QWTyefMLEcBYJUuekgW4BYPJcr9E7j"))
    assert (bip32.get_xpub_from_path("m/0/2147483647H/1/2147483646H/2") == bip32.get_xpub_from_path([0, HARDENED_INDEX + 2147483647, 1, HARDENED_INDEX + 2147483646, 2]))
    assert (bip32.get_xpriv_from_path("m/0/2147483647H/1/2147483646H/2") == bip32.get_xpriv_from_path([0, HARDENED_INDEX + 2147483647, 1, HARDENED_INDEX + 2147483646, 2]))
    # fmt: on


def test_vector_3():
    # fmt: off
    seed = bytes.fromhex("4b381541583be4423346c643850da4b320e46a87ae3d2a4e6da11eba819cd4acba45d239319ac14f863b8d5ab5a0d0c64d2e8a1e7d1457df2e5a3c51c73235be")
    bip32 = BIP32.from_seed(seed)
    # Chain m
    assert (bip32.get_xpub_from_path([]) == base58.b58decode_check("xpub661MyMwAqRbcEZVB4dScxMAdx6d4nFc9nvyvH3v4gJL378CSRZiYmhRoP7mBy6gSPSCYk6SzXPTf3ND1cZAceL7SfJ1Z3GC8vBgp2epUt13"))
    assert (bip32.get_xpriv_from_path([]) == base58.b58decode_check("xprv9s21ZrQH143K25QhxbucbDDuQ4naNntJRi4KUfWT7xo4EKsHt2QJDu7KXp1A3u7Bi1j8ph3EGsZ9Xvz9dGuVrtHHs7pXeTzjuxBrCmmhgC6"))
    assert (bip32.get_xpub_from_path("m") == bip32.get_xpub_from_path([]))
    assert (bip32.get_xpriv_from_path("m") == bip32.get_xpriv_from_path([]))
    # Chain m/0H
    assert (bip32.get_xpub_from_path([HARDENED_INDEX]) == base58.b58decode_check("xpub68NZiKmJWnxxS6aaHmn81bvJeTESw724CRDs6HbuccFQN9Ku14VQrADWgqbhhTHBaohPX4CjNLf9fq9MYo6oDaPPLPxSb7gwQN3ih19Zm4Y"))
    assert (bip32.get_xpriv_from_path([HARDENED_INDEX]) == base58.b58decode_check("xprv9uPDJpEQgRQfDcW7BkF7eTya6RPxXeJCqCJGHuCJ4GiRVLzkTXBAJMu2qaMWPrS7AANYqdq6vcBcBUdJCVVFceUvJFjaPdGZ2y9WACViL4L"))
    assert (bip32.get_xpub_from_path("m/0H") == bip32.get_xpub_from_path([HARDENED_INDEX]))
    assert (bip32.get_xpriv_from_path("m/0H") == bip32.get_xpriv_from_path([HARDENED_INDEX]))
    # fmt: on


def test_sanity_checks():
    # fmt: off
    seed = bytes.fromhex("1077a46dc8545d372f22d9e110ae6c5c2bf7620fe9c4c911f5404d112233e1aa270567dd3554092e051ba3ba86c303590b0309116ac89964ff284db2219d7511")
    first_bip32 = BIP32.from_seed(seed)
    sec_bip32 = BIP32.from_xpriv(base58.b58decode_check("xprv9s21ZrQH143K3o4KUs47P2x9afhH31ekMo2foNTYwrU9wwZ8g5EatR9bn6YmCacdvnHWMnPFUqieQrnunrzuF5UfgGbhbEW43zRnhpPDBUL"))
    assert first_bip32.get_master_xpriv() == sec_bip32.get_master_xpriv()
    assert first_bip32.get_master_xpub() == sec_bip32.get_master_xpub()
    # Fuzz it a bit
    for i in range(50):
        path = [int.from_bytes(os.urandom(3), "big") for _ in range(5)]
        h_path = [HARDENED_INDEX + int.from_bytes(os.urandom(3), "big") for _ in range(5)]
        mixed_path = [int.from_bytes(os.urandom(3), "big") for _ in range(5)]
        for i in mixed_path:
            if int.from_bytes(os.urandom(32), "big") % 2:
                i += HARDENED_INDEX
        assert first_bip32.get_xpriv_from_path(path) == sec_bip32.get_xpriv_from_path(path)
        assert first_bip32.get_xpub_from_path(path) == sec_bip32.get_xpub_from_path(path)
        assert first_bip32.get_xpriv_from_path(h_path) == sec_bip32.get_xpriv_from_path(h_path)
        assert first_bip32.get_xpub_from_path(h_path) == sec_bip32.get_xpub_from_path(h_path)
        assert first_bip32.get_xpriv_from_path(mixed_path) == sec_bip32.get_xpriv_from_path(mixed_path)
        assert first_bip32.get_xpub_from_path(mixed_path) == sec_bip32.get_xpub_from_path(mixed_path)
    # Taken from iancoleman's website
    bip32 = BIP32.from_seed(bytes.fromhex("ac8c2377e5cde867d7e420fbe04d8906309b70d51b8fe58d6844930621a9bc223929155dcfebb4da9d62c86ec0d15adf936a663f4f0cf39cbb0352e7dac073d6"))
    assert bip32.get_master_xpriv() == bip32.get_xpriv_from_path([]) == base58.b58decode_check("xprv9s21ZrQH143K2GzaKJsW7DQsxeDpY3zqgusaSx6owWGC19k4mhwnVAsm4qPsCw43NkY2h1BzVLyxWHt9NKF86QRyBj53vModdGcNxtpD6KX")
    assert bip32.get_master_xpub() == bip32.get_xpub_from_path([]) == base58.b58decode_check("xpub661MyMwAqRbcEm53RLQWUMMcWg4JwWih48oBFLWRVqoAsx5DKFG32yCEv8iH29TWpmo5KTcpsjXcea6Zx4Hc6PAbGnHjEDCf3yHbj7qdpnf")
    # Sanity checks for m/0'/0'/14/0'/18
    xpriv = bip32.get_xpriv_from_path([HARDENED_INDEX, HARDENED_INDEX, 14,
                                       HARDENED_INDEX, 18])
    xpub = bip32.get_xpub_from_path([HARDENED_INDEX, HARDENED_INDEX, 14,
                                     HARDENED_INDEX, 18])
    assert xpriv == base58.b58decode_check("xprvA2YVbLvEeKaPedw7F6RLwG3RgYnTq1xGCyDNMgZNWdEQnSUBQmKEuLyA6TSPsggt5xvyJHLD9L25tNLpQiP4Q8ZkQNo8ueAgeYj5zYq8hSm")
    assert xpub == base58.b58decode_check("xpub6FXqzrT8Uh8gs81aM7xMJPzAEacxEUg7aC8yA4xz4xmPfEoKxJdVT9Hdwm3LwVQrSos2rhGDt8aGGHvdLr5LLAjK8pXFkbSpzGoGTXjd4z9")
    # Now if we our master is m/0'/0'/14, we should derive the same keys for
    # m/0'/18 !
    xpriv2 = bip32.get_xpriv_from_path([HARDENED_INDEX, HARDENED_INDEX, 14])
    assert xpriv2 == base58.b58decode_check("xprv9yQJmvQMywM5i7UNuZ4RQ1A9rEMwAJCExPardkmBCB46S3vBqNEatSwLUrwLNLHBu1Kd9aGxGKDD5YAfs6hRzpYthciAHjtGadxgV2PeqY9")
    bip32 = BIP32.from_xpriv(xpriv2)
    assert bip32.get_master_xpriv() == xpriv2
    assert bip32.get_xpriv_from_path([HARDENED_INDEX, 18]) == xpriv
    assert bip32.get_xpub_from_path([HARDENED_INDEX, 18]) == xpub
    # We should recognize the networks..
    # .. for xprivs:
    bip32 = BIP32.from_xpriv(base58.b58decode_check("xprv9wHokC2KXdTSpEepFcu53hMDUHYfAtTaLEJEMyxBPAMf78hJg17WhL5FyeDUQH5KWmGjGgEb2j74gsZqgupWpPbZgP6uFmP8MYEy5BNbyET"))
    assert bip32.network == "main"
    bip32 = BIP32.from_xpriv(base58.b58decode_check("tprv8ZgxMBicQKsPeCBsMzQCCb5JcW4S49MVL3EwhdZMF1RF71rgisZU4ZRvrHX6PZQEiNUABDLvYqpx8Lsccq8aGGR59qHAoLoE3iXYuDa8JTP"))
    assert bip32.network == "test"
    # .. for xpubs:
    bip32 = BIP32.from_xpub(base58.b58decode_check("xpub6AHA9hZDN11k2ijHMeS5QqHx2KP9aMBRhTDqANMnwVtdyw2TDYRmF8PjpvwUFcL1Et8Hj59S3gTSMcUQ5gAqTz3Wd8EsMTmF3DChhqPQBnU"))
    assert bip32.network == "main"
    bip32 = BIP32.from_xpub(base58.b58decode_check("tpubD6NzVbkrYhZ4WN3WiKRjeo2eGyYNiKNg8vcQ1UjLNJJaDvoFhmR1XwJsbo5S4vicSPoWQBThR3Rt8grXtP47c1AnoiXMrEmFdRZupxJzH1j"))
    assert bip32.network == "test"
    # We should create valid network encoding..
    assert BIP32.from_seed(os.urandom(32),
                           "test").get_master_xpub().startswith(b"\x04\x35\x87\xCF")
    assert BIP32.from_seed(os.urandom(32),
                           "test").get_master_xpriv().startswith(b"\x04\x35\x83\x94")
    assert BIP32.from_seed(os.urandom(32),
                           "main").get_master_xpub().startswith(b"\x04\x88\xB2\x1E")
    assert BIP32.from_seed(os.urandom(32),
                           "main").get_master_xpriv().startswith(b"\x04\x88\xAD\xE4")

    # We can get the keys from "m" or []
    bip32 = BIP32.from_seed(os.urandom(32))
    assert (bip32.get_master_xpub() == bip32.get_xpub_from_path("m") ==
            bip32.get_xpub_from_path([]))
    assert (bip32.get_master_xpriv() == bip32.get_xpriv_from_path("m") ==
            bip32.get_xpriv_from_path([]))
    master_non_extended_pubkey = bip32.get_privkey_from_path("m")
    pubkey = _utils._privkey_to_pubkey(master_non_extended_pubkey)
    assert pubkey == bip32.get_pubkey_from_path("m")
    # But getting from "m'" does not make sense
    with pytest.raises(ValueError, match="invalid format"):
        bip32.get_pubkey_from_path("m'")
    # fmt: on
