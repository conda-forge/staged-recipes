import coincurve
import os
import pytest

from bip32 import BIP32, HARDENED_INDEX, PrivateDerivationError, InvalidInputError


def test_vector_1():
    seed = bytes.fromhex("000102030405060708090a0b0c0d0e0f")
    bip32 = BIP32.from_seed(seed)
    # Chain m
    assert (
        bip32.get_xpub()
        == "xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8"
    )
    assert bip32.get_xpub_bytes() == bytes.fromhex(
        "0488b21e000000000000000000873dff81c02f525623fd1fe5167eac3a55a049de3d314bb42ee227ffed37d5080339a36013301597daef41fbe593a02cc513d0b55527ec2df1050e2e8ff49c85c2"
    )
    assert (
        bip32.get_xpriv()
        == "xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi"
    )
    assert bip32.get_xpriv_bytes() == bytes.fromhex(
        "0488ade4000000000000000000873dff81c02f525623fd1fe5167eac3a55a049de3d314bb42ee227ffed37d50800e8f32e723decf4051aefac8e2c93c9c5b214313817cdb01a1494b917c8436b35"
    )
    # Chain m/0H
    assert (
        bip32.get_xpub_from_path([HARDENED_INDEX])
        == "xpub68Gmy5EdvgibQVfPdqkBBCHxA5htiqg55crXYuXoQRKfDBFA1WEjWgP6LHhwBZeNK1VTsfTFUHCdrfp1bgwQ9xv5ski8PX9rL2dZXvgGDnw"
    )
    assert (
        bip32.get_xpriv_from_path([HARDENED_INDEX])
        == "xprv9uHRZZhk6KAJC1avXpDAp4MDc3sQKNxDiPvvkX8Br5ngLNv1TxvUxt4cV1rGL5hj6KCesnDYUhd7oWgT11eZG7XnxHrnYeSvkzY7d2bhkJ7"
    )
    assert bip32.get_xpub_from_path("m/0H") == bip32.get_xpub_from_path(
        [HARDENED_INDEX]
    )
    assert bip32.get_xpriv_from_path("m/0H") == bip32.get_xpriv_from_path(
        [HARDENED_INDEX]
    )
    # m/0H/1
    assert (
        bip32.get_xpub_from_path([HARDENED_INDEX, 1])
        == "xpub6ASuArnXKPbfEwhqN6e3mwBcDTgzisQN1wXN9BJcM47sSikHjJf3UFHKkNAWbWMiGj7Wf5uMash7SyYq527Hqck2AxYysAA7xmALppuCkwQ"
    )
    assert (
        bip32.get_xpriv_from_path([HARDENED_INDEX, 1])
        == "xprv9wTYmMFdV23N2TdNG573QoEsfRrWKQgWeibmLntzniatZvR9BmLnvSxqu53Kw1UmYPxLgboyZQaXwTCg8MSY3H2EU4pWcQDnRnrVA1xe8fs"
    )
    assert bip32.get_xpub_from_path("m/0'/1") == bip32.get_xpub_from_path(
        [HARDENED_INDEX, 1]
    )
    assert bip32.get_xpriv_from_path("m/0'/1") == bip32.get_xpriv_from_path(
        [HARDENED_INDEX, 1]
    )
    # m/0H/1/2H
    assert (
        bip32.get_xpub_from_path([HARDENED_INDEX, 1, HARDENED_INDEX + 2])
        == "xpub6D4BDPcP2GT577Vvch3R8wDkScZWzQzMMUm3PWbmWvVJrZwQY4VUNgqFJPMM3No2dFDFGTsxxpG5uJh7n7epu4trkrX7x7DogT5Uv6fcLW5"
    )
    assert (
        bip32.get_xpriv_from_path([HARDENED_INDEX, 1, HARDENED_INDEX + 2])
        == "xprv9z4pot5VBttmtdRTWfWQmoH1taj2axGVzFqSb8C9xaxKymcFzXBDptWmT7FwuEzG3ryjH4ktypQSAewRiNMjANTtpgP4mLTj34bhnZX7UiM"
    )
    assert bip32.get_xpub_from_path("m/0h/1/2h") == bip32.get_xpub_from_path(
        [HARDENED_INDEX, 1, HARDENED_INDEX + 2]
    )
    assert bip32.get_xpriv_from_path("m/0h/1/2h") == bip32.get_xpriv_from_path(
        [HARDENED_INDEX, 1, HARDENED_INDEX + 2]
    )
    # m/0H/1/2H/2
    assert (
        bip32.get_xpub_from_path([HARDENED_INDEX, 1, HARDENED_INDEX + 2, 2])
        == "xpub6FHa3pjLCk84BayeJxFW2SP4XRrFd1JYnxeLeU8EqN3vDfZmbqBqaGJAyiLjTAwm6ZLRQUMv1ZACTj37sR62cfN7fe5JnJ7dh8zL4fiyLHV"
    )
    assert (
        bip32.get_xpriv_from_path([HARDENED_INDEX, 1, HARDENED_INDEX + 2, 2])
        == "xprvA2JDeKCSNNZky6uBCviVfJSKyQ1mDYahRjijr5idH2WwLsEd4Hsb2Tyh8RfQMuPh7f7RtyzTtdrbdqqsunu5Mm3wDvUAKRHSC34sJ7in334"
    )
    assert (
        bip32.get_xpub_from_path("m/0'/1/2'/2")
        == "xpub6FHa3pjLCk84BayeJxFW2SP4XRrFd1JYnxeLeU8EqN3vDfZmbqBqaGJAyiLjTAwm6ZLRQUMv1ZACTj37sR62cfN7fe5JnJ7dh8zL4fiyLHV"
    )
    assert (
        bip32.get_xpriv_from_path("m/0'/1/2'/2")
        == "xprvA2JDeKCSNNZky6uBCviVfJSKyQ1mDYahRjijr5idH2WwLsEd4Hsb2Tyh8RfQMuPh7f7RtyzTtdrbdqqsunu5Mm3wDvUAKRHSC34sJ7in334"
    )
    # m/0H/1/2H/2/1000000000
    assert (
        bip32.get_xpub_from_path([HARDENED_INDEX, 1, HARDENED_INDEX + 2, 2, 1000000000])
        == "xpub6H1LXWLaKsWFhvm6RVpEL9P4KfRZSW7abD2ttkWP3SSQvnyA8FSVqNTEcYFgJS2UaFcxupHiYkro49S8yGasTvXEYBVPamhGW6cFJodrTHy"
    )
    assert (
        bip32.get_xpriv_from_path(
            [HARDENED_INDEX, 1, HARDENED_INDEX + 2, 2, 1000000000]
        )
        == "xprvA41z7zogVVwxVSgdKUHDy1SKmdb533PjDz7J6N6mV6uS3ze1ai8FHa8kmHScGpWmj4WggLyQjgPie1rFSruoUihUZREPSL39UNdE3BBDu76"
    )
    assert bip32.get_xpub_from_path(
        "m/0H/1/2H/2/1000000000"
    ) == bip32.get_xpub_from_path(
        [HARDENED_INDEX, 1, HARDENED_INDEX + 2, 2, 1000000000]
    )
    assert bip32.get_xpriv_from_path(
        "m/0H/1/2H/2/1000000000"
    ) == bip32.get_xpriv_from_path(
        [HARDENED_INDEX, 1, HARDENED_INDEX + 2, 2, 1000000000]
    )


