"""Package test: a 1D lamellar SCFT solved on the MKL backend, and on CUDA when
POLYMERFTS_TEST_CUDA=1 is set (CI machines have no GPU)."""
import os

os.environ.setdefault("OMP_NUM_THREADS", "1")

import numpy as np
import polymerfts

platforms = polymerfts.PlatformSelector.avail_platforms()
print("platforms:", platforms)
assert "cpu-mkl" in platforms, platforms


def solve(platform):
    params = {
        "platform": platform,
        "nx": [32],
        "lx": [1.5],
        "relax_cell": False,
        "chain_model": "continuous",
        "ds": 1 / 50,
        "segment_lengths": {"A": 1.0, "B": 1.0},
        "chi_n": {"A,B": 15.0},
        "polymers": [{"volume_fraction": 1.0,
                      "blocks": [{"type": "A", "length": 0.5}, {"type": "B", "length": 0.5}]}],
        "optimizer": {"name": "am", "max_hist": 20, "start_error": 1e-2, "mix_min": 0.1, "mix_init": 0.1},
        "max_iter": 2000,
        "tolerance": 1e-9,
    }
    x = np.arange(32) / 32
    result = polymerfts.SCFT(params=params).run(
        initial_fields={"A": np.cos(2 * np.pi * x), "B": -np.cos(2 * np.pi * x)}, return_result=True)
    total = np.mean(result.phi["A"] + result.phi["B"])
    print(f"{platform}: converged={result.converged} F={result.free_energy:.12f} "
          f"error={result.error_level:.2e} mean(phi_A+phi_B)={total:.12f}")
    assert result.converged
    assert abs(total - 1.0) < 1e-10
    assert np.isfinite(result.free_energy) and result.free_energy < 0
    return result.free_energy


f_cpu = solve("cpu-mkl")
if os.environ.get("POLYMERFTS_TEST_CUDA") == "1":
    assert "cuda" in platforms, platforms
    f_gpu = solve("cuda")
    assert abs(f_gpu - f_cpu) < 1e-9, (f_cpu, f_gpu)
print("OK")
