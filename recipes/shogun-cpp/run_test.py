# run a bunch of the shogun examples

import os
import subprocess
import sys


to_run = [
    'basic_minimal',
    'classifier_minimal_svm',
    'classifier_svmlight_string_features_precomputed_kernel',
    'clustering_kmeans',
    'features_subset_labels',
    'library_mldatahdf5',
    'mathematics_confidence_intervals',
    'modelselection_parameter_tree',
    'neuralnets_convolutional',
    'regression_gaussian_process_fitc',
    'so_multiclass_BMRM',
    'streaming_from_dense',
    'transfer_multitasklogisticregression',
]

d = os.path.join(
    os.environ['LIBRARY_PREFIX' if os.name == 'nt' else 'PREFIX'],
    'share', 'shogun', 'examples', 'libshogun')

for example in to_run:
    proc = subprocess.Popen(
        [os.path.join(d, example)],
        stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    stdout, _ = proc.communicate()
    if proc.returncode != 0:
        print("ERROR: {} returned {}".format(example, proc.returncode))
        print("Output was:")
        print(stdout)
        sys.exit(1)
