import numpy as np
import time
import argparse
from pathlib import Path

import flappy as fl
from flappy.config.variables import variables as FV

if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-o", "--ofile", help="The output file name", default="results.csv.gz"
    )
    parser.add_argument(
        "--n_cpus", help="The number of processors", type=int, default=1
    )
    args = parser.parse_args()

    n_s = 30
    n_t = 52
    wd = 270.0
    ti = 0.08
    rotor = "centre"
    c = 100
    p0 = np.array([0.0, 0.0])
    stp = np.array([601.0, 15.0])
    tfile = "../NREL-5MW-D126-H90.csv"
    ofile = Path(args.ofile)

    # init flappy:
    fl.init_flappy(n_cpus=args.n_cpus)

    # load model book:
    mbook = fl.ModelBook(ct_power_curve_file=tfile)

    # create wind farm:
    farm = fl.WindFarm()
    fl.input.add_turbine_row(
        farm,
        rotor_diameter=126.0,
        hub_height=90.0,
        rotor_model=rotor,
        wake_models=["Bastankhah", "CrespoHernandez"],
        turbine_models=["ct_P_curves"],
        base_point=p0,
        step_vector=stp,
        steps=n_t - 1,
    )

    # create states:
    ws0 = 6.0
    ws1 = 16.0
    states = fl.input.AFSScan(
        ws_min=ws0,
        ws_delta=(ws1 - ws0) / (n_s - 1),
        ws_n_bins=n_s,
        func_pdf_ws=None,
        wd_min=wd,
        wd_delta=1.0,
        wd_n_bins=1,
        func_pdf_wd=None,
        ti_min=ti,
        ti_delta=0.01,
        ti_n_bins=1,
        func_pdf_ti=None,
        rho_min=1.225,
        rho_delta=0.001,
        rho_n_bins=1,
        func_pdf_rho=None,
        max_chunk_size=c,
    )
    states.initialize()

    time0 = time.time()

    # run calculation:
    results = farm.calculate(mbook, states, wake_superp=["wind_quadratic", "ti_max"])

    time1 = time.time()
    print("\nCalc time =", time1 - time0, "\n")

    df = results.state_turbine_results[
        [FV.WD, FV.AMB_WS, FV.WS, FV.AMB_TI, FV.TI, FV.AMB_CT, FV.CT]
    ]

    print(results.turbine_results[[FV.X, FV.Y]])

    print()
    print("TRESULTS\n")
    print(df)

    print("\nWriting file", ofile)
    df.to_csv(ofile)

    # close flappy:
    fl.shutdown_flappy()
