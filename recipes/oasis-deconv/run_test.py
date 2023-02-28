import numpy.testing as npt
import numpy as np
from oasis.oasis_methods import oasisAR1, constrained_oasisAR1, oasisAR2, constrained_oasisAR2
from oasis.functions import gen_data, foopsi, constrained_foopsi, onnls, constrained_onnlsAR2


def AR1(constrained=False):
    g = .95
    sn = .3
    y, c, s = [a[0] for a in gen_data([g], sn, N=1)]
    result = constrained_oasisAR1(y, g, sn) if constrained else oasisAR1(y, g, lam=2.4)
    result_foopsi = constrained_foopsi(y, [g], sn) if constrained else foopsi(y, [g], lam=2.4)
    npt.assert_allclose(np.corrcoef(result[0], result_foopsi[0])[0, 1], 1)
    npt.assert_allclose(np.corrcoef(result[1], result_foopsi[1])[0, 1], 1)
    npt.assert_allclose(np.corrcoef(result[0], c)[0, 1], 1, .03)
    npt.assert_allclose(np.corrcoef(result[1], s)[0, 1], 1, .2)


def test_AR1():
    AR1()


def test_constrainedAR1():
    AR1(True)


def AR2(constrained=False):
    g = [1.7, -.712]
    sn = .3
    y, c, s = [a[0] for a in gen_data(g, sn, N=1, seed=3)]
    result = constrained_onnlsAR2(y, g, sn) if constrained else onnls(y, g, lam=25)
    result_foopsi = constrained_foopsi(y, g, sn) if constrained else foopsi(y, g, lam=25)
    npt.assert_allclose(np.corrcoef(result[0], result_foopsi[0])[0, 1], 1, 1e-3)
    npt.assert_allclose(np.corrcoef(result[1], result_foopsi[1])[0, 1], 1, 1e-2)
    npt.assert_allclose(np.corrcoef(result[0], c)[0, 1], 1, .03)
    npt.assert_allclose(np.corrcoef(result[1], s)[0, 1], 1, .2)
    result2 = constrained_oasisAR2(y, g[0], g[1], sn) if constrained \
        else oasisAR2(y, g[0], g[1], lam=25)
    npt.assert_allclose(np.corrcoef(result2[0], c)[0, 1], 1, .03)
    npt.assert_allclose(np.corrcoef(result2[1], s)[0, 1], 1, .2)


def test_AR2():
    AR2()


def test_constrainedAR2():
    AR2(True)
