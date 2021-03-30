# Placekey-py

[![PyPI version](https://badge.fury.io/py/placekey.svg)](https://badge.fury.io/py/placekey)
[![PyPI downloads](https://img.shields.io/pypi/dm/placekey)](https://pypistats.org/packages/placekey)
[![version](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

A Python library for working with [Placekeys](https://placekey.io). Documentation for this package can be found [here](https://placekey.github.io/placekey-py/), and documentation for the Placekey service API can be found [here](https://docs.placekey.io/). The Plackey design specification is available [here](https://docs.placekey.io/Placekey_Technical_White_Paper.pdf). The details in Placekey encoding is [here](https://docs.placekey.io/Placekey_Encoding_Specification%20White_Paper.pdf). We welcome your feedback. 

## Installation

This package can be installed from [PyPI](https://pypi.org/project/placekey/) by

```shell script
pip install placekey
```

MacOS Big Sur may need to run `brew install geos` if the installation of the `shapely` dependency fails.

## Usage

The basic functionality of the Placekey library is conversion between Placekeys and latitude-longitude coordinates.

```python
>>> import placekey as pk
>>> lat, long = 0.0, 0.0
>>> pk.geo_to_placekey(lat, long)
'@dvt-smp-tvz'
```

```python
>>> pk.placekey_to_geo('@dvt-smp-tvz')
(0.00018033323813810344, -0.00018985758738881587)
```

The library also allows for conversion between Placekeys and [H3 indices](https://github.com/uber/h3-py).

```python
>>> pk.placekey_to_h3('@dvt-smp-tvz')
'8a754e64992ffff'
```

```python
>>> pk.h3_to_placekey('8a754e64992ffff')
'@dvt-smp-tvz'
```

The distance in meters between two Placekeys can be found with the following function.

```python
>>> pk.placekey_distance('@dvt-smp-tvz', '@5vg-7gq-tjv')
12795124.895573696
```

An upper bound on the maximal distance in meters between two Placekeys based on the length of their shared prefix is provided by `placekey.get_prefix_distance_dict()`.

```python
>>> pk.get_prefix_distance_dict()
{0: 20040000.0,
 1: 20040000.0,
 2: 2777000.0,
 3: 1065000.0,
 4: 152400.0,
 5: 21770.0,
 6: 8227.0,
 7: 1176.0,
 8: 444.3,
 9: 63.47}
```

Placekeys found in a data set can be partially validated by

```python
>>> pk.placekey_format_is_valid('222-227@dvt-smp-tvz')
True
```

```python
>>> pk.placekey_format_is_valid('@123-456-789')
False
```

## API Client

This package also includes a client for the Placekey API. The methods in the client are automatically rate limited.

```python
>>> from placekey.api import PlacekeyAPI
>>> placekey_api_key = "..."
>>> pk_api = PlacekeyAPI(placekey_api_key)
```

The `PlacekeyAPI.lookup_placekey` method can be used to lookup the Placekey for a single place.

```python
>>> pk_api.lookup_placekey(latitude=37.7371, longitude=-122.44283)
{'query_id': '0', 'placekey': '@5vg-82n-kzz'}
```

```python
>>> place = {
>>>   "street_address": "598 Portola Dr",
>>>   "city": "San Francisco",
>>>   "region": "CA",
>>>   "postal_code": "94131",
>>>   "iso_country_code": "US"
>>> }
>>> pk_api.lookup_placekey(**place, strict_address_match=True)
{'query_id': '0', 'placekey': '227@5vg-82n-pgk'}
```

The `PlacekeyAPI.lookup_placekeys` method can be used to lookup Placekeys for multiple places.

```python
>>> places = [
>>>   {
>>>     "street_address": "1543 Mission Street, Floor 3",
>>>     "city": "San Francisco",
>>>     "region": "CA",
>>>     "postal_code": "94105",
>>>     "iso_country_code": "US"
>>>   },
>>>   {
>>>     "query_id": "thisqueryidaloneiscustom",
>>>     "location_name": "Twin Peaks Petroleum",
>>>     "street_address": "598 Portola Dr",
>>>     "city": "San Francisco",
>>>     "region": "CA",
>>>     "postal_code": "94131",
>>>     "iso_country_code": "US"
>>>   },
>>>   {
>>>     "latitude": 37.7371,
>>>     "longitude": -122.44283
>>>   }
>>> ]
>>> pk_api.lookup_placekeys(places)
[{'query_id': 'place_0', 'placekey': '226@5vg-7gq-5mk'},
 {'query_id': 'thisqueryidaloneiscustom', 'placekey': '227-222@5vg-82n-pgk'},
 {'query_id': 'place_2', 'placekey': '@5vg-82n-kzz'}]
```

Full details on how to query the API and how to get an API key can be found [here](https://docs.placekey.io/).

## Notebooks

Jupyter notebooks demonstrating various Placekey functionality are contained in the [placekey-notebooks](https://github.com/Placekey/placekey-notebooks) repository.

## Support

This package runs on Python 3.
