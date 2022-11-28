from pathlib import Path
import inspect
from dask.diagnostics import ProgressBar

import foxes
import foxes.variables as FV


thisdir = Path(inspect.getfile(inspect.currentframe())).parent


def test():

    c = 180
    tfile = thisdir / "NREL-5MW-D126-H90.csv"
    sfile = thisdir / "states.csv.gz"
    lfile = thisdir / "test_farm.csv"
    cases = [
        ("grid100", "rotor_points", None),
        ("grid4", "rotor_points", 0.15),
        ("grid9", "rotor_points", 0.06),
        ("centre", "axiwake5", 0.04),
        ("centre", "axiwake10", 0.038),
        ("grid9", "distsliced", 0.06),
        ("centre", "distsliced9", 0.06),
        ("centre", "distsliced16", 0.04),
        ("centre", "distsliced36", 0.016),
        ("centre", "grid9", 0.06),
        ("centre", "grid16", 0.04),
        ("centre", "grid36", 0.016),
    ]

    ck = {FV.STATE: c}

    base_results = None
    for rotor, pwake, lim in cases:

        print(f"\nENTERING CASE {(rotor, pwake, lim)}\n")

        mbook = foxes.models.ModelBook()
        ttype = foxes.models.turbine_types.PCtFile(
            data_source=tfile, var_ws_ct=FV.REWS, var_ws_P=FV.REWS
        )
        mbook.turbine_types[ttype.name] = ttype

        states = foxes.input.states.StatesTable(
            data_source=sfile,
            output_vars=[FV.WS, FV.WD, FV.TI, FV.RHO],
            var2col={FV.WS: "ws", FV.WD: "wd", FV.TI: "ti"},
            fixed_vars={FV.RHO: 1.225},
        )

        farm = foxes.WindFarm()
        foxes.input.farm_layout.add_from_file(
            farm, lfile, turbine_models=[ttype.name], verbosity=1
        )

        algo = foxes.algorithms.Downwind(
            mbook,
            farm,
            states=states,
            rotor_model=rotor,
            wake_models=["Bastankhah_linear_k002"],
            wake_frame="rotor_wd",
            partial_wakes_model=pwake,
            chunks=ck,
            verbosity=1,
        )

        if 1:
            with ProgressBar():
                data = algo.calc_farm()
        else:
            data = algo.calc_farm()

        df = data.to_dataframe()[
            [FV.AMB_WD, FV.WD, FV.AMB_REWS, FV.REWS, FV.AMB_P, FV.P]
        ]

        print()
        print("TRESULTS\n")
        print(df)

        df = df.reset_index()

        if base_results is None:
            base_results = df

        else:
            print(f"CASE {(rotor, pwake, lim)}")
            delta = df - base_results
            print(delta)
            print(delta.min(), delta.max())
            chk = delta[FV.REWS].abs()
            print(f"CASE {(rotor, pwake, lim)}:", chk.max())

            assert (chk < lim).all()
