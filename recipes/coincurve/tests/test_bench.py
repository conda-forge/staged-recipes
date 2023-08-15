from coincurve import PrivateKey, PublicKey, verify_signature

from .samples import MESSAGE, PRIVATE_KEY_BYTES, PUBLIC_KEY_COMPRESSED, SIGNATURE


def test_verify_signature_util(benchmark):
    benchmark(verify_signature, SIGNATURE, MESSAGE, PUBLIC_KEY_COMPRESSED)


def test_private_key_new(benchmark):
    benchmark(PrivateKey)


def test_private_key_load(benchmark):
    benchmark(PrivateKey, PRIVATE_KEY_BYTES)


def test_private_key_sign(benchmark):
    private_key = PrivateKey(PRIVATE_KEY_BYTES)
    benchmark(private_key.sign, MESSAGE)


def test_private_key_sign_recoverable(benchmark):
    private_key = PrivateKey(PRIVATE_KEY_BYTES)
    benchmark(private_key.sign_recoverable, MESSAGE)


def test_private_key_ecdh(benchmark):
    private_key = PrivateKey(PRIVATE_KEY_BYTES)
    benchmark(private_key.ecdh, PUBLIC_KEY_COMPRESSED)


def test_public_key_load(benchmark):
    benchmark(PublicKey, PUBLIC_KEY_COMPRESSED)


def test_public_key_load_from_valid_secret(benchmark):
    benchmark(PublicKey.from_valid_secret, PRIVATE_KEY_BYTES)


def test_public_key_format(benchmark):
    public_key = PublicKey(PUBLIC_KEY_COMPRESSED)
    benchmark(public_key.format)


def test_public_key_point(benchmark):
    public_key = PublicKey(PUBLIC_KEY_COMPRESSED)
    benchmark(public_key.point)


def test_public_key_verify(benchmark):
    public_key = PublicKey(PUBLIC_KEY_COMPRESSED)
    benchmark(public_key.verify, SIGNATURE, MESSAGE)
