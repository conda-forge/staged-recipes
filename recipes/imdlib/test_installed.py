"""Offline checks of the installed package, including bundled data and outputs."""
from importlib import metadata, resources
import unittest

import imdlib as imd
import numpy as np
import pandas as pd
from imdlib.extreme import _load_region_mask


class InstalledPackageTests(unittest.TestCase):
    def rain(self, years=1):
        dates = pd.date_range('1991-01-01', f'{1990 + years}-12-31')
        rng = np.random.default_rng(73)
        values = rng.gamma(2, 3, (len(dates), 2, 2))
        return imd.IMD(values, 'rain', str(dates[0].date()), str(dates[-1].date()),
                       len(dates), np.array([7.5, 7.75]), np.array([67.5, 67.75]),
                       land_mask=np.ones((2, 2), dtype=bool))

    def test_metadata(self):
        self.assertEqual(metadata.version('imdlib'), imd.__version__)

    def test_bundled_masks(self):
        for name, shape in [('region_mask_100.npy', (31, 31)),
                            ('region_mask_025.npy', (135, 129))]:
            path = resources.files('imdlib').joinpath('data', name)
            with path.open('rb') as stream:
                mask = np.load(stream, allow_pickle=False)
            self.assertEqual(mask.shape, shape)
            self.assertTrue(set(np.unique(mask)).issubset({-1, 0, 1, 2}))
        self.assertEqual(_load_region_mask().shape, (31, 31))

    def test_annual_index_and_export(self):
        rain = self.rain()
        rain.data[:] = 0
        rain.data[:5] = 70
        heavy = rain.copy().compute('d64', 'A', threshold=64.5)
        np.testing.assert_array_equal(heavy.data, np.full((1, 2, 2), 5.0))
        self.assertIn('d64', heavy.get_xarray().data_vars)
        self.assertEqual(heavy.spatial_mean().shape, (1, 1))
        dry = rain.copy().compute('cdd', 'A')
        np.testing.assert_array_equal(dry.data, np.full((1, 2, 2), 360.0))

    def test_climatology_anomaly_and_copy(self):
        rain = self.rain()
        rain.data[:] = 2
        copy = rain.copy()
        copy.data[0] = 10
        self.assertEqual(rain.data[0, 0, 0], 2)
        climate = rain.copy().climatology()
        self.assertEqual(climate.data.shape, (12, 2, 2))
        self.assertEqual(climate.get_xarray().sizes['time'], 12)
        anomaly = rain.copy().anomaly()
        np.testing.assert_allclose(anomaly.data, 0, atol=1e-10)

    def test_spi(self):
        result = self.rain(30).compute('spi', 'M', timescale=3)
        self.assertEqual(result.data.shape, (360, 2, 2))
        self.assertTrue(np.isnan(result.data[:2]).all())
        self.assertTrue(np.isfinite(result.data[2:]).all())
        self.assertIn('spi', result.get_xarray().data_vars)
        self.assertEqual(result.spatial_mean().shape, (360, 1))

    def temperature(self, cat):
        dates = pd.date_range('1991-01-01', '2000-12-31')
        values = np.full((len(dates), 31, 31), 30.0 if cat == 'tmax' else 15.0)
        values[:, 0, 0] = 99.9
        mask = _load_region_mask()
        return imd.IMD(values, cat, '1991-01-01', '2000-12-31', len(dates),
                       np.arange(7.5, 38.5), np.arange(67.5, 98.5), land_mask=mask >= 0)

    def test_heatwave_and_coldwave(self):
        for cat, method, extreme in [('tmax', 'heatwave', 50.0),
                                     ('tmin', 'coldwave', -10.0)]:
            obj = self.temperature(cat)
            cell = tuple(np.argwhere(_load_region_mask() == 0)[0])
            obj.data[(100,) + cell] = extreme
            result = getattr(obj, method)(norm_start=1991, norm_end=2000)
            self.assertEqual(result.data[(100,) + cell], 2)
            self.assertTrue(np.isnan(result.data[:, _load_region_mask() == -1]).all())
            self.assertIn(method, result.get_xarray().data_vars)

    def test_spei(self):
        rain = self.rain(30)
        dates = pd.date_range('1991-01-01', '2020-12-31')
        rain.data = np.random.default_rng(73).gamma(2, 3, (len(dates), 5, 5))
        rain.lat_array = np.arange(7.5, 8.51, 0.25)
        rain.lon_array = np.arange(67.5, 68.51, 0.25)
        rain.land_mask = np.ones((5, 5), dtype=bool)
        temperatures = {}
        for cat, value in [('tmax', 30.0), ('tmin', 15.0)]:
            temperatures[cat] = imd.IMD(np.full((len(dates), 2, 2), value), cat,
                '1991-01-01', '2020-12-31', len(dates),
                np.array([7.5, 8.5]), np.array([67.5, 68.5]),
                land_mask=np.ones((2, 2), dtype=bool))
            temperatures[cat].data[:, 0, 0] = 99.9
        result = rain.compute('spei', 'M', timescale=3, **temperatures)
        self.assertEqual(result.data.shape, (360, 5, 5))
        self.assertTrue(np.isnan(result.data[:2]).all())
        self.assertTrue(np.isfinite(result.data[2:]).any())
        self.assertIn('spei', result.get_xarray().data_vars)


if __name__ == '__main__':
    unittest.main(verbosity=2)
