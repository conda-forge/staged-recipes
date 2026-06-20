"""Pure-Python interface to GM2Calc.

GM2Calc compiles a C ("extern C") interface into ``libgm2calc`` (the
``*_c.cpp`` sources), so this module binds those already-compiled routines
directly with :mod:`ctypes`.  Nothing is compiled or JIT-ed at import time and
there is no dependency on cppyy/Cling -- the shared library built during the
conda package build is called as-is.

The library is located relative to ``sys.prefix`` so the module is relocatable
within a conda environment.

Example
-------
>>> import gm2calc
>>> model = gm2calc.MSSMNoFV()
>>> model.set_MassB(150); model.set_MassWB(300); model.set_Mu(350)
>>> # ... set the remaining parameters ...
>>> model.calculate_masses()
>>> amu = model.calculate_amu_1loop() + model.calculate_amu_2loop()

This binds GM2Calc's MSSMNoFV (real MSSM without flavour violation) and THDM
(Two-Higgs-Doublet Model) C APIs, covering the standard muon (g-2) workflow.
"""

import ctypes
import sys
from pathlib import Path

__all__ = [
    "GM2CalcError",
    "MSSMNoFV",
    "SM",
    "THDM",
    "THDMConfig",
    "THDMGaugeBasis",
    "THDMMassBasis",
    "YukawaType",
    "error_str",
]


def _load_library():
    """Load libgm2calc from the active environment."""
    libdir = Path(sys.prefix) / "lib"
    for name in ("libgm2calc.so", "libgm2calc.dylib"):
        path = libdir / name
        if path.exists():
            return ctypes.CDLL(str(path))
    raise OSError(
        f"could not find libgm2calc in {str(libdir)!r}; "
        "is the 'gm2calc' package installed in this environment?"
    )


_lib = _load_library()

_DBL = ctypes.c_double
_UINT = ctypes.c_uint
_INT = ctypes.c_int


# --- opaque handle ------------------------------------------------------
class _MSSMNoFV_onshell(ctypes.Structure):
    pass


_Ptr = ctypes.POINTER(_MSSMNoFV_onshell)


# --- error handling -----------------------------------------------------
# gm2calc_error enum, see include/gm2calc/gm2_error.h
_lib.gm2calc_error_str.argtypes = [_INT]
_lib.gm2calc_error_str.restype = ctypes.c_char_p


def error_str(code):
    """Return the human-readable string for a gm2calc_error code."""
    return _lib.gm2calc_error_str(code).decode()


class GM2CalcError(Exception):
    """Raised when a GM2Calc routine reports an error or physical problem."""


def _decl(name, restype, argtypes):
    fn = getattr(_lib, name)
    fn.restype = restype
    fn.argtypes = argtypes
    return fn


# C-function name suffixes grouped by signature.  The full C name is
# "gm2calc_mssmnofv_<suffix>".  Binding from tables keeps the wrapper a 1:1
# mirror of include/gm2calc/MSSMNoFV_onshell.h.
_SCALAR_SETTERS = [  # set_<x>(double)
    "alpha_MZ",
    "alpha_thompson",
    "g3",
    "MassB",
    "MassWB",
    "MassG",
    "Mu",
    "TB",
    "scale",
    "MAh_pole",
    "MZ_pole",
    "MW_pole",
    "MT_pole",
    "MB_running",
    "ML_pole",
    "MM_pole",
    "MSvmL_pole",
]
_INDEX_SETTERS = [  # set_<x>(unsigned, double)
    "MSm_pole",
    "MCha_pole",
    "MChi_pole",
]
_MATRIX_SETTERS = [  # set_<x>(unsigned, unsigned, double)
    "Ae",
    "Au",
    "Ad",
    "mq2",
    "mu2",
    "md2",
    "ml2",
    "me2",
]
_SCALAR_GETTERS = [  # get_<x>() -> double
    "EL",
    "EL0",
    "gY",
    "g1",
    "g2",
    "g3",
    "TB",
    "MassB",
    "MassWB",
    "MassG",
    "Mu",
    "vev",
    "scale",
    "MW",
    "MZ",
    "ME",
    "MM",
    "ML",
    "MU",
    "MC",
    "MT",
    "MD",
    "MS",
    "MB",
    "MBMB",
    "MAh",
    "MSveL",
    "MSvmL",
    "MSvtL",
]
_INDEX_GETTERS = [  # get_<x>(unsigned) -> double
    "Mhh",
    "MCha",
    "MChi",
    "MSe",
    "MSm",
    "MStau",
    "MSu",
    "MSd",
    "MSc",
    "MSs",
    "MSt",
    "MSb",
]
_MATRIX_GETTERS = [  # get_<x>(unsigned, unsigned) -> double
    "Ae",
    "Ad",
    "Au",
    "mq2",
    "md2",
    "mu2",
    "ml2",
    "me2",
    "USe",
    "USm",
    "UStau",
    "USu",
    "USd",
    "USc",
    "USs",
    "USt",
    "USb",
    "Ye",
    "Yd",
    "Yu",
]
_CALCULATORS = [  # <x>() -> double
    "calculate_amu_1loop",
    "calculate_amu_1loop_non_tan_beta_resummed",
    "calculate_amu_2loop",
    "calculate_amu_2loop_non_tan_beta_resummed",
    "calculate_uncertainty_amu_0loop",
    "calculate_uncertainty_amu_1loop",
    "calculate_uncertainty_amu_2loop",
    "amu1LChi0",
    "amu1LChipm",
    "amu2LFSfapprox",
    "amu2LFSfapprox_non_tan_beta_resummed",
    "amu2LChipmPhotonic",
    "amu2LChi0Photonic",
    "amu2LaSferm",
    "amu2LaCha",
]


