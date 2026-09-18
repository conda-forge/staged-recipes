"""Check installed-package score semantics and preprocessing derivatives."""
import numpy as np
from sklearn.linear_model import LogisticRegression, Ridge
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler

import skgrad

X = np.array([[-2., 1.], [-1., -1.], [1., 2.], [2., -2.]])
classifier = LogisticRegression().fit(X, [0, 0, 1, 1])
values, jacobian = skgrad.value_and_jacobian(classifier, X)
np.testing.assert_allclose(values[:, 0], classifier.decision_function(X))
np.testing.assert_allclose(
    jacobian[:, 0, :], np.broadcast_to(classifier.coef_[0], X.shape)
)
np.testing.assert_allclose(skgrad.input_gradient(classifier, X), jacobian[:, 0, :])

pipeline = make_pipeline(StandardScaler(), Ridge()).fit(X, X @ [2., -3.])
expected_gradient = pipeline[-1].coef_ / pipeline[0].scale_
np.testing.assert_allclose(
    skgrad.input_gradient(pipeline, X), np.broadcast_to(expected_gradient, X.shape)
)
np.testing.assert_allclose(skgrad.model_output(pipeline, X)[:, 0], pipeline.predict(X))
print("skgrad score and pipeline gradient checks passed")
