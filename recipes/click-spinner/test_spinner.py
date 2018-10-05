import sys
import os
import time
import tempfile
from six import StringIO
import click
from click.testing import CliRunner

import click_spinner


def test_spinner():
    @click.command()
    def cli():
       with click_spinner.spinner():
           for thing in range(10):
               pass

    runner = CliRunner()
    result = runner.invoke(cli, [])
    assert result.exception is None


def test_spinner_resume():
    @click.command()
    def cli():
       spinner = click_spinner.Spinner()
       spinner.start()
       for thing in range(10):
           pass
       spinner.stop()
       spinner.start()
       for thing in range(10):
           pass
       spinner.stop()

    runner = CliRunner()
    result = runner.invoke(cli, [])
    assert result.exception is None


def test_spinner_redirect():
    @click.command()
    def cli():
       stdout_io = StringIO()
       saved_stdout = sys.stdout
       sys.stdout = stdout_io  # redirect stdout to a string buffer
       spinner = click_spinner.Spinner()
       spinner.start()
       time.sleep(1)  # allow time for a few spins
       spinner.stop()
       sys.stdout = saved_stdout
       stdout_io.flush()
       stdout_str = stdout_io.getvalue()
       assert len(stdout_str) == 0

    runner = CliRunner()
    result = runner.invoke(cli, [])
    assert result.exception is None


def test_spinner_redirect_force():
    @click.command()
    def cli():
       stdout_io = StringIO()
       saved_stdout = sys.stdout
       sys.stdout = stdout_io  # redirect stdout to a string buffer
       spinner = click_spinner.Spinner(force=True)
       spinner.start()
       time.sleep(1)  # allow time for a few spins
       spinner.stop()
       sys.stdout = saved_stdout
       stdout_io.flush()
       stdout_str = stdout_io.getvalue()
       assert len(stdout_str) > 0

    runner = CliRunner()
    result = runner.invoke(cli, [])
    assert result.exception is None


def test_spinner_disable():
    @click.command()
    def cli():
       stdout_io = StringIO()
       saved_stdout = sys.stdout
       sys.stdout = stdout_io  # redirect stdout to a string buffer
       spinner = click_spinner.Spinner(disable=True)
       spinner.start()
       time.sleep(1)  # allow time for doing nothing
       spinner.stop()
       sys.stdout = saved_stdout
       stdout_io.flush()
       stdout_str = stdout_io.getvalue()
       assert len(stdout_str) == 0

    runner = CliRunner()
    result = runner.invoke(cli, [])
    assert result.exception is None


def test_spinner_as():
    @click.command()
    def cli():
       spinner = click_spinner.spinner()
       with spinner as sp:
           assert sp == spinner

    runner = CliRunner()
    result = runner.invoke(cli, [])
    assert result.exception is None

class CMException(Exception):
    pass


def test_spinner_exc():
    @click.command()
    def cli():
       with click_spinner.spinner():
           for thing in range(10):
               if thing == 5:
                   raise CMException("foo")

    runner = CliRunner()
    result = runner.invoke(cli, [])
    assert isinstance(result.exception, CMException)
