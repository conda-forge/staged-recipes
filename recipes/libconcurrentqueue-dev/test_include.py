import os

prefix = os.environ["PREFIX"]
header = os.path.join(prefix, "include", "concurrentqueue.h")

if not os.path.exists(header):
    raise FileNotFoundError(f"Missing header: {header}")

print("Header found:", header)
