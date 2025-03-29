# Attempt Iris import
import Iris

# Ensure we can load the codec module
from Iris import Codec

# If not running windows, check the encoder module
import platform
if (any(platform.win32_ver()) == False):
    from Iris import Encoder