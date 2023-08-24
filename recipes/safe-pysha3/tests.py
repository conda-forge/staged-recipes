from __future__ import print_function

import hashlib
import hmac
import os
import sys
import unittest

import sha3


if sys.version_info[0] == 3:
    fromhex = bytes.fromhex

    def tobyte(b):
        return bytes([b])

    def asunicode(s):
        return s
else:
    def fromhex(s):
        return s.decode('hex')

    def tobyte(b):
        return bytes(b)

    def asunicode(s):
        return s.decode('ascii')


def read_vectors(hash_name):
    vector = os.path.join('vectors', hash_name + '.txt')
    with open(vector) as f:
        for line in f:
            line = line.strip()
            if line.startswith('#') or not line:
                continue
            msg, md = line.split(',')
            yield msg, md


class BaseSHA3Tests(unittest.TestCase):
    new = None
    name = None
    digest_size = None
    block_size = None
    rate_bits = None
    capacity_bits = None
    shake = False

    vectors = []
    # http://wolfgang-ehrhardt.de/hmac-sha3-testvectors.html
    hmac_vectors = [
        ("0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b", "4869205468657265"),
        ("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" +
         "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" +
         "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" +
         "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" +
         "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
         "5468697320697320612074657374207573696e672061206c6172676572207" +
         "468616e20626c6f636b2d73697a65206b657920616e642061206c617267657" +
         "2207468616e20626c6f636b2d73697a6520646174612e20546865206b65792" +
         "06e6565647320746f20626520686173686564206265666f7265206265696e6" +
         "720757365642062792074686520484d414320616c676f726974686d2e")
    ]
    hmac_results = []

    def assertHashDigest(self, hexmsg, hexdigest):
        hexdigest = hexdigest.lower()
        msg = fromhex(hexmsg)
        digest = fromhex(hexdigest)
        self.assertEqual(len(digest), self.digest_size)

        sha3 = self.new(msg)
        self.assertEqual(sha3.hexdigest(), hexdigest)
        self.assertEqual(sha3.digest(), digest)

        sha3 = self.new()
        sha3.update(msg)
        self.assertEqual(sha3.hexdigest(), hexdigest)
        self.assertEqual(sha3.digest(), digest)

        sha3 = self.new()
        for b in msg:
            sha3.update(tobyte(b))
        self.assertEqual(sha3.hexdigest(), hexdigest)
        self.assertEqual(sha3.digest(), digest)

    def test_basics(self):
        sha3 = self.new()
        self.assertEqual(sha3.name, self.name)
        self.assertEqual(sha3.digest_size, self.digest_size)
        self.assertEqual(sha3._capacity_bits + sha3._rate_bits, 1600)
        self.assertEqual(sha3._rate_bits, self.rate_bits)
        self.assertEqual(sha3._capacity_bits, self.capacity_bits)
        if self.block_size is not None:
            self.assertEqual(sha3.block_size, self.block_size)

        if self.shake:
            self.assertEqual(len(sha3.digest(4)), 4)
            self.assertEqual(len(sha3.hexdigest(4)), 8)
            self.assertEqual(len(sha3.digest(8)), 8)
            self.assertEqual(len(sha3.hexdigest(8)), 16)
            self.assertEqual(len(sha3.digest(97)), 97)
            self.assertEqual(len(sha3.hexdigest(97)), 194)
        else:
            self.assertEqual(len(sha3.digest()), self.digest_size)
            self.assertEqual(len(sha3.hexdigest()), self.digest_size * 2)

        # object is read-only
        self.assertRaises(AttributeError, setattr, sha3, "attribute", None)
        self.assertRaises(AttributeError, setattr, sha3, "digest_size", 3)
        self.assertRaises(AttributeError, setattr, sha3, "name", "egg")

        self.new(b"data")
        self.new(string=b"data")
        self.assertRaises(TypeError, self.new, None)
        self.assertRaises(TypeError, sha3.update, None)
        self.assertRaises(TypeError, self.new, asunicode("text"))
        self.assertRaises(TypeError, sha3.update, asunicode("text"))

        sha3type = type(sha3)
        self.assertEqual(sha3type.__name__, self.name)
        self.assertEqual(sha3type.__module__, "_pysha3")
        self.assertIsInstance(sha3type(), sha3type)
        self.assertIs(sha3type, self.new)
        self.assertRaises(TypeError, type, sha3type, "subclass", {})

    def test_hashlib(self):
        constructor = getattr(hashlib, self.name)
        s1 = constructor()
        self.assertEqual(s1.name, self.name)
        self.assertEqual(s1.digest_size, self.digest_size)

        # s2 = hashlib.new(self.name)
        # self.assertEqual(s2.name, self.name)
        # self.assertEqual(s2.digest_size, self.digest_size)
        # self.assertEqual(type(s1), type(s2))

        # if sys.version_info < (3, 4):
        #     self.assertEqual(constructor, self.new)

    def test_vectors(self):
        for hexmsg, hexdigest in read_vectors(self.name):
            self.assertHashDigest(hexmsg, hexdigest)

    def test_vectors_unaligned(self):
        for hexmsg, hexdigest in self.vectors:
            hexdigest = hexdigest.lower()
            msg = fromhex(hexmsg)
            digest = fromhex(hexdigest)
            for i in range(1, 15):
                msg2 = i * b"\x00" + msg
                unaligned = memoryview(msg2)[i:]
                self.assertEqual(unaligned, msg)

                sha3 = self.new(unaligned)
                self.assertEqual(sha3.hexdigest(), hexdigest)
                self.assertEqual(sha3.digest(), digest)

    def test_hmac(self):
        for (key, msg), expected in zip(self.hmac_vectors, self.hmac_results):
            key = fromhex(key)
            msg = fromhex(msg)
            mac = hmac.new(key, msg, self.new)
            self.assertEqual(len(mac.digest()), self.digest_size)
            result = mac.hexdigest()
            self.assertEqual(result, expected,
                             "%s != %s for %r, %r" %
                             (result, expected, key, msg))


