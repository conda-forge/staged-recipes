import pandas as pd
from pathlib import Path
import inspect

import foxes
import foxes.variables as FV


thisdir = Path(inspect.getfile(inspect.currentframe())).parent


def test():

    c = 2000
    cfile = thisdir / "flappy" / "results.csv.gz"
    tfile = thisdir / "NREL-5MW-D126-H90.csv"
    sfile = thisdir / "states.csv.gz"
    lfile = thisdir / "test_farm.csv"

    ck = {FV.STATE: c}

    mbook = foxes.models.ModelBook()
    ttype = foxes.models.turbine_types.PCtFile(
        data_source=tfile, var_ws_ct=FV.REWS, var_ws_P=FV.REWS
    )
    mbook.turbine_types[ttype.name] = ttype

    states = foxes.input.states.StatesTable(
        data_source=sfile,
        output_vars=[FV.WS, FV.WD, FV.TI, FV.RHO, FV.MOL],
        var2col={FV.WS: "ws", FV.WD: "wd", FV.TI: "ti", FV.MOL: "mol"},
        fixed_vars={FV.RHO: 1.225, FV.Z0: 0.05, FV.H: 100.0},
        profiles={FV.WS: "ABLLogWsProfile"},
    )

    farm = foxes.WindFarm()
    foxes.input.farm_layout.add_from_file(
        farm,
        lfile,
        col_x="x",
        col_y="y",
        col_H="H",
        turbine_models=[ttype.name],
        verbosity=0,
    )

    algo = foxes.algorithms.Downwind(
        mbook,
        farm,
        states=states,
        rotor_model="centre",
        wake_models=["Jensen_linear_k007"],
        wake_frame="rotor_wd",
        partial_wakes_model="rotor_points",
        chunks=ck,
        verbosity=0,
    )

    data = algo.calc_farm()

    df = data.to_dataframe()[[FV.AMB_WD, FV.WD, FV.AMB_REWS, FV.REWS, FV.AMB_P, FV.P]]

    print()
    print("TRESULTS\n")
    print(df)

    print("\nReading file", cfile)
    fdata = pd.read_csv(cfile)
    print(fdata)

    print("\nVERIFYING\n")
    df[FV.WS] = df["REWS"]
    df[FV.AMB_WS] = df["AMB_REWS"]

    delta = df.reset_index() - fdata
    print(delta)
    print(delta.max())
    chk = delta[[FV.AMB_WS, FV.AMB_P, FV.WS, FV.P]].abs()
    print(chk.max())

    assert (chk[FV.AMB_WS] < 1e-5).all()
    assert (chk[FV.AMB_P] < 1e-3).all()
    assert (chk[FV.WS] < 1e-5).all()
    assert (chk[FV.P] < 1e-3).all()
