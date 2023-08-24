from hashlib import sha512
from os import urandom

import pytest

from coincurve.ecdsa import deserialize_recoverable, recover
from coincurve.keys import PrivateKey, PublicKey, PublicKeyXOnly
from coincurve.utils import bytes_to_int, int_to_bytes_padded, verify_signature

from .samples import (
    MESSAGE,
    PRIVATE_KEY_BYTES,
    PRIVATE_KEY_DER,
    PRIVATE_KEY_HEX,
    PRIVATE_KEY_NUM,
    PRIVATE_KEY_PEM,
    PUBLIC_KEY_COMPRESSED,
    PUBLIC_KEY_UNCOMPRESSED,
    PUBLIC_KEY_X,
    PUBLIC_KEY_Y,
    RECOVERABLE_SIGNATURE,
    SIGNATURE,
    X_ONLY_PUBKEY,
    X_ONLY_PUBKEY_INVALID,
)

G = PublicKey(
    b'\x04y\xbef~\xf9\xdc\xbb\xacU\xa0b\x95\xce\x87\x0b\x07\x02\x9b'
    b'\xfc\xdb-\xce(\xd9Y\xf2\x81[\x16\xf8\x17\x98H:\xdaw&\xa3\xc4e'
    b']\xa4\xfb\xfc\x0e\x11\x08\xa8\xfd\x17\xb4H\xa6\x85T\x19\x9cG'
    b'\xd0\x8f\xfb\x10\xd4\xb8'
)
n = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141


class TestPrivateKey:
    def test_public_key(self):
        assert PrivateKey(PRIVATE_KEY_BYTES).public_key.format() == PUBLIC_KEY_COMPRESSED

    def test_xonly_pubkey(self):
        assert PrivateKey(PRIVATE_KEY_BYTES).public_key_xonly.format() == PUBLIC_KEY_COMPRESSED[1:]

    def test_signature_correct(self):
        private_key = PrivateKey()
        public_key = private_key.public_key

        message = urandom(200)
        signature = private_key.sign(message)

        assert verify_signature(signature, message, public_key.format(compressed=True))
        assert verify_signature(signature, message, public_key.format(compressed=False))

    def test_signature_deterministic(self):
        assert PrivateKey(PRIVATE_KEY_BYTES).sign(MESSAGE) == SIGNATURE

    def test_signature_invalid_hasher(self):
        with pytest.raises(ValueError):
            PrivateKey().sign(MESSAGE, lambda x: sha512(x).digest())

    def test_signature_recoverable(self):
        private_key = PrivateKey(PRIVATE_KEY_BYTES)
        assert (
            private_key.public_key.format()
            == PublicKey(recover(MESSAGE, deserialize_recoverable(private_key.sign_recoverable(MESSAGE)))).format()
        )

    def test_schnorr_signature(self):
        private_key = PrivateKey()
        message = urandom(32)

        # Message must be 32 bytes
        with pytest.raises(ValueError):
            private_key.sign_schnorr(message + b'\x01')

        # We can provide supplementary randomness
        sig = private_key.sign_schnorr(message, urandom(32))
        assert private_key.public_key_xonly.verify(sig, message)

        # Or not
        sig = private_key.sign_schnorr(message)
        assert private_key.public_key_xonly.verify(sig, message)

    def test_to_hex(self):
        assert PrivateKey(PRIVATE_KEY_BYTES).to_hex() == PRIVATE_KEY_HEX

    def test_to_int(self):
        assert PrivateKey(PRIVATE_KEY_BYTES).to_int() == PRIVATE_KEY_NUM

    def test_to_pem(self):
        assert PrivateKey(PRIVATE_KEY_BYTES).to_pem() == PRIVATE_KEY_PEM

    def test_to_der(self):
        assert PrivateKey(PRIVATE_KEY_BYTES).to_der() == PRIVATE_KEY_DER

    def test_from_hex(self):
        assert PrivateKey.from_hex(PRIVATE_KEY_HEX).secret == PRIVATE_KEY_BYTES

    def test_from_int(self):
        assert PrivateKey.from_int(PRIVATE_KEY_NUM).secret == PRIVATE_KEY_BYTES

    def test_from_pem(self):
        assert PrivateKey.from_pem(PRIVATE_KEY_PEM).secret == PRIVATE_KEY_BYTES

    def test_from_der(self):
        assert PrivateKey.from_der(PRIVATE_KEY_DER).secret == PRIVATE_KEY_BYTES

    def test_ecdh(self):
        a = PrivateKey()
        b = PrivateKey()

        assert a.ecdh(b.public_key.format()) == b.ecdh(a.public_key.format())

    def test_add(self):
        assert PrivateKey(b'\x01').add(b'\x09').to_int() == 10

    def test_add_update(self):
        private_key = PrivateKey(b'\x01')
        new_private_key = private_key.add(b'\x09', update=True)

        assert new_private_key.to_int() == 10
        assert private_key is new_private_key

    def test_multiply(self):
        assert PrivateKey(b'\x05').multiply(b'\x05').to_int() == 25

    def test_multiply_update(self):
        private_key = PrivateKey(b'\x05')
        new_private_key = private_key.multiply(b'\x05', update=True)

        assert new_private_key.to_int() == 25
        assert private_key is new_private_key


