try:
    import lance  # noqa
except Exception:
    print("\033[0;31mFAILED:\033[0m run_tests.py")
    raise
else:
    print("\033[0;32mPASSED:\033[0m run_tests.py")
