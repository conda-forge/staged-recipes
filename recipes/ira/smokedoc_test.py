#!/usr/bin/env python3
import ira_mod
import numpy as np
import pytest


# A "fixture" to set up the IRA object for our tests
@pytest.fixture
def ira_instance():
    """Provides an instantiated ira_mod.IRA() object"""
    try:
        ira = ira_mod.IRA()
        print("\nira_mod.IRA() instantiated successfully.")
        return ira
    except Exception as e:
        pytest.fail(f"Failed to instantiate ira_mod.IRA(): {e}")


def test_cshda_permutation(ira_instance):
    """
    Runs the CShDA test based on the documentation.
    """
    # Use the ira_instance provided by the fixture
    ira = ira_instance

    # Data from the IRA documentation
    nat1 = 10
    typ1 = np.ones(nat1, dtype=int)
    coords1 = np.array(
        [
            [-0.49580341, 0.9708181, 0.37341428],
            [-1.05611656, -0.4724503, -0.37449784],
            [-0.63509644, -0.66670776, 0.66219897],
            [-0.83642178, 0.59155936, -0.64507703],
            [0.59636159, 0.80558701, 0.23843962],
            [0.25975284, 0.71540297, -0.78971024],
            [-0.09743308, -1.03812804, -0.31233049],
            [0.09254502, 0.20016738, 1.03021068],
            [-0.18424967, -0.24756757, -1.07217522],
            [0.46705991, -0.73516435, 0.56288325],
        ]
    )
    nat2 = nat1
    typ2 = typ1
    coords2 = np.array(
        [
            [-0.50010644, 0.96625779, 0.37944221],
            [-1.05658467, -0.46953529, -0.37456054],
            [-0.63373056, -0.66591152, 0.66168751],
            [-0.83286912, 0.5942803, -0.64527646],
            [0.59310547, 0.80745772, 0.23711422],
            [0.2636203, 0.7126221, -0.79370807],
            [-0.09940056, -1.03859144, -0.31064337],
            [0.09208454, 0.19985156, 1.03003579],
            [-0.18468815, -0.24935304, -1.07257697],
            [0.4691676, -0.73356138, 0.56184166],
        ]
    )

    # Add permutation
    permutation_indices = [2, 4, 3, 5, 9, 8, 6, 7, 0, 1]
    coords2_permuted = coords2[permutation_indices]

    # Call cshda
    print("Calling ira.cshda...")
    perm, dist = ira.cshda(nat1, typ1, coords1, nat2, typ2, coords2_permuted)

    print(f"Received permutation: {perm}")
    print(f"Received distances: {dist}")

    # --- Assertions ---
    # 1. Check that the permutation array is valid
    assert len(perm) == nat1, "Permutation array has incorrect length"
    assert set(perm) == set(range(nat1)), "Permutation array is not a valid permutation"
    print("Permutation array is valid.")

    # 2. Check that the distances are small (as coords1 and coords2 are close)
    assert np.all(dist < 0.01), "Distances are not small"
    print("Distances are all small, as expected.")

    # 3. Check that applying the permutation correctly re-orders coords2
    coords2_reordered = coords2_permuted[perm]
    diff = coords1 - coords2_reordered
    manual_dists = np.linalg.norm(diff, axis=1)

    assert np.allclose(dist, manual_dists), (
        "Calculated distances (dist) do not match manual check"
    )
    print("Reported distances match manually calculated distances after permutation.")
    print("--- Test Passed! ---")
