import ctypes

rccl = ctypes.CDLL("librccl.so")
rccl.ncclGetVersion.argtypes = [ctypes.POINTER(ctypes.c_int)]
rccl.ncclGetVersion.restype = ctypes.c_int
version = ctypes.c_int()
assert rccl.ncclGetVersion(ctypes.byref(version)) == 0
assert version.value > 0

rccl.ncclGetErrorString.argtypes = [ctypes.c_int]
rccl.ncclGetErrorString.restype = ctypes.c_char_p
assert rccl.ncclGetErrorString(0)
print(f"Loaded librccl.so; NCCL API version: {version.value}")