class MSSMNoFV:
    """On-shell MSSM (no flavour violation) model for the muon (g-2)."""

    def __init__(self):
        _lib.gm2calc_mssmnofv_new.restype = _Ptr
        _lib.gm2calc_mssmnofv_new.argtypes = []
        self._ptr = _lib.gm2calc_mssmnofv_new()
        if not self._ptr:
            raise GM2CalcError("could not allocate MSSMNoFV_onshell")

    def __del__(self):
        ptr = getattr(self, "_ptr", None)
        if ptr:
            _lib.gm2calc_mssmnofv_free(ptr)
            self._ptr = None

    def set_verbose_output(self, enable):
        _lib.gm2calc_mssmnofv_set_verbose_output(self._ptr, int(bool(enable)))

    def calculate_masses(self):
        """Calculate the MSSM mass spectrum, raising on error."""
        err = _lib.gm2calc_mssmnofv_calculate_masses(self._ptr)
        if err != 0:
            raise GM2CalcError(error_str(err))

    def convert_to_onshell(self):
        """Convert the model parameters to the on-shell scheme."""
        err = _lib.gm2calc_mssmnofv_convert_to_onshell(self._ptr)
        if err != 0:
            raise GM2CalcError(error_str(err))

    def have_problem(self):
        return bool(_lib.gm2calc_mssmnofv_have_problem(self._ptr))

    def have_warning(self):
        return bool(_lib.gm2calc_mssmnofv_have_warning(self._ptr))

    def get_problems(self):
        buf = ctypes.create_string_buffer(1024)
        _lib.gm2calc_mssmnofv_get_problems(self._ptr, buf, len(buf))
        return buf.value.decode()

    def get_warnings(self):
        buf = ctypes.create_string_buffer(1024)
        _lib.gm2calc_mssmnofv_get_warnings(self._ptr, buf, len(buf))
        return buf.value.decode()


# free()/calculate/problem prototypes used by the explicit methods above
_decl("gm2calc_mssmnofv_free", None, [_Ptr])
_decl("gm2calc_mssmnofv_set_verbose_output", None, [_Ptr, _INT])
_decl("gm2calc_mssmnofv_calculate_masses", _INT, [_Ptr])
_decl("gm2calc_mssmnofv_convert_to_onshell", _INT, [_Ptr])
_decl("gm2calc_mssmnofv_have_problem", _INT, [_Ptr])
_decl("gm2calc_mssmnofv_have_warning", _INT, [_Ptr])
_decl("gm2calc_mssmnofv_get_problems", None, [_Ptr, ctypes.c_char_p, _UINT])
_decl("gm2calc_mssmnofv_get_warnings", None, [_Ptr, ctypes.c_char_p, _UINT])


# Generate the uniform setter/getter/calculator methods from the tables.
def _bind_scalar_setter(suffix):
    fn = _decl(f"gm2calc_mssmnofv_set_{suffix}", None, [_Ptr, _DBL])
    return lambda self, value: fn(self._ptr, value)


def _bind_index_setter(suffix):
    fn = _decl(f"gm2calc_mssmnofv_set_{suffix}", None, [_Ptr, _UINT, _DBL])
    return lambda self, i, value: fn(self._ptr, i, value)


