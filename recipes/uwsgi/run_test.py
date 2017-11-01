# this test just makes sure we have the uwsgidecorators python module
try:
    import uwsgidecorators
except ImportError as e:
    # this is the expected behavior
    assert str(e).replace("'", "") == 'No module named uwsgi'
else:
    raise EnvironmentError("uwsgidecorators didn't import correctly")
