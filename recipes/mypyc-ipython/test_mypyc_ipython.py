from IPython import get_ipython
shell = get_ipython()

shell.run_line_magic("reload_ext", "mypyc_ipython")

FIB_FAST = """def my_fibonacci_fast(n: int) -> int:
    if n <= 2:
        return 1
    else:
        return my_fibonacci_fast(n-1) + my_fibonacci_fast(n-2)"""

print("...compiling with mypyc...", flush=True)
shell.run_cell_magic("mypyc", "", FIB_FAST)

print("...forcing re-compile with mypyc...", flush=True)
shell.run_cell_magic("mypyc", "--force", FIB_FAST)

print("...forcing re-compile with verbose mypyc...", flush=True)
shell.run_cell_magic("mypyc", "--force --verbose", FIB_FAST)

print("...benchmarking...")

def my_fibonacci_slow(n: int) -> int:
    if n <= 2:
        return 1
    else:
        return my_fibonacci_slow(n-1) + my_fibonacci_slow(n-2)

shell.user_ns["my_fibonacci_slow"] = my_fibonacci_slow

print("...running %%timeit WITHOUT mypyc...", flush=True)
t0 = shell.run_line_magic("timeit", "-o my_fibonacci_slow(20)")

print("...running %%timeit with mypyc...", flush=True)
t1 = shell.run_line_magic("timeit", "-o my_fibonacci_fast(20)")

print("...without mypyc:", t0.best)
print("...with mypyc:   ", t1.best)

assert t1.best < t0.best, f"OH NO: it was {int(t1.best / t0.best)} slower"

print(f"OK: it was {int(t0.best / t1.best)}x faster")