class BaseKeccakTests(BaseSHA3Tests):
    def test_hashlib(self):
        self.failIf(hasattr(hashlib, self.name))


class BaseShakeTests(BaseSHA3Tests):
    shake = True

    def assertHashDigest(self, hexmsg, hexdigest):
        hexdigest = hexdigest.lower()
        msg = fromhex(hexmsg)
        digest = fromhex(hexdigest)
        # self.assertEqual(len(digest), self.digest_size)

        sha3 = self.new(msg)
        self.assertEqual(sha3.hexdigest(len(digest)), hexdigest)
        self.assertEqual(sha3.digest(len(digest)), digest)

        sha3 = self.new()
        sha3.update(msg)
        self.assertEqual(sha3.hexdigest(len(digest)), hexdigest)
        self.assertEqual(sha3.digest(len(digest)), digest)

        sha3 = self.new()
        for b in msg:
            sha3.update(tobyte(b))
        self.assertEqual(sha3.hexdigest(len(digest)), hexdigest)
        self.assertEqual(sha3.digest(len(digest)), digest)


class SHA3_224Tests(BaseSHA3Tests):
    new = sha3.sha3_224
    name = "sha3_224"
    digest_size = 28
    block_size = 144
    rate_bits = 1152
    capacity_bits = 448
    hmac_results = [
        "3b16546bbc7be2706a031dcafd56373d9884367641d8c59af3c860f7",
        "c79c9b093424e588a9878bbcb089e018270096e9b4b1a9e8220c866a",
        ]


class SHA3_256Tests(BaseSHA3Tests):
    new = sha3.sha3_256
    name = "sha3_256"
    digest_size = 32
    block_size = 136
    rate_bits = 1088
    capacity_bits = 512
    hmac_results = [
        "ba85192310dffa96e2a3a40e69774351140bb7185e1202cdcc917589f95e16bb",
        "e6a36d9b915f86a093cac7d110e9e04cf1d6100d30475509c2475f571b758b5a",
        ]


class SHA3_384Tests(BaseSHA3Tests):
    new = sha3.sha3_384
    name = "sha3_384"
    digest_size = 48
    block_size = 104
    rate_bits = 832
    capacity_bits = 768
    hmac_results = [
        "68d2dcf7fd4ddd0a2240c8a437305f61fb7334cfb5d0226e1bc27dc10a2e72" +
        "3a20d370b47743130e26ac7e3d532886bd",
        "cad18a8ff6c4cc3ad487b95f9769e9b61c062aefd6952569e6e6421897054c" +
        "fc70b5fdc6605c18457112fc6aaad45585",
        ]


