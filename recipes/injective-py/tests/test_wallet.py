from eth_hash.auto import keccak

from pyinjective import Address, PrivateKey


class TestPrivateKey:
    def test_private_key_signature_generation(self):
        private_key = PrivateKey.from_mnemonic("test mnemonic never use other places")

        signature = private_key.sign(msg="test message".encode())
        expected_signature = (
            b'\x8f\xae\xcb#z\x9a+\x12\x88\xea\xb5xZ"\x8f\x98y\xb8\x97\xa7F\xd5\xdd\x15s\x05;'
            b"\x04\x1d\xbaY|rw\x8b\xbb\x19\xfc\x8e\x15\x8b\xf1\x18\x08\xba\xc7\x15\xed\xb0\xee\x95"
            b"\x0e|Ch\x7f\xaf\x9cH\xc6\x9f\xbf\x14\xa5"
        )

        assert expected_signature == signature


class TestPublicKey:
    def test_convert_public_key_to_address(self):
        private_key = PrivateKey.from_mnemonic("test mnemonic never use other places")
        public_key = private_key.to_public_key()
        address = public_key.to_address()

        key = public_key.verify_key.to_string("uncompressed")
        hashed_value = keccak(key[1:])
        expected_address = Address(hashed_value[12:])

        assert expected_address == address
