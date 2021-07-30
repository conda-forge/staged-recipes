"""
Simple test case for fractopo conda build.
"""

import geopandas as gpd
from fractopo import Network

kb11_network = Network(
    name="KB11",
    trace_gdf=gpd.read_file(
        "https://raw.githubusercontent.com/nialov/"
        "fractopo/master/tests/sample_data/KB11/KB11_traces.geojson"
    ),
    area_gdf=gpd.read_file(
        "https://raw.githubusercontent.com/nialov/"
        "fractopo/master/tests/sample_data/KB11/KB11_area.geojson"
    ),
    truncate_traces=True,
    circular_target_area=False,
    determine_branches_nodes=True,
    snap_threshold=0.001,
)

kb11_network.parameters
