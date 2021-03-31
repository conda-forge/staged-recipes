#!/usr/bin/env python3
"""
Created on Tue Mar 30 09:46:17 2021

:Authors:
    Mark Driver <mdd31>
    Mark J. Williamson <mjw99>
"""

import logging
from xmlvalidator.test.xmlvalidationtest import run_tests

logging.basicConfig()
LOGGER = logging.getLogger(__name__)
LOGGER.setLevel(logging.WARN)


if __name__ == "__main__":
    run_tests()
