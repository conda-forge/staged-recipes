#!/usr/bin/env python3
"""
Created on Thr Apr 8 18:00:00 2021

:Authors:
    Mark Driver <mdd31>
    Mark J. Williamson <mjw99>
"""

import logging
from cmlgenerator.test.cmlgeneratortests import run_tests

logging.basicConfig()
LOGGER = logging.getLogger(__name__)
LOGGER.setLevel(logging.WARN)


if __name__ == "__main__":
    run_tests()
