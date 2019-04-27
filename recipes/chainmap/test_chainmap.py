

from chainmap import *
import pytest


def simple_cm():
    c = ChainMap()
    c['one'] = 1
    c['two'] = 2

    cc = c.new_child()
    cc['one'] = 'one'

    return c, cc


def test_repr():
    c, cc = simple_cm()

    order1 = "ChainMap({'one': 'one'}, {'one': 1, 'two': 2})"
    order2 = "ChainMap({'one': 'one'}, {'two': 2, 'one': 1})"
    assert repr(cc) in [order1, order2]


def test_recursive_repr():
    """
    Test for degnerative recursive cases. Very unlikely in
    ChainMaps. But all must bow before the god of testing coverage.
    """
    c = ChainMap()
    c['one'] = c
    assert repr(c) == "ChainMap({'one': ...})"


def test_get():
    c, cc = simple_cm()

    assert cc.get('two') == 2
    assert cc.get('three') == None
    assert cc.get('three', 'notthree') == 'notthree'


def test_bool():
    c = ChainMap()
    assert not(bool(c))

    c['one'] = 1
    c['two'] = 2
    assert bool(c)

    cc = c.new_child()
    cc['one'] = 'one'
    assert cc


def test_fromkeys():
    keys = 'a b c'.split()
    c = ChainMap.fromkeys(keys)
    assert len(c) == 3
    assert c['a'] == None
    assert c['b'] == None
    assert c['c'] == None


def test_copy():
    c, cc = simple_cm()
    new_cc = cc.copy()
    assert new_cc is not cc
    assert sorted(new_cc.items()) == sorted(cc.items())


def test_parents():
    c, cc = simple_cm()

    new_c = cc.parents
    assert c is not new_c
    assert len(new_c) == 2
    assert new_c['one'] == c['one']
    assert new_c['two'] == c['two']


def test_delitem():
    c, cc = simple_cm()

    with pytest.raises(KeyError):
        del cc['two']

    del cc['one']
    assert len(cc) == 2
    assert cc['one'] == 1
    assert cc['two'] == 2


def test_popitem():
    c, cc = simple_cm()

    assert cc.popitem() == ('one', 'one')

    with pytest.raises(KeyError):
        cc.popitem()


def test_pop():
    c, cc = simple_cm()

    assert cc.pop('one') == 'one'

    with pytest.raises(KeyError):
        cc.pop('two')

    assert len(cc) == 2


def test_clear():
    c, cc = simple_cm()

    cc.clear()
    assert len(cc) == 2
    assert cc['one'] == 1
    assert cc['two'] == 2


def test_missing():

    c, cc = simple_cm()

    with pytest.raises(KeyError):
        cc['clown']
