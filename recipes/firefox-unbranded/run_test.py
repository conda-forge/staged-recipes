""" Test whether firefox is viable with geckodriver and selenium
"""
import sys
import os
import subprocess
from selenium import webdriver
from selenium.webdriver.firefox.options import Options

# can't always test on linux due to gtk3
# - https://github.com/conda-forge/staged-recipes/issues/9314
IS_LINUX = sys.platform.startswith("linux")

if sys.platform.startswith("win32"):
    FIREFOX_BINARY = os.path.join(os.environ["LIBRARY_BIN"], "firefox.exe")
    EXECUTABLE_PATH = os.path.join(os.environ["SCRIPTS"], "geckodriver.exe")
else:
    FIREFOX_BINARY = os.path.join(sys.prefix, "bin", "firefox")
    EXECUTABLE_PATH = os.path.join(sys.prefix, "bin", "geckodriver")


if __name__ == "__main__":
    print("checking firefox binary at {}...".format(FIREFOX_BINARY))
    assert os.path.exists(FIREFOX_BINARY), "couldn't find binary"
    print("... ok")

    print("checking binary version...")
    try:
        version = subprocess.check_output([FIREFOX_BINARY, "--version"]).decode("utf-8")
        assert os.environ["PKG_VERSION"] in version
        print("... ok")
    except subprocess.CalledProcessError:
        print("... failed to check version")
        if IS_LINUX:
            print("... version check failure ignored on linux due to gtk3")
        else:
            sys.exit(1)

    print("testing about:license with selenium...")
    driver = None
    try:
        options = Options()
        options.headless = True
        driver = webdriver.Firefox(options=options,
                                   firefox_binary=FIREFOX_BINARY,
                                   executable_path=EXECUTABLE_PATH)
        driver.get("about:license")

        assert "Mozilla Public License 2.0" in driver.page_source, \
            "couldn't even load the license page"
        print("... ok")
        driver.quit()
    except:
        if driver:
            driver.quit()
        print("... failed to load license page")
        if IS_LINUX:
            print("... about:license check ignored on linux, due to gtk3")
        else:
            sys.exit(1)
