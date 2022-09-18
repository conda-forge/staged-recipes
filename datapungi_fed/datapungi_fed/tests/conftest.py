# content of conftest.py
import pytest


def pytest_addoption(parser):
    parser.addoption(
        "--cmdopt", action="store", default="", help="enter API key"
    )


@pytest.fixture
def cmdopt(request):
    return request.config.getoption("--cmdopt")