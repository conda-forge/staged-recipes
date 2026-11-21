"""Run Zope's upstream test modules with plain unittest.

Each module is loaded through its test_suite() when it has one, the way
zope.testrunner does. zope.testrunner itself is not on conda-forge, so the
modules below are skipped: they rely on its test layers to set up shared
fixtures and fail without them.
"""
import importlib
import pkgutil
import sys
import unittest

NEEDS_LAYERS = {
    "OFS.tests.testCopySupportEvents",
    "Products.Five.browser.tests.test_i18n",
    "Products.Five.tests.test_i18n",
    "Products.PageTemplates.tests.testTranslation",
    "Products.PageTemplates.tests.test_engine",
    "Testing.ZopeTestCase.tests",
    "Testing.ZopeTestCase.zopedoctest.tests",
    "webdav.tests.testCopySupportEvents",
    "webdav.tests.testCopySupportHooks",
}
PACKAGES = ["App", "OFS", "Products.Five", "Products.PageTemplates", "Products.SiteAccess",
            "Testing", "webdav", "zmi", "Zope2", "ZPublisher", "ZTUtils"]

names = set()
for top in PACKAGES:
    pkg = importlib.import_module(top)
    for info in pkgutil.walk_packages(pkg.__path__, top + "."):
        last = info.name.rsplit(".", 1)[1]
        if ".tests" in info.name and (last.startswith("test") or (last == "tests" and not info.ispkg)):
            names.add(info.name)

loader = unittest.defaultTestLoader
suite = unittest.TestSuite()
for name in sorted(names - NEEDS_LAYERS):
    module = importlib.import_module(name)
    suite.addTest(getattr(module, "test_suite", lambda: loader.loadTestsFromModule(module))())

result = unittest.TextTestRunner(verbosity=2).run(suite)
sys.exit(not result.wasSuccessful() or result.testsRun == 0)
