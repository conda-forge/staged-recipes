import math
import pprint
import pylibefp
from qcelemental import compare_recursive

b2a = 0.529177
a2b = 1.0 / b2a


def blank_ene():
    fields = [
        'charge_penetration', 'disp', 'dispersion', 'elec', 'electrostatic', 'electrostatic_point_charges',
        'exchange_repulsion', 'pol', 'polarization', 'xr'
    ]
    ene = {f: 0.0 for f in fields}
    return ene


def system_1():
    sys = pylibefp.core.efp()

    frags = ['h2o', 'nh3']
    sys.add_potential(frags)
    sys.add_fragment(frags)
    sys.set_frag_coordinates(0, 'xyzabc', [0.0 * a2b, 0.0 * a2b, 0.0 * a2b, 1.0, 2.0, 3.0])  # yapf: disable
    sys.set_frag_coordinates(1, 'xyzabc', [5.0 * a2b, 0.0 * a2b, 0.0 * a2b, 5.0, 2.0, 8.0])  # yapf: disable

    sys.prepare()
    return sys

if __name__ == "__main__":
    print("starting")
    asdf = system_1()
    print("got system")
    asdf.set_opts({
        'elec': True,
        'elec_damp': 'screen',
        'xr': True,
        'pol': True,  # 'pol_damp': 'tt',
        'disp': True,
        'disp_damp': 'tt'
    })
    print("set options")
    asdf.compute()
    print("computed")
    ene = asdf.get_energy()
    pprint.pprint(ene)
    print('<<< get_opts():  ', asdf.get_opts(), '>>>')
    #print('<<< summary():   ', asdf.summary(), '>>>')
    print('<<< get_energy():', ene, '>>>')
    print('<<< get_atoms(): ', asdf.get_atoms(), '>>>')
    print(asdf.energy_summary())
    print(asdf.geometry_summary(units_to_bohr=b2a))
    print(asdf.geometry_summary(units_to_bohr=1.0))
    
    expected_ene = blank_ene()
    expected_ene['elec'] = expected_ene['electrostatic'] = 0.0002900482
    expected_ene['xr'] = expected_ene['exchange_repulsion'] = 0.0000134716
    expected_ene['pol'] = expected_ene['polarization'] = 0.0002777238 - expected_ene['electrostatic']
    expected_ene['disp'] = expected_ene['dispersion'] = -0.0000989033
    expected_ene['total'] = 0.0001922903
    assert asdf.get_frag_count() == 2, 'nfrag'
    assert math.isclose(asdf.get_frag_charge(1), 0.0, abs_tol=1.e-6), 'f_chg'
    assert asdf.get_frag_multiplicity(1) == 1, 'f_mult'
    assert asdf.get_frag_name(1) == 'NH3', 'f_name'
    assert compare_recursive(expected_ene, ene, 'ene', atol=1.e-6)