def test_vector_2():
    seed = bytes.fromhex(
        "fffcf9f6f3f0edeae7e4e1dedbd8d5d2cfccc9c6c3c0bdbab7b4b1aeaba8a5a29f9c999693908d8a8784817e7b7875726f6c696663605d5a5754514e4b484542"
    )
    bip32 = BIP32.from_seed(seed)
    # Chain m
    assert (
        bip32.get_xpub()
        == "xpub661MyMwAqRbcFW31YEwpkMuc5THy2PSt5bDMsktWQcFF8syAmRUapSCGu8ED9W6oDMSgv6Zz8idoc4a6mr8BDzTJY47LJhkJ8UB7WEGuduB"
    )
    assert bip32.get_xpub_bytes() == bytes.fromhex(
        "0488b21e00000000000000000060499f801b896d83179a4374aeb7822aaeaceaa0db1f85ee3e904c4defbd968903cbcaa9c98c877a26977d00825c956a238e8dddfbd322cce4f74b0b5bd6ace4a7"
    )
    assert (
        bip32.get_xpriv()
        == "xprv9s21ZrQH143K31xYSDQpPDxsXRTUcvj2iNHm5NUtrGiGG5e2DtALGdso3pGz6ssrdK4PFmM8NSpSBHNqPqm55Qn3LqFtT2emdEXVYsCzC2U"
    )
    assert bip32.get_xpriv_bytes() == bytes.fromhex(
        "0488ade400000000000000000060499f801b896d83179a4374aeb7822aaeaceaa0db1f85ee3e904c4defbd9689004b03d6fc340455b363f51020ad3ecca4f0850280cf436c70c727923f6db46c3e"
    )
    # Chain m/0
    assert (
        bip32.get_xpub_from_path([0])
        == "xpub69H7F5d8KSRgmmdJg2KhpAK8SR3DjMwAdkxj3ZuxV27CprR9LgpeyGmXUbC6wb7ERfvrnKZjXoUmmDznezpbZb7ap6r1D3tgFxHmwMkQTPH"
    )
    assert (
        bip32.get_xpriv_from_path([0])
        == "xprv9vHkqa6EV4sPZHYqZznhT2NPtPCjKuDKGY38FBWLvgaDx45zo9WQRUT3dKYnjwih2yJD9mkrocEZXo1ex8G81dwSM1fwqWpWkeS3v86pgKt"
    )
    assert bip32.get_xpriv_from_path("m/0") == bip32.get_xpriv_from_path([0])
    assert bip32.get_xpub_from_path("m/0") == bip32.get_xpub_from_path([0])
    # Chain m/0/2147483647H
    assert (
        bip32.get_xpub_from_path([0, HARDENED_INDEX + 2147483647])
        == "xpub6ASAVgeehLbnwdqV6UKMHVzgqAG8Gr6riv3Fxxpj8ksbH9ebxaEyBLZ85ySDhKiLDBrQSARLq1uNRts8RuJiHjaDMBU4Zn9h8LZNnBC5y4a"
    )
    assert (
        bip32.get_xpriv_from_path([0, HARDENED_INDEX + 2147483647])
        == "xprv9wSp6B7kry3Vj9m1zSnLvN3xH8RdsPP1Mh7fAaR7aRLcQMKTR2vidYEeEg2mUCTAwCd6vnxVrcjfy2kRgVsFawNzmjuHc2YmYRmagcEPdU9"
    )
    assert bip32.get_xpub_from_path("m/0/2147483647H") == bip32.get_xpub_from_path(
        [0, HARDENED_INDEX + 2147483647]
    )
    assert bip32.get_xpriv_from_path("m/0/2147483647H") == bip32.get_xpriv_from_path(
        [0, HARDENED_INDEX + 2147483647]
    )
    # Chain m/0/2147483647H/1
    assert (
        bip32.get_xpub_from_path([0, HARDENED_INDEX + 2147483647, 1])
        == "xpub6DF8uhdarytz3FWdA8TvFSvvAh8dP3283MY7p2V4SeE2wyWmG5mg5EwVvmdMVCQcoNJxGoWaU9DCWh89LojfZ537wTfunKau47EL2dhHKon"
    )
    assert (
        bip32.get_xpriv_from_path([0, HARDENED_INDEX + 2147483647, 1])
        == "xprv9zFnWC6h2cLgpmSA46vutJzBcfJ8yaJGg8cX1e5StJh45BBciYTRXSd25UEPVuesF9yog62tGAQtHjXajPPdbRCHuWS6T8XA2ECKADdw4Ef"
    )
    assert bip32.get_xpub_from_path("m/0/2147483647H/1") == bip32.get_xpub_from_path(
        [0, HARDENED_INDEX + 2147483647, 1]
    )
    assert bip32.get_xpriv_from_path("m/0/2147483647H/1") == bip32.get_xpriv_from_path(
        [0, HARDENED_INDEX + 2147483647, 1]
    )
    # Chain m/0/2147483647H/1/2147483646H
    assert (
        bip32.get_xpub_from_path(
            [0, HARDENED_INDEX + 2147483647, 1, HARDENED_INDEX + 2147483646]
        )
        == "xpub6ERApfZwUNrhLCkDtcHTcxd75RbzS1ed54G1LkBUHQVHQKqhMkhgbmJbZRkrgZw4koxb5JaHWkY4ALHY2grBGRjaDMzQLcgJvLJuZZvRcEL"
    )
    assert (
        bip32.get_xpriv_from_path(
            [0, HARDENED_INDEX + 2147483647, 1, HARDENED_INDEX + 2147483646]
        )
        == "xprvA1RpRA33e1JQ7ifknakTFpgNXPmW2YvmhqLQYMmrj4xJXXWYpDPS3xz7iAxn8L39njGVyuoseXzU6rcxFLJ8HFsTjSyQbLYnMpCqE2VbFWc"
    )
    assert bip32.get_xpub_from_path(
        "m/0/2147483647H/1/2147483646H"
    ) == bip32.get_xpub_from_path(
        [0, HARDENED_INDEX + 2147483647, 1, HARDENED_INDEX + 2147483646]
    )
    assert bip32.get_xpriv_from_path(
        "m/0/2147483647H/1/2147483646H"
    ) == bip32.get_xpriv_from_path(
        [0, HARDENED_INDEX + 2147483647, 1, HARDENED_INDEX + 2147483646]
    )
    # Chain m/0/2147483647H/1/2147483646H/2
    assert (
        bip32.get_xpub_from_path(
            [0, HARDENED_INDEX + 2147483647, 1, HARDENED_INDEX + 2147483646, 2]
        )
        == "xpub6FnCn6nSzZAw5Tw7cgR9bi15UV96gLZhjDstkXXxvCLsUXBGXPdSnLFbdpq8p9HmGsApME5hQTZ3emM2rnY5agb9rXpVGyy3bdW6EEgAtqt"
    )
    assert (
        bip32.get_xpriv_from_path(
            [0, HARDENED_INDEX + 2147483647, 1, HARDENED_INDEX + 2147483646, 2]
        )
        == "xprvA2nrNbFZABcdryreWet9Ea4LvTJcGsqrMzxHx98MMrotbir7yrKCEXw7nadnHM8Dq38EGfSh6dqA9QWTyefMLEcBYJUuekgW4BYPJcr9E7j"
    )
    assert bip32.get_xpub_from_path(
        "m/0/2147483647H/1/2147483646H/2"
    ) == bip32.get_xpub_from_path(
        [0, HARDENED_INDEX + 2147483647, 1, HARDENED_INDEX + 2147483646, 2]
    )
    assert bip32.get_xpriv_from_path(
        "m/0/2147483647H/1/2147483646H/2"
    ) == bip32.get_xpriv_from_path(
        [0, HARDENED_INDEX + 2147483647, 1, HARDENED_INDEX + 2147483646, 2]
    )


