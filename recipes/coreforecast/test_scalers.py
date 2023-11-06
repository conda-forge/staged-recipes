import numpy as np
import pytest

from coreforecast.grouped_array import GroupedArray
from coreforecast.scalers import (
    LocalMinMaxScaler,
    LocalRobustScaler,
    LocalStandardScaler,
)


@pytest.fixture
def indptr():
    lengths = np.random.randint(low=100, high=200, size=10)
    return np.append(0, lengths.cumsum()).astype(np.int32)


@pytest.fixture
def data(indptr):
    return np.random.randn(indptr[-1])


def std_scaler_stats(x):
    return np.nanmean(x), np.nanstd(x)


def minmax_scaler_stats(x):
    min, max = np.nanmin(x), np.nanmax(x)
    return min, max - min


def robust_scaler_iqr_stats(x):
    q25, median, q75 = np.nanquantile(x, [0.25, 0.5, 0.75])
    return median, q75 - q25


def robust_scaler_mad_stats(x):
    median = np.nanmedian(x)
    mad = np.nanmedian(np.abs(x - median))
    return median, mad


def scaler_transform(x, stats):
    offset, scale = stats
    return (x - offset) / scale


def scaler_inverse_transform(x, stats):
    offset, scale = stats
    return x * scale + offset


scaler2fns = {
    "standard": std_scaler_stats,
    "minmax": minmax_scaler_stats,
    "robust-iqr": robust_scaler_iqr_stats,
    "robust-mad": robust_scaler_mad_stats,
}
scaler2core = {
    "standard": LocalStandardScaler(),
    "minmax": LocalMinMaxScaler(),
    "robust-iqr": LocalRobustScaler("iqr"),
    "robust-mad": LocalRobustScaler("mad"),
}
scalers = list(scaler2fns.keys())
dtypes = [np.float32, np.float64]


@pytest.mark.parametrize("scaler_name", scalers)
@pytest.mark.parametrize("dtype", dtypes)
def test_correctness(data, indptr, scaler_name, dtype):
    # introduce some nans at the starts of groups
    data = data.astype(dtype, copy=True)
    sizes = np.diff(indptr)
    gt10 = np.where(sizes > 10)[0]
    assert gt10.size > 5
    for i in range(5):
        group = gt10[i]
        data[indptr[group] : indptr[group] + 10] = np.nan
    ga = GroupedArray(data, indptr, num_threads=2)

    # setup scaler
    scaler = scaler2core[scaler_name]
    stats_fn = scaler2fns[scaler_name]
    scaler.fit(ga)

    # stats
    expected_stats = np.hstack([stats_fn(grp) for grp in ga]).reshape(-1, 2)
    np.testing.assert_allclose(scaler.stats_, expected_stats, atol=1e-6, rtol=1e-6)

    # transform
    transformed = scaler.transform(ga)
    expected_transformed = np.hstack(
        [scaler_transform(grp, scaler.stats_[i]) for i, grp in enumerate(ga)]
    )
    np.testing.assert_allclose(transformed, expected_transformed, atol=1e-6, rtol=1e-6)

    # inverse transform
    transformed_ga = GroupedArray(transformed, ga.indptr)
    restored = scaler.inverse_transform(transformed_ga)
    expected_restored = np.hstack(
        [
            scaler_inverse_transform(grp, scaler.stats_[i])
            for i, grp in enumerate(transformed_ga)
        ]
    )
    np.testing.assert_allclose(restored, expected_restored, atol=1e-6, rtol=1e-6)
