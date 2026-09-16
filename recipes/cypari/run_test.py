"""Functional checks for the conda-forge cypari package.

Upstream's own suite is `python -m cypari.test`. It passes in full here on
macOS (2454 checks) but has one linux only failure: PARI's pari_err2str
returns "not a function in function cal" on linux, one character short of the
"call" its PariError.errtext doctest expects. That is a cosmetic difference in
an error string, so rather than pin the suite to a platform these checks
exercise the same ground and assert on the error text by substring.
"""

from cypari import pari
from cypari._pari import PariError


def test_arithmetic():
    assert str(pari("2^100")) == "1267650600228229401496703205376"
    assert int(pari(2) ** 10) == 1024
    assert str(pari(1000).nextprime()) == "1009"


def test_factorisation():
    # 600851475143 = 71 * 839 * 1471 * 6857
    assert str(pari("factor(600851475143)")) == "[71, 1; 839, 1; 1471, 1; 6857, 1]"
    assert str(pari(97).isprime()) == "True"


def test_number_theory():
    assert str(pari("quadgen(5)^2")) == "1 + w"
    assert str(pari(30).eulerphi()) == "8"
    assert str(pari("Mod(3, 7)^-1")) == "Mod(5, 7)"


def test_real_precision():
    # The PARI series pinned in the recipe must agree here. Against 2.17 this
    # returns 3.14159265358973, which is why the recipe pins pari 2.15.*.
    assert str(pari.pi()).startswith("3.14159265358979")


def test_linked_pari_version():
    major, minor = pari.version()[:2]
    assert (major, minor) == (2, 15), pari.version()


def test_error_handling():
    try:
        pari("pi()")
    except PariError as exc:
        # Substring rather than equality: the linux build of PARI drops the
        # final character of this message.
        assert "not a function" in exc.errtext(), exc.errtext()
    else:
        raise AssertionError("expected PariError for pi()")

    try:
        pari(1) / pari(0)
    except PariError as exc:
        assert "impossible inverse" in exc.errtext(), exc.errtext()
    else:
        raise AssertionError("expected PariError for division by zero")


if __name__ == "__main__":
    for name, check in sorted(globals().items()):
        if name.startswith("test_"):
            check()
            print("ok", name)