class TestPublicKey:
    def test_from_secret(self):
        assert PublicKey.from_secret(PRIVATE_KEY_BYTES).format() == PUBLIC_KEY_COMPRESSED

    def test_from_point(self):
        assert PublicKey.from_point(PUBLIC_KEY_X, PUBLIC_KEY_Y).format() == PUBLIC_KEY_COMPRESSED

    def test_from_signature_and_message(self):
        assert (
            PublicKey.from_secret(PRIVATE_KEY_BYTES).format()
            == PublicKey.from_signature_and_message(RECOVERABLE_SIGNATURE, MESSAGE).format()
        )

    def test_format(self):
        assert PublicKey(PUBLIC_KEY_UNCOMPRESSED).format(compressed=True) == PUBLIC_KEY_COMPRESSED
        assert PublicKey(PUBLIC_KEY_COMPRESSED).format(compressed=False) == PUBLIC_KEY_UNCOMPRESSED

    def test_point(self):
        assert PublicKey(PUBLIC_KEY_COMPRESSED).point() == (PUBLIC_KEY_X, PUBLIC_KEY_Y)

    def test_verify(self):
        public_key = PublicKey(PUBLIC_KEY_COMPRESSED)
        assert public_key.verify(SIGNATURE, MESSAGE)

    def test_transform(self):
        x = urandom(32)
        k = urandom(32)
        point = G.multiply(x)

        assert point.add(k) == G.multiply(int_to_bytes_padded((bytes_to_int(x) + bytes_to_int(k)) % n))

    def test_combine(self):
        a = PrivateKey().public_key
        b = PrivateKey().public_key

        assert PublicKey.combine_keys([a, b]) == a.combine([b])


class TestXonlyPubKey:
    def test_parse_invalid(self):
        # Must be 32 bytes
        with pytest.raises(ValueError):
            PublicKeyXOnly.from_secret(bytes(33))

        # Must be an x coordinate for a valid point
        with pytest.raises(ValueError):
            PublicKeyXOnly(X_ONLY_PUBKEY_INVALID)

    def test_roundtrip(self):
        assert PublicKeyXOnly(X_ONLY_PUBKEY).format() == X_ONLY_PUBKEY
        assert PublicKeyXOnly(PUBLIC_KEY_COMPRESSED[1:]).format() == PUBLIC_KEY_COMPRESSED[1:]

        # Test __eq__
        assert PublicKeyXOnly(X_ONLY_PUBKEY) == PublicKeyXOnly(X_ONLY_PUBKEY)

    def test_tweak(self):
        # Taken from BIP341 test vectors.
        # See github.com/bitcoin/bips/blob/6545b81022212a9f1c814f6ce1673e84bc02c910/bip-0341/wallet-test-vectors.json
        pubkey = PublicKeyXOnly(bytes.fromhex('d6889cb081036e0faefa3a35157ad71086b123b2b144b649798b494c300a961d'))
        pubkey.tweak_add(bytes.fromhex('b86e7be8f39bab32a6f2c0443abbc210f0edac0e2c53d501b36b64437d9c6c70'))
        assert pubkey.format() == bytes.fromhex('53a1f6e454df1aa2776a2814a721372d6258050de330b3c6d10ee8f4e0dda343')

    def test_parity(self):
        # Taken from BIP341 test vectors.
        # See github.com/bitcoin/bips/blob/6545b81022212a9f1c814f6ce1673e84bc02c910/bip-0341/wallet-test-vectors.json
        pubkey = PublicKeyXOnly(bytes.fromhex('187791b6f712a8ea41c8ecdd0ee77fab3e85263b37e1ec18a3651926b3a6cf27'))
        pubkey.tweak_add(bytes.fromhex('cbd8679ba636c1110ea247542cfbd964131a6be84f873f7f3b62a777528ed001'))
        assert pubkey.format() == bytes.fromhex('147c9c57132f6e7ecddba9800bb0c4449251c92a1e60371ee77557b6620f3ea3')
        assert pubkey.parity

        pubkey = PublicKeyXOnly(bytes.fromhex('93478e9488f956df2396be2ce6c5cced75f900dfa18e7dabd2428aae78451820'))
        pubkey.tweak_add(bytes.fromhex('6af9e28dbf9d6aaf027696e2598a5b3d056f5fd2355a7fd5a37a0e5008132d30'))
        assert pubkey.format() == bytes.fromhex('e4d810fd50586274face62b8a807eb9719cef49c04177cc6b76a9a4251d5450e')
        assert not pubkey.parity
