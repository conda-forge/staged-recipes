#! /bin/bash
import sys
import landlab
result = landlab.test()
if result.wasSuccessful():
    sys.exit(0)
else:
    sys.exit(1)
