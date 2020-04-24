from __future__ import print_function
import exception_test  # noqa
import testLib


try:
    testLib.failLSSTException("message1")
except Exception as e:
    print("\nexception:", repr(e), "\n")
    assert repr(e) == "LSSTException('message1')"


try:
    testLib.failCustomError("message2")
except Exception as e:
    print("\nexception:", repr(e), "\n")
    assert repr(e) == "CustomError('message2')"


try:
    testLib.failLSSTException("message3")
except exception_test.LSSTException as e:
    print("\nexception:", repr(e), "\n")
    assert repr(e) == "LSSTException('message3')"


try:
    testLib.failCustomError("message4")
except exception_test.LSSTException as e:
    print("\nexception:", repr(e), "\n")
    assert repr(e) == "CustomError('message4')"


print("\nPASSED")
