# this test just makes sure we have the uwsgidecorators python module
try:
    import uwsgidecorators
except ImportError as e:
    # this is the expected behavior
    assert e.message == 'No module named uwsgi', e.message
else:
    raise EnvironmentError("uwsgidecorators didn't import correctly")
