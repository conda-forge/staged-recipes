#!/usr/bin/env python
"""Test that meta.yaml is a valid YAML after being processed by Jinja"""

from io import StringIO
from pprint import pprint

from jinja2 import Template
import yaml

with open('meta.yaml') as fp:
    t = Template(fp.read())

io = StringIO(t.render(()))
pprint(yaml.load(io))
