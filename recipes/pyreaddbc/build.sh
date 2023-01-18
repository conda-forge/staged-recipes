#!/usr/bin/env bash

poetry config experimental.new-installer false
poetry config virtualenvs.create false
poetry install --only-root
