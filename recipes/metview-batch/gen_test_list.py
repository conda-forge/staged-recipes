import os

# Start,End,Stride
nums = "0,0,0"

# the environment variable TESTS_TO_SKIP should be a comma separated list of integers
tests_to_skip = list(map(int, os.environ["TESTS_TO_SKIP"].split(",")))

NUM_TESTS = int(os.environ["NUM_TESTS"])

for i in range(1, NUM_TESTS+1):
    if not (i in tests_to_skip):
        nums += "," + str(i)

with open("test_list.txt", "w") as f:
    f.write(nums)
