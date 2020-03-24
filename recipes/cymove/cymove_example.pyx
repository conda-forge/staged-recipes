# distutils: language = c++

from libcpp.memory cimport make_shared, shared_ptr, nullptr
from cymove cimport cymove as move

cdef shared_ptr[int] ptr1, ptr2
cdef int* raw_ptr

ptr1 = make_shared[int](5)
raw_ptr = ptr1.get()
ptr2 = move(ptr1)

assert ptr2.get() == raw_ptr
assert ptr1 == nullptr

print("OK!")
