import os
os.environ["PYNPUT_BACKEND_KEYBOARD"] = "dummy"
os.environ["PYNPUT_BACKEND"] = "dummy"
os.environ["DISPLAY"] = ":0"
import pynput.mouse
import pynput.keyboard