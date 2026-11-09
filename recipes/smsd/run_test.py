# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2018-2026 BioInception PVT LTD
# Algorithm Copyright (c) 2009-2026 Syed Asad Rahman
# See the NOTICE file for attribution, trademark, and algorithm IP terms.
"""Conda package smoke checks of chemistry, arrays and packed corpus I/O."""

from importlib.metadata import version
from pathlib import Path
from tempfile import TemporaryDirectory

import smsd
from smsd.adapters import fingerprints_numpy
from smsd.clustering import butina, maxmin
from smsd.corpus import FingerprintCorpus

assert smsd.__version__ == version("smsd")
backend = smsd.gpu_device_info()
assert "OpenMP" in backend and "no OpenMP" not in backend, backend
options = smsd.MCS.Options()
options.timeout_ms = 1000
options.node_limit = 100000
common = smsd.MCS.find("CCO").with_options(options).match_with_smarts("CCN")
assert common.result.optimal and common.result.best.atom_count == 2
assert smsd.Substructure.smarts(common.smarts).match("CCC").found

molecules = ["CCO", "CCN", "c1ccccc1"]
features = fingerprints_numpy(molecules, kind="ecfp", fp_size=128)
assert features.shape == (3, 128) and str(features.dtype) == "uint8"

with TemporaryDirectory() as directory:
    with FingerprintCorpus.from_smiles(Path(directory) / "molecules.fp", molecules,
                                       kind="ecfp", fp_size=128, chunk_size=2,
                                       num_threads=1) as corpus:
        assert len(corpus) == 3
        assert len(list(corpus.top_k_pairs(1, chunk_size=2))) == 3
        assert sorted(index for cluster in butina(corpus, chunk_size=2)
                      for index in cluster) == [0, 1, 2]
        assert len(set(maxmin(corpus, 2, chunk_size=2))) == 2
