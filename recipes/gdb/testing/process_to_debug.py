import os
import signal
os.kill(os.getpid(), signal.SIGSEGV)