def test_vector_3():
    seed = bytes.fromhex(
        "4b381541583be4423346c643850da4b320e46a87ae3d2a4e6da11eba819cd4acba45d239319ac14f863b8d5ab5a0d0c64d2e8a1e7d1457df2e5a3c51c73235be"
    )
    bip32 = BIP32.from_seed(seed)
    # Chain m
    assert (
        bip32.get_xpub_from_path([])
        == "xpub661MyMwAqRbcEZVB4dScxMAdx6d4nFc9nvyvH3v4gJL378CSRZiYmhRoP7mBy6gSPSCYk6SzXPTf3ND1cZAceL7SfJ1Z3GC8vBgp2epUt13"
    )
    assert (
        bip32.get_xpriv_from_path([])
        == "xprv9s21ZrQH143K25QhxbucbDDuQ4naNntJRi4KUfWT7xo4EKsHt2QJDu7KXp1A3u7Bi1j8ph3EGsZ9Xvz9dGuVrtHHs7pXeTzjuxBrCmmhgC6"
    )
    assert bip32.get_xpub_from_path("m") == bip32.get_xpub_from_path([])
    assert bip32.get_xpriv_from_path("m") == bip32.get_xpriv_from_path([])
    # Chain m/0H
    assert (
        bip32.get_xpub_from_path([HARDENED_INDEX])
        == "xpub68NZiKmJWnxxS6aaHmn81bvJeTESw724CRDs6HbuccFQN9Ku14VQrADWgqbhhTHBaohPX4CjNLf9fq9MYo6oDaPPLPxSb7gwQN3ih19Zm4Y"
    )
    assert (
        bip32.get_xpriv_from_path([HARDENED_INDEX])
        == "xprv9uPDJpEQgRQfDcW7BkF7eTya6RPxXeJCqCJGHuCJ4GiRVLzkTXBAJMu2qaMWPrS7AANYqdq6vcBcBUdJCVVFceUvJFjaPdGZ2y9WACViL4L"
    )
    assert bip32.get_xpub_from_path("m/0H") == bip32.get_xpub_from_path(
        [HARDENED_INDEX]
    )
    assert bip32.get_xpriv_from_path("m/0H") == bip32.get_xpriv_from_path(
        [HARDENED_INDEX]
    )