class SHA3_512Tests(BaseSHA3Tests):
    new = sha3.sha3_512
    name = "sha3_512"
    digest_size = 64
    block_size = 72
    rate_bits = 576
    capacity_bits = 1024
    hmac_results = [
        "eb3fbd4b2eaab8f5c504bd3a41465aacec15770a7cabac531e482f860b5ec7" +
        "ba47ccb2c6f2afce8f88d22b6dc61380f23a668fd3888bb80537c0a0b86407689e",
        "dc030ee7887034f32cf402df34622f311f3e6cf04860c6bbd7fa488674782b" +
        "4659fdbdf3fd877852885cfe6e22185fe7b2ee952043629bc9d5f3298a41d02c66",
        ]


class Shake_128Tests(BaseShakeTests):
    new = sha3.shake_128
    name = "shake_128"
    digest_size = 0
    block_size = 168
    rate_bits = 1344
    capacity_bits = 256


class Shake_256Tests(BaseShakeTests):
    new = sha3.shake_256
    name = "shake_256"
    digest_size = 0
    block_size = 136
    rate_bits = 1088
    capacity_bits = 512


class Keccak_224Tests(BaseKeccakTests):
    new = sha3.keccak_224
    name = "keccak_224"
    digest_size = 28
    block_size = 144
    rate_bits = 1152
    capacity_bits = 448
    hmac_results = [
        "b73d595a2ba9af815e9f2b4e53e78581ebd34a80b3bbaac4e702c4cc",
        "92649468be236c3c72c189909c063b13f994be05749dc91310db639e",
        ]


class Keccak_256Tests(BaseKeccakTests):
    new = sha3.keccak_256
    name = "keccak_256"
    digest_size = 32
    block_size = 136
    rate_bits = 1088
    capacity_bits = 512
    hmac_results = [
        "9663d10c73ee294054dc9faf95647cb99731d12210ff7075fb3d3395abfb9821",
        "fdaa10a0299aecff9bb411cf2d7748a4022e4a26be3fb5b11b33d8c2b7ef5484",
        ]


class Keccak_384Tests(BaseKeccakTests):
    new = sha3.keccak_384
    name = "keccak_384"
    digest_size = 48
    block_size = 104
    rate_bits = 832
    capacity_bits = 768
    hmac_results = [
        "892dfdf5d51e4679bf320cd16d4c9dc6f749744608e003add7fba894acff87" +
        "361efa4e5799be06b6461f43b60ae97048",
        "fe9357e3cfa538eb0373a2ce8f1e26ad6590afdaf266f1300522e8896d27e7" +
        "3f654d0631c8fa598d4bb82af6b744f4f5",
        ]


class Keccak_512Tests(BaseKeccakTests):
    new = sha3.keccak_512
    name = "keccak_512"
    digest_size = 64
    block_size = 72
    rate_bits = 576
    capacity_bits = 1024
    hmac_results = [
        "8852c63be8cfc21541a4ee5e5a9a852fc2f7a9adec2ff3a13718ab4ed81aae" +
        "a0b87b7eb397323548e261a64e7fc75198f6663a11b22cd957f7c8ec858a1c7755",
        "6adc502f14e27812402fc81a807b28bf8a53c87bea7a1df6256bf66f5de1a4" +
        "cb741407ad15ab8abc136846057f881969fbb159c321c904bfb557b77afb7778c8",
        ]


def test_main():
    suite = unittest.TestSuite()
    classes = [
        SHA3_224Tests, SHA3_256Tests, SHA3_384Tests, SHA3_512Tests,
        Shake_128Tests, Shake_256Tests,
        Keccak_224Tests, Keccak_256Tests, Keccak_384Tests, Keccak_512Tests,
    ]
    for cls in classes:
        suite.addTests(unittest.makeSuite(cls))
    return suite


if __name__ == "__main__":
    result = unittest.TextTestRunner(verbosity=2).run(test_main())
    sys.exit(not result.wasSuccessful())
