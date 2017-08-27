import pip


def install(package):
    pip.main(['install', package])


# Example
if __name__ == '__main__':
    install('pyside')
    import Qt

