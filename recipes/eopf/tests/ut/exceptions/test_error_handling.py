import pytest

from eopf.exceptions.error_handling import (
    ERROR_POLICY_MAPPING,
    BestEffortPolicy, ErrorPolicy,
    FailFastPolicy,
    FailOnCriticalPolicy,
)
from eopf.exceptions.errors import CriticalException, ExceptionWithExitCode


@pytest.mark.unit
def test_fail_fast():
    """ """
    policy = FailFastPolicy()
    with pytest.raises(ExceptionWithExitCode):
        try:
            raise ExceptionWithExitCode("test")
        except Exception as e:
            policy.handle(e)


@pytest.mark.unit
def test_fail_on_critical():
    """ """
    policy = FailOnCriticalPolicy()
    try:
        raise ExceptionWithExitCode("test")
    except Exception as e:
        policy.handle(e)
    with pytest.raises(CriticalException):
        try:
            raise CriticalException("test")
        except Exception as e:
            policy.handle(e)


@pytest.mark.unit
def test_fail_on_critical_not_raised():
    """ """
    policy = FailOnCriticalPolicy()
    try:
        raise ExceptionWithExitCode("test")
    except Exception as e:
        policy.handle(e)
    with pytest.raises(ExceptionWithExitCode):
        policy.finalize()


@pytest.mark.unit
def test_best_efforts():
    """ """
    policy = BestEffortPolicy()
    try:
        raise ExceptionWithExitCode("test")
    except Exception as e:
        policy.handle(e)
    try:
        raise CriticalException("test")
    except Exception as e:
        policy.handle(e)

    assert len(policy.errors) == 2
    with pytest.raises(ExceptionWithExitCode):
        policy.finalize()


@pytest.mark.unit
@pytest.mark.parametrize(
    "policy, original_exc, cleanup_exc, result_exc",
    [
        (FailFastPolicy(), KeyError, ValueError, KeyError),
        (FailFastPolicy(), ExceptionWithExitCode, ValueError, ExceptionWithExitCode),
        (BestEffortPolicy(), KeyError, ValueError, KeyError),
        (BestEffortPolicy(), ExceptionWithExitCode, ValueError, ValueError),
        (BestEffortPolicy(), ValueError, ExceptionWithExitCode, ValueError),
        (BestEffortPolicy(), ExceptionWithExitCode, ExceptionWithExitCode, ExceptionWithExitCode),
        (BestEffortPolicy(), ExceptionWithExitCode, CriticalException, CriticalException),
        (FailOnCriticalPolicy(), ExceptionWithExitCode, CriticalException, CriticalException),
        (FailOnCriticalPolicy(), ExceptionWithExitCode, ExceptionWithExitCode, ExceptionWithExitCode),
        (FailOnCriticalPolicy(), ValueError, ExceptionWithExitCode, ValueError),
        (FailOnCriticalPolicy(), ValueError, CriticalException, ValueError),
        (FailOnCriticalPolicy(), ValueError, CriticalException, ValueError),
    ],
)
def test_combined_error(policy: ErrorPolicy, original_exc, cleanup_exc, result_exc):
    with pytest.raises(result_exc):
        try:
            try:
                raise original_exc("truc")
            except Exception as e:
                policy.handle(e)
        finally:
            try:
                raise cleanup_exc("much")
            except Exception as ebis:
                policy.handle(ebis)
            policy.finalize()


@pytest.mark.unit
@pytest.mark.parametrize(
    "name, value",
    [
        ("FAIL_FAST", FailFastPolicy),
        ("FAIL_ON_CRITICAL", FailOnCriticalPolicy),
        ("BEST_EFFORT", BestEffortPolicy),
    ],
)
def test_mapping(name, value):
    assert ERROR_POLICY_MAPPING[name] == value


@pytest.mark.unit
def test_bad_mapping():
    with pytest.raises(KeyError):
        ERROR_POLICY_MAPPING["truc"]