def test_vector_4():
    seed = bytes.fromhex(
        "3ddd5602285899a946114506157c7997e5444528f3003f6134712147db19b678"
    )
    bip32 = BIP32.from_seed(seed)
    # Chain m
    assert (
        bip32.get_xpub_from_path("m")
        == "xpub661MyMwAqRbcGczjuMoRm6dXaLDEhW1u34gKenbeYqAix21mdUKJyuyu5F1rzYGVxyL6tmgBUAEPrEz92mBXjByMRiJdba9wpnN37RLLAXa"
    )
    assert (
        bip32.get_xpriv_from_path("m")
        == "xprv9s21ZrQH143K48vGoLGRPxgo2JNkJ3J3fqkirQC2zVdk5Dgd5w14S7fRDyHH4dWNHUgkvsvNDCkvAwcSHNAQwhwgNMgZhLtQC63zxwhQmRv"
    )
    # Chain m/0/H
    assert (
        bip32.get_xpub_from_path("m/0h")
        == "xpub69AUMk3qDBi3uW1sXgjCmVjJ2G6WQoYSnNHyzkmdCHEhSZ4tBok37xfFEqHd2AddP56Tqp4o56AePAgCjYdvpW2PU2jbUPFKsav5ut6Ch1m"
    )
    assert (
        bip32.get_xpriv_from_path("m/0h")
        == "xprv9vB7xEWwNp9kh1wQRfCCQMnZUEG21LpbR9NPCNN1dwhiZkjjeGRnaALmPXCX7SgjFTiCTT6bXes17boXtjq3xLpcDjzEuGLQBM5ohqkao9G"
    )
    # Chain m/0H/1H
    assert (
        bip32.get_xpub_from_path("m/0h/1h")
        == "xpub6BJA1jSqiukeaesWfxe6sNK9CCGaujFFSJLomWHprUL9DePQ4JDkM5d88n49sMGJxrhpjazuXYWdMf17C9T5XnxkopaeS7jGk1GyyVziaMt"
    )
    assert (
        bip32.get_xpriv_from_path("m/0h/1h")
        == "xprv9xJocDuwtYCMNAo3Zw76WENQeAS6WGXQ55RCy7tDJ8oALr4FWkuVoHJeHVAcAqiZLE7Je3vZJHxspZdFHfnBEjHqU5hG1Jaj32dVoS6XLT1"
    )


