import numpy
from threadpoolctl import threadpool_info, threadpool_limits


if __name__ == "main":
    print(threadpool_info())

    with threadpool_limits(1):
        print(threadpool_info())
