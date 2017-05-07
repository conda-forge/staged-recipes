import eli5
from sklearn import datasets, svm

iris = datasets.load_iris()
digits = datasets.load_digits()

clf = svm.LinearSVC(C=100.)
clf.fit(digits.data[:-1], digits.target[:-1])

res = eli5.explain_weights(clf)
print(eli5.format_as_text(res))
