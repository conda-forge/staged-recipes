import numpy as np
import pandas as pd
import time
import argparse
from pathlib import Path

import flappy as fl
from flappy.config.variables import variables as FV

if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-c", "--chunksize", help="The maximal chunk size", type=int, default=500
    )
    parser.add_argument("-o", "--opath", help="The output file path", default=".")
    parser.add_argument(
        "--n_cpus", help="The number of processors", type=int, default=4
    )
    args = parser.parse_args()

    c = args.chunksize
    p0 = np.array([0.0, 0.0])
    stp = np.array([500.0, 0.0])
    opath = Path(args.opath)
    tfile = "../NREL-5MW-D126-H90.csv"
    sfile = "../states.csv.gz"
    lfile = "../test_farm.csv"
    cases = [
        (["Bastankhah_rotor"], ["wind_linear"], "centre"),
        (["Bastankhah_rotor"], ["wind_linear"], "grid4"),
        (["Bastankhah_rotor"], ["wind_linear"], "grid16"),
        (["Bastankhah_rotor"], ["wind_linear"], "grid64"),
    ]

    # init flappy:
    fl.init_flappy(n_cpus=args.n_cpus)

    for i, (wakes, superp, rotor) in enumerate(cases):

        print(f"\nCase {(wakes, superp, rotor)}")

        # load model book:
        mbook = fl.ModelBook(ct_power_curve_file=tfile)

        # create wind farm:
        farm = fl.WindFarm()
        fl.input.add_turbines_from_csv(
            farm,
            lfile,
            col_index="index",
            col_x="x",
            col_y="y",
            rotor_diameter=126.0,
            hub_height=90.0,
            rotor_model=rotor,
            wake_models=wakes,
            turbine_models=["ct_P_curves"],
            output_level=0,
        )

        # create states:
        states = fl.input.AFSStatesTable(
            data_file=sfile,
            col_wd="wd",
            col_ws_ref="ws",
            col_ti="ti",
            col_weight="weight",
            air_density=1.225,
            z0=0.1,
            h_ref=100.0,
            max_chunk_size=args.chunksize,
            output_level=0,
        )
        states.initialize()

        # run calculation:
        results = farm.calculate(mbook, states, wake_superp=superp, output_level=0)

        df = results.state_turbine_results[[FV.WD, FV.AMB_WS, FV.WS, FV.AMB_P, FV.P]]

        ofile = opath / f"results_{i}.csv.gz"
        print(f"Writing file {ofile}")
        df.to_csv(ofile)

    # close flappy:
    fl.shutdown_flappy()
