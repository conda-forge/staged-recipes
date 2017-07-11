"""
A simple test for LightGBM based on scikit-learn.

Tests are not shipped with the source distribution so we include a simple
functional test here that is adapted from:

    https://github.com/Microsoft/LightGBM/blob/master/tests/python_package_test/test_sklearn.py

"""

import unittest

import lightgbm as lgb

from sklearn.datasets import load_boston, load_breast_cancer
from sklearn.metrics import log_loss, mean_squared_error
from sklearn.model_selection import train_test_split


class TestSklearn(unittest.TestCase):
    def test_binary(self):
        X, y = load_breast_cancer(True)
        X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.1, random_state=42)
        gbm = lgb.LGBMClassifier(n_estimators=50, silent=True)
        gbm.fit(X_train, y_train, eval_set=[(X_test, y_test)], early_stopping_rounds=5, verbose=False)
        ret = log_loss(y_test, gbm.predict_proba(X_test))

        self.assertLess(ret, 0.15)
        self.assertAlmostEqual(ret, gbm.evals_result['valid_0']['binary_logloss'][gbm.best_iteration - 1], places=5)

    def test_regression(self):
        X, y = load_boston(True)
        X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.1, random_state=42)
        gbm = lgb.LGBMRegressor(n_estimators=50, silent=True)
        gbm.fit(X_train, y_train, eval_set=[(X_test, y_test)], early_stopping_rounds=5, verbose=False)
        ret = mean_squared_error(y_test, gbm.predict(X_test))

        self.assertLess(ret, 16)
        self.assertAlmostEqual(ret, gbm.evals_result['valid_0']['l2'][gbm.best_iteration - 1], places=5)


if __name__ == '__main__':
    unittest.main()