def test_vector_5():
    invalid_xpubs = [
        "xpub661MyMwAqRbcEYS8w7XLSVeEsBXy79zSzH1J8vCdxAZningWLdN3zgtU6LBpB85b3D2yc8sfvZU521AAwdZafEz7mnzBBsz4wKY5fTtTQBm",
        "xpub661MyMwAqRbcEYS8w7XLSVeEsBXy79zSzH1J8vCdxAZningWLdN3zgtU6Txnt3siSujt9RCVYsx4qHZGc62TG4McvMGcAUjeuwZdduYEvFn",
        "xpub661MyMwAqRbcEYS8w7XLSVeEsBXy79zSzH1J8vCdxAZningWLdN3zgtU6N8ZMMXctdiCjxTNq964yKkwrkBJJwpzZS4HS2fxvyYUA4q2Xe4",
        "xpub661no6RGEX3uJkY4bNnPcw4URcQTrSibUZ4NqJEw5eBkv7ovTwgiT91XX27VbEXGENhYRCf7hyEbWrR3FewATdCEebj6znwMfQkhRYHRLpJ",
        "xpub661MyMwAuDcm6CRQ5N4qiHKrJ39Xe1R1NyfouMKTTWcguwVcfrZJaNvhpebzGerh7gucBvzEQWRugZDuDXjNDRmXzSZe4c7mnTK97pTvGS8",
        "DMwo58pR1QLEFihHiXPVykYB6fJmsTeHvyTp7hRThAtCX8CvYzgPcn8XnmdfHGMQzT7ayAmfo4z3gY5KfbrZWZ6St24UVf2Qgo6oujFktLHdHY4",
        "DMwo58pR1QLEFihHiXPVykYB6fJmsTeHvyTp7hRThAtCX8CvYzgPcn8XnmdfHPmHJiEDXkTiJTVV9rHEBUem2mwVbbNfvT2MTcAqj3nesx8uBf9",
        "xpub661MyMwAqRbcEYS8w7XLSVeEsBXy79zSzH1J8vCdxAZningWLdN3zgtU6Q5JXayek4PRsn35jii4veMimro1xefsM58PgBMrvdYre8QyULY",
    ]
    for xpub in invalid_xpubs:
        with pytest.raises(ValueError):
            BIP32.from_xpub(xpub)

    invalid_xprivs = [
        "xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHL",
        "xprv9s21ZrQH143K24Mfq5zL5MhWK9hUhhGbd45hLXo2Pq2oqzMMo63oStZzF93Y5wvzdUayhgkkFoicQZcP3y52uPPxFnfoLZB21Teqt1VvEHx",
        "xprv9s21ZrQH143K24Mfq5zL5MhWK9hUhhGbd45hLXo2Pq2oqzMMo63oStZzFAzHGBP2UuGCqWLTAPLcMtD5SDKr24z3aiUvKr9bJpdrcLg1y3G",
        "xprv9s21ZrQH4r4TsiLvyLXqM9P7k1K3EYhA1kkD6xuquB5i39AU8KF42acDyL3qsDbU9NmZn6MsGSUYZEsuoePmjzsB3eFKSUEh3Gu1N3cqVUN",
        "xprv9s21ZrQH143K24Mfq5zL5MhWK9hUhhGbd45hLXo2Pq2oqzMMo63oStZzFAzHGBP2UuGCqWLTAPLcMtD9y5gkZ6Eq3Rjuahrv17fEQ3Qen6J",
        "xprv9s2SPatNQ9Vc6GTbVMFPFo7jsaZySyzk7L8n2uqKXJen3KUmvQNTuLh3fhZMBoG3G4ZW1N2kZuHEPY53qmbZzCHshoQnNf4GvELZfqTUrcv",
        "xprv9s21ZrQH143K24Mfq5zL5MhWK9hUhhGbd45hLXo2Pq2oqzMMo63oStZzFGpWnsj83BHtEy5Zt8CcDr1UiRXuWCmTQLxEK9vbz5gPstX92JQ",
        "xprv9s21ZrQH143K24Mfq5zL5MhWK9hUhhGbd45hLXo2Pq2oqzMMo63oStZzFGTQQD3dC4H2D5GBj7vWvSQaaBv5cxi9gafk7NF3pnBju6dwKvH",
        "DMwo58pR1QLEFihHiXPVykYB6fJmsTeHvyTp7hRThAtCX8CvYzgPcn8XnmdfHGMQzT7ayAmfo4z3gY5KfbrZWZ6St24UVf2Qgo6oujFktLHdHY4",
        "DMwo58pR1QLEFihHiXPVykYB6fJmsTeHvyTp7hRThAtCX8CvYzgPcn8XnmdfHPmHJiEDXkTiJTVV9rHEBUem2mwVbbNfvT2MTcAqj3nesx8uBf9",
    ]
    for xpriv in invalid_xprivs:
        with pytest.raises(ValueError):
            BIP32.from_xpriv(xpriv)


