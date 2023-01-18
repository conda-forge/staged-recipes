#!/usr/bin/env bash

# curl -sSL https://install.python-poetry.org | python3 -
poetry config experimental.new-installer false
poetry config virtualenvs.create false
poetry install --only-root
