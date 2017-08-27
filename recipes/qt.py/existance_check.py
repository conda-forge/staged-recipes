import site
import sys
import os


def existance_check():
    """Returns True if Qt.py is found, else returns False"""

    found = False
    site_package_locations = site.getsitepackages()
    for location in site_package_locations:
        if os.path.exists(os.path.join(location, 'Qt.py')):
            found = True
        print(
            'Qt.py was not found in any of the locations:' +
            ', '.join(site_package_locations)
            )
    return found


# Example
if __name__ == '__main__':
    if existance_check():
        sys.exit(0)
    else:
        sys.exit(1)
