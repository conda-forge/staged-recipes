# trick PyDAQmx
import sys
sys.modules["DAQmxConfigTest"] = None

# verify pydaqmx installed
import PyDAQmx