def test_sanity_checks():
    seed = bytes.fromhex(
        "1077a46dc8545d372f22d9e110ae6c5c2bf7620fe9c4c911f5404d112233e1aa270567dd3554092e051ba3ba86c303590b0309116ac89964ff284db2219d7511"
    )
    first_bip32 = BIP32.from_seed(seed)
    sec_bip32 = BIP32.from_xpriv(
        "xprv9s21ZrQH143K3o4KUs47P2x9afhH31ekMo2foNTYwrU9wwZ8g5EatR9bn6YmCacdvnHWMnPFUqieQrnunrzuF5UfgGbhbEW43zRnhpPDBUL"
    )
    assert first_bip32.get_xpriv() == sec_bip32.get_xpriv()
    assert first_bip32.get_xpub() == sec_bip32.get_xpub()
    # Fuzz it a bit
    for i in range(50):
        path = [int.from_bytes(os.urandom(3), "big") for _ in range(5)]
        h_path = [
            HARDENED_INDEX + int.from_bytes(os.urandom(3), "big") for _ in range(5)
        ]
        mixed_path = [int.from_bytes(os.urandom(3), "big") for _ in range(5)]
        for i in mixed_path:
            if int.from_bytes(os.urandom(32), "big") % 2:
                i += HARDENED_INDEX
        assert first_bip32.get_xpriv_from_path(path) == sec_bip32.get_xpriv_from_path(
            path
        )
        assert first_bip32.get_xpub_from_path(path) == sec_bip32.get_xpub_from_path(
            path
        )
        assert first_bip32.get_xpriv_from_path(h_path) == sec_bip32.get_xpriv_from_path(
            h_path
        )
        assert first_bip32.get_xpub_from_path(h_path) == sec_bip32.get_xpub_from_path(
            h_path
        )
        assert first_bip32.get_xpriv_from_path(
            mixed_path
        ) == sec_bip32.get_xpriv_from_path(mixed_path)
        assert first_bip32.get_xpub_from_path(
            mixed_path
        ) == sec_bip32.get_xpub_from_path(mixed_path)

    # Taken from iancoleman's website
    bip32 = BIP32.from_seed(
        bytes.fromhex(
            "ac8c2377e5cde867d7e420fbe04d8906309b70d51b8fe58d6844930621a9bc223929155dcfebb4da9d62c86ec0d15adf936a663f4f0cf39cbb0352e7dac073d6"
        )
    )
    assert (
        bip32.get_xpriv()
        == bip32.get_xpriv_from_path([])
        == "xprv9s21ZrQH143K2GzaKJsW7DQsxeDpY3zqgusaSx6owWGC19k4mhwnVAsm4qPsCw43NkY2h1BzVLyxWHt9NKF86QRyBj53vModdGcNxtpD6KX"
    )
    assert (
        bip32.get_xpub()
        == bip32.get_xpub_from_path([])
        == "xpub661MyMwAqRbcEm53RLQWUMMcWg4JwWih48oBFLWRVqoAsx5DKFG32yCEv8iH29TWpmo5KTcpsjXcea6Zx4Hc6PAbGnHjEDCf3yHbj7qdpnf"
    )
    # Sanity checks for m/0'/0'/14/0'/18
    xpriv = bip32.get_xpriv_from_path(
        [HARDENED_INDEX, HARDENED_INDEX, 14, HARDENED_INDEX, 18]
    )
    xpub = bip32.get_xpub_from_path(
        [HARDENED_INDEX, HARDENED_INDEX, 14, HARDENED_INDEX, 18]
    )
    assert (
        xpriv
        == "xprvA2YVbLvEeKaPedw7F6RLwG3RgYnTq1xGCyDNMgZNWdEQnSUBQmKEuLyA6TSPsggt5xvyJHLD9L25tNLpQiP4Q8ZkQNo8ueAgeYj5zYq8hSm"
    )
    assert (
        xpub
        == "xpub6FXqzrT8Uh8gs81aM7xMJPzAEacxEUg7aC8yA4xz4xmPfEoKxJdVT9Hdwm3LwVQrSos2rhGDt8aGGHvdLr5LLAjK8pXFkbSpzGoGTXjd4z9"
    )
    # Now if we our master is m/0'/0'/14, we should derive the same keys for
    # m/0'/18 !
    xpriv2 = bip32.get_xpriv_from_path([HARDENED_INDEX, HARDENED_INDEX, 14])
    assert (
        xpriv2
        == "xprv9yQJmvQMywM5i7UNuZ4RQ1A9rEMwAJCExPardkmBCB46S3vBqNEatSwLUrwLNLHBu1Kd9aGxGKDD5YAfs6hRzpYthciAHjtGadxgV2PeqY9"
    )
    bip32 = BIP32.from_xpriv(xpriv2)
    assert bip32.get_xpriv() == xpriv2
    assert bip32.get_xpriv_from_path([HARDENED_INDEX, 18]) == xpriv
    assert bip32.get_xpub_from_path([HARDENED_INDEX, 18]) == xpub

    # We should recognize the networks..
    # .. for xprivs:
    bip32 = BIP32.from_xpriv(
        "xprv9wHokC2KXdTSpEepFcu53hMDUHYfAtTaLEJEMyxBPAMf78hJg17WhL5FyeDUQH5KWmGjGgEb2j74gsZqgupWpPbZgP6uFmP8MYEy5BNbyET"
    )
    assert bip32.network == "main"
    bip32 = BIP32.from_xpriv(
        "tprv8ZgxMBicQKsPeCBsMzQCCb5JcW4S49MVL3EwhdZMF1RF71rgisZU4ZRvrHX6PZQEiNUABDLvYqpx8Lsccq8aGGR59qHAoLoE3iXYuDa8JTP"
    )
    assert bip32.network == "test"
    # .. for xpubs:
    bip32 = BIP32.from_xpub(
        "xpub6AHA9hZDN11k2ijHMeS5QqHx2KP9aMBRhTDqANMnwVtdyw2TDYRmF8PjpvwUFcL1Et8Hj59S3gTSMcUQ5gAqTz3Wd8EsMTmF3DChhqPQBnU"
    )
    assert bip32.network == "main"
    bip32 = BIP32.from_xpub(
        "tpubD6NzVbkrYhZ4WN3WiKRjeo2eGyYNiKNg8vcQ1UjLNJJaDvoFhmR1XwJsbo5S4vicSPoWQBThR3Rt8grXtP47c1AnoiXMrEmFdRZupxJzH1j"
    )
    assert bip32.network == "test"

    # We should create valid network encoding..
    assert BIP32.from_seed(os.urandom(32), "test").get_xpub().startswith("tpub")
    assert BIP32.from_seed(os.urandom(32), "test").get_xpriv().startswith("tprv")
    assert BIP32.from_seed(os.urandom(32), "main").get_xpub().startswith("xpub")
    assert BIP32.from_seed(os.urandom(32), "main").get_xpriv().startswith("xprv")

    # We can get the keys from "m" or []
    bip32 = BIP32.from_seed(os.urandom(32))
    assert (
        bip32.get_xpub()
        == bip32.get_xpub_from_path("m")
        == bip32.get_xpub_from_path([])
    )
    assert (
        bip32.get_xpriv()
        == bip32.get_xpriv_from_path("m")
        == bip32.get_xpriv_from_path([])
    )
    non_extended_pubkey = bip32.get_privkey_from_path("m")
    pubkey = coincurve.PublicKey.from_secret(non_extended_pubkey)
    assert pubkey.format() == bip32.get_pubkey_from_path("m")
    # But getting from "m'" does not make sense
    with pytest.raises(ValueError, match="invalid format"):
        bip32.get_pubkey_from_path("m'")

    # We raise if we attempt to use a privkey without privkey access
    bip32 = BIP32.from_xpub(
        "xpub6C6zm7YgrLrnd7gXkyYDjQihT6F2ei9EYbNuSiDAjok7Ht56D5zbnv8WDoAJGg1RzKzK4i9U2FUwXG7TFGETFc35vpQ4sZBuYKntKMLshiq"
    )
    bip32.get_xpub()
    bip32.get_pubkey_from_path("m/0/1")
    bip32.get_xpub_from_path("m/10000/18")
    with pytest.raises(PrivateDerivationError):
        bip32.get_xpriv()
        bip32.get_extended_privkey_from_path("m/0/1/2")
        bip32.get_privkey_from_path([9, 8])
        bip32.get_pubkey_from_path("m/0'/1")
        bip32.get_xpub_from_path("m/10000'/18")

    # We can't create a BIP32 for an unknown network (to test InvalidInputError)
    with pytest.raises(InvalidInputError, match="'network' must be one of"):
        BIP32.from_seed(os.urandom(32), network="invalid_net")
