"""Check that pyausaxs resolves the conda-installed backend and can initialize it."""


def main():
    from pyausaxs import loader

    path, origin = loader.resolve_lib()
    assert origin == "prefix", f"expected the prefix-installed backend, got {origin!r} at {path}"

    from pyausaxs.wrapper.AUSAXS import AUSAXS

    assert AUSAXS.ready(), f"backend failed to initialize: {AUSAXS.init_error()}"
    print(f"backend ready: {path}")


# pyausaxs runs its backend integration check in a multiprocessing child; with the spawn
# start method (macOS, Windows) the child re-imports this script, so the check must not
# run at import time
if __name__ == "__main__":
    main()
