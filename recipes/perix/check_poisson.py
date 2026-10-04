#!/usr/bin/env python3

import pathlib
import sys
import xml.etree.ElementTree as ET


def values(element):
    return [float(value) for value in (element.text or "").split()]


def main():
    if len(sys.argv) != 3:
        raise SystemExit("usage: check_poisson.py LOG PD_RESULTS_VTU")

    log = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8")
    required_messages = (
        "assembly: openmp",
        "backend=Pardiso",
        "Static solve is done",
    )
    for message in required_messages:
        if message not in log:
            raise RuntimeError(f"missing runtime evidence: {message}")
    if "boundary-ghost DoF rows carry no boundary condition" in log:
        raise RuntimeError("the package test left a boundary-ghost row unconstrained")

    root = ET.parse(sys.argv[2]).getroot()
    point_values = root.find(".//PointData/DataArray[@Name='u']")
    point_coordinates = root.find(".//Points/DataArray")
    if point_values is None or point_coordinates is None:
        raise RuntimeError("the PD result does not contain u values and coordinates")

    solution = values(point_values)
    coordinates = values(point_coordinates)
    if len(coordinates) != 3 * len(solution):
        raise RuntimeError("the VTU point and solution counts are inconsistent")

    max_error = max(
        abs(value - coordinates[3 * point])
        for point, value in enumerate(solution)
    )
    print(f"max |u-x| = {max_error:.3e}")
    if max_error > 1.0e-10:
        raise RuntimeError("the packaged PARDISO solve failed the u=x oracle")


if __name__ == "__main__":
    main()
