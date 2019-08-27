try:
    # This is going to fail with an OSError complaining that the necessary
    # library isn't installed
    import ftd2xx
except OSError as e:
    pass
