try:
    if 'snap_compare' not in globals() or not callable(snap_compare):
        raise NameError("'snap_compare' is either not defined or not callable.")
except Exception as e:
    print(f"Error: {e}")