def _bind_matrix_setter(suffix):
    fn = _decl(f"gm2calc_mssmnofv_set_{suffix}", None, [_Ptr, _UINT, _UINT, _DBL])

    def setter(self, *args):
        # set_<x>(i, j, value) sets a single element; set_<x>(matrix) sets the
        # full 3x3 from any indexable sequence (nested list/tuple or numpy
        # array -- numpy is supported but not required).
        if len(args) == 3:
            i, j, value = args
            fn(self._ptr, i, j, float(value))
        elif len(args) == 1:
            matrix = args[0]
            for i in range(3):
                row = matrix[i]
                for j in range(3):
                    fn(self._ptr, i, j, float(row[j]))
        else:
            raise TypeError(f"set_{suffix}() takes a 3x3 matrix or (i, j, value)")

    return setter


def _bind_scalar_getter(suffix):
    fn = _decl(f"gm2calc_mssmnofv_get_{suffix}", _DBL, [_Ptr])
    return lambda self: fn(self._ptr)


def _bind_index_getter(suffix):
    fn = _decl(f"gm2calc_mssmnofv_get_{suffix}", _DBL, [_Ptr, _UINT])
    return lambda self, i: fn(self._ptr, i)


def _bind_matrix_getter(suffix):
    fn = _decl(f"gm2calc_mssmnofv_get_{suffix}", _DBL, [_Ptr, _UINT, _UINT])
    return lambda self, i, j: fn(self._ptr, i, j)


def _bind_calculator(suffix):
    fn = _decl(f"gm2calc_mssmnofv_{suffix}", _DBL, [_Ptr])
    return lambda self: fn(self._ptr)


for _suffix in _SCALAR_SETTERS:
    setattr(MSSMNoFV, f"set_{_suffix}", _bind_scalar_setter(_suffix))
for _suffix in _INDEX_SETTERS:
    setattr(MSSMNoFV, f"set_{_suffix}", _bind_index_setter(_suffix))
for _suffix in _MATRIX_SETTERS:
    setattr(MSSMNoFV, f"set_{_suffix}", _bind_matrix_setter(_suffix))
for _suffix in _SCALAR_GETTERS:
    setattr(MSSMNoFV, f"get_{_suffix}", _bind_scalar_getter(_suffix))
for _suffix in _INDEX_GETTERS:
    setattr(MSSMNoFV, f"get_{_suffix}", _bind_index_getter(_suffix))
for _suffix in _MATRIX_GETTERS:
    setattr(MSSMNoFV, f"get_{_suffix}", _bind_matrix_getter(_suffix))
for _suffix in _CALCULATORS:
    setattr(MSSMNoFV, _suffix, _bind_calculator(_suffix))

del _suffix


# ======================================================================
# Two-Higgs-Doublet Model (THDM)
#
# The THDM C API (include/gm2calc/THDM.h, SM.h) takes plain C structs by
# value/pointer rather than the opaque-handle setters used by MSSMNoFV, so the
# input is mirrored here as ctypes.Structures whose field order matches the C
# layout exactly.
# ======================================================================

_DBL3 = _DBL * 3
_DBL3X3 = (_DBL * 3) * 3


class YukawaType:
    """gm2calc_THDM_yukawa_type enum values (THDM.h)."""

    type_1 = 1
    type_2 = 2
    type_X = 3
    type_Y = 4
    aligned = 5
    general = 6


class SM(ctypes.Structure):
    """Standard Model input for the THDM (mirrors struct gm2calc_SM)."""

    _fields_ = [
        ("alpha_em_0", _DBL),
        ("alpha_em_mz", _DBL),
        ("alpha_s_mz", _DBL),
        ("mh", _DBL),
        ("mw", _DBL),
        ("mz", _DBL),
        ("mu", _DBL3),
        ("md", _DBL3),
        ("mv", _DBL3),
        ("ml", _DBL3),
        ("ckm_real", _DBL3X3),
        ("ckm_imag", _DBL3X3),
    ]

    def __init__(self):
        super().__init__()
        _lib.gm2calc_sm_set_to_default(ctypes.byref(self))

    def set_alpha_em_0(self, value):
        self.alpha_em_0 = value

    def set_alpha_em_mz(self, value):
        self.alpha_em_mz = value

    def set_alpha_s_mz(self, value):
        self.alpha_s_mz = value

    def set_mh(self, value):
        self.mh = value

    def set_mw(self, value):
        self.mw = value

    def set_mz(self, value):
        self.mz = value

    def set_mu(self, i, value):
        self.mu[i] = value

    def set_md(self, i, value):
        self.md[i] = value

    def set_mv(self, i, value):
        self.mv[i] = value

    def set_ml(self, i, value):
        self.ml[i] = value


class THDMConfig(ctypes.Structure):
    """THDM configuration options (mirrors struct gm2calc_THDM_config)."""

    _fields_ = [
        ("force_output", _INT),
        ("running_couplings", _INT),
    ]

    def __init__(self):
        super().__init__()
        _lib.gm2calc_thdm_config_set_to_default(ctypes.byref(self))


