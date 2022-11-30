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
    parser.add_argument(
        "-o", "--ofile", help="The output file name", default="results.csv.gz"
    )
    parser.add_argument(
        "--n_cpus", help="The number of processors", type=int, default=4
    )
    args = parser.parse_args()

    c = args.chunksize
    p0 = np.array([0.0, 0.0])
    stp = np.array([500.0, 0.0])
    ofile = Path(args.ofile)
    tPfile = "../NREL-5MW-D126-H90-P.csv"
    tCtfile = "../NREL-5MW-D126-H90-Ct.csv"
    sfile = "../states.csv.gz"
    lfile = "../test_farm.csv"

    # init flappy:
    fl.init_flappy(n_cpus=args.n_cpus)

    # load model book:
    mbook = fl.ModelBook()
    mbook.turbine_models[f"ws_P"] = fl.models.Ws2P(P_curve_file=tPfile)
    mbook.turbine_models[f"ws_Ct"] = fl.models.Ws2Ct(ct_curve_file=tCtfile)

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
        rotor_model="centre",
        wake_models=["Jensen007"],
        turbine_models=["ws_P", "ws_Ct"],
    )

    # create states:
    states = fl.input.AFSStatesTable(
        data_file=sfile,
        col_wd="wd",
        col_ws="ws",
        col_ti="ti",
        col_weight="weight",
        air_density=1.225,
        max_chunk_size=args.chunksize,
    )
    states.initialize()

    time0 = time.time()

    # run calculation:
    results = farm.calculate(mbook, states, wake_superp=["wind_linear"])

    time1 = time.time()
    print("\nCalc time =", time1 - time0, "\n")

    df = results.state_turbine_results[[FV.WD, FV.AMB_WS, FV.WS, FV.AMB_P, FV.P]]

    print()
    print("TRESULTS\n")
    print(df)

    print("\nWriting file", ofile)
    df.to_csv(ofile)

    # close flappy:
    fl.shutdown_flappy()
