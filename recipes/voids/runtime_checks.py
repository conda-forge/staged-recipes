import re
import subprocess
import sys

import numpy as np


def check_package_metadata() -> None:
    result = subprocess.run(
        [sys.executable, "-m", "pip", "check"],
        capture_output=True,
        text=True,
    )
    print(result.stdout, end="")
    print(result.stderr, end="", file=sys.stderr)

    lines = [
        line.strip()
        for line in (result.stdout + "\n" + result.stderr).splitlines()
        if line.strip()
    ]
    allowed = [
        line
        for line in lines
        if re.fullmatch(r"pypardiso \S+ requires mkl, which is not installed\.", line)
    ]
    unexpected = [
        line
        for line in lines
        if line != "No broken requirements found." and line not in allowed
    ]

    assert not unexpected, "\n".join(unexpected)
    assert result.returncode == int(bool(allowed)), (result.returncode, allowed)


def check_fem_runtime() -> None:
    from voids.fem.singlephase import (
        FEMMapProblem,
        FEniCSSolverOptions,
        solve_brinkman_usfem,
    )
    from voids.image.porosity import PermeabilityMap, PorosityMap

    problem = FEMMapProblem(
        PermeabilityMap(np.full((2, 2), 2.0), cell_size=1.0),
        PorosityMap(np.ones((2, 2)), cell_size=1.0),
        viscosity=1.0,
    )
    result = solve_brinkman_usfem(
        problem,
        flow_axis="x",
        options=FEniCSSolverOptions.superlu_direct(),
    )

    assert np.isclose(result.permeability, 2.0, rtol=5e-4), result.permeability


def check_pypardiso_runtime() -> None:
    from pypardiso import spsolve
    from scipy.sparse import csc_matrix

    matrix = csc_matrix([[4.0, 1.0], [1.0, 3.0]])
    rhs = np.array([1.0, 2.0])
    solution = spsolve(matrix, rhs)

    assert np.allclose(matrix @ solution, rhs), solution


def main() -> None:
    check_package_metadata()

    if sys.platform != "win32":
        check_fem_runtime()

    if sys.platform.startswith("linux") or sys.platform == "win32":
        check_pypardiso_runtime()


if __name__ == "__main__":
    main()