class THDMGaugeBasis(ctypes.Structure):
    """THDM gauge-basis input (mirrors struct gm2calc_THDM_gauge_basis).

    The C field ``lambda[7]`` is exposed as ``lambda_`` since ``lambda`` is a
    Python keyword.  Matrix fields default to zero.
    """

    _fields_ = [
        ("yukawa_type", _INT),
        ("lambda_", _DBL * 7),
        ("tan_beta", _DBL),
        ("m122", _DBL),
        ("zeta_u", _DBL),
        ("zeta_d", _DBL),
        ("zeta_l", _DBL),
        ("Delta_u", _DBL3X3),
        ("Delta_d", _DBL3X3),
        ("Delta_l", _DBL3X3),
        ("Pi_u", _DBL3X3),
        ("Pi_d", _DBL3X3),
        ("Pi_l", _DBL3X3),
    ]


class THDMMassBasis(ctypes.Structure):
    """THDM physical (mass) basis input (mirrors struct gm2calc_THDM_mass_basis).

    Matrix fields (Delta_*, Pi_*) default to zero.
    """

    _fields_ = [
        ("yukawa_type", _INT),
        ("mh", _DBL),
        ("mH", _DBL),
        ("mA", _DBL),
        ("mHp", _DBL),
        ("sin_beta_minus_alpha", _DBL),
        ("lambda_6", _DBL),
        ("lambda_7", _DBL),
        ("tan_beta", _DBL),
        ("m122", _DBL),
        ("zeta_u", _DBL),
        ("zeta_d", _DBL),
        ("zeta_l", _DBL),
        ("Delta_u", _DBL3X3),
        ("Delta_d", _DBL3X3),
        ("Delta_l", _DBL3X3),
        ("Pi_u", _DBL3X3),
        ("Pi_d", _DBL3X3),
        ("Pi_l", _DBL3X3),
    ]


class _THDM_handle(ctypes.Structure):
    pass


_ThdmPtr = ctypes.POINTER(_THDM_handle)

_decl(
    "gm2calc_thdm_new_with_mass_basis",
    _INT,
    [
        ctypes.POINTER(_ThdmPtr),
        ctypes.POINTER(THDMMassBasis),
        ctypes.POINTER(SM),
        ctypes.POINTER(THDMConfig),
    ],
)
_decl(
    "gm2calc_thdm_new_with_gauge_basis",
    _INT,
    [
        ctypes.POINTER(_ThdmPtr),
        ctypes.POINTER(THDMGaugeBasis),
        ctypes.POINTER(SM),
        ctypes.POINTER(THDMConfig),
    ],
)
_decl("gm2calc_thdm_free", None, [_ThdmPtr])

_THDM_CALCULATORS = [  # <x>() -> double
    "calculate_amu_1loop",
    "calculate_amu_2loop",
    "calculate_amu_2loop_bosonic",
    "calculate_amu_2loop_fermionic",
    "calculate_uncertainty_amu_0loop",
    "calculate_uncertainty_amu_1loop",
    "calculate_uncertainty_amu_2loop",
]


class THDM:
    """Two-Higgs-Doublet Model for the muon (g-2).

    Construct from a :class:`THDMMassBasis` or :class:`THDMGaugeBasis`, an
    :class:`SM` and an optional :class:`THDMConfig`.
    """

    def __init__(self, basis, sm, config=None):
        if config is None:
            config = THDMConfig()
        if isinstance(basis, THDMMassBasis):
            new = _lib.gm2calc_thdm_new_with_mass_basis
        elif isinstance(basis, THDMGaugeBasis):
            new = _lib.gm2calc_thdm_new_with_gauge_basis
        else:
            raise TypeError("basis must be a THDMMassBasis or THDMGaugeBasis")
        self._ptr = _ThdmPtr()
        err = new(
            ctypes.byref(self._ptr),
            ctypes.byref(basis),
            ctypes.byref(sm),
            ctypes.byref(config),
        )
        if err != 0:
            self._ptr = None
            raise GM2CalcError(error_str(err))

    def __del__(self):
        ptr = getattr(self, "_ptr", None)
        if ptr:
            _lib.gm2calc_thdm_free(self._ptr)
            self._ptr = None


def _bind_thdm_calculator(suffix):
    fn = _decl(f"gm2calc_thdm_{suffix}", _DBL, [_ThdmPtr])
    return lambda self: fn(self._ptr)


for _suffix in _THDM_CALCULATORS:
    setattr(THDM, _suffix, _bind_thdm_calculator(_suffix))

del _suffix
