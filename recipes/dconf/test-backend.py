import ctypes
import os
from pathlib import Path

libdir = Path(os.environ['PREFIX']) / 'lib'
assert (libdir / 'gio/modules/libdconfsettings.so').is_file()

# Read the actual backend type: GIO can fall back even with GSETTINGS_BACKEND set.
os.environ.pop('GIO_MODULE_DIR', None)
os.environ.pop('GIO_EXTRA_MODULES', None)
os.environ['GSETTINGS_BACKEND'] = 'dconf'
gio = ctypes.CDLL(str(libdir / 'libgio-2.0.so.0'))
gio.g_settings_backend_get_default.restype = ctypes.c_void_p
gio.g_type_name_from_instance.argtypes = [ctypes.c_void_p]
gio.g_type_name_from_instance.restype = ctypes.c_char_p
backend = gio.g_settings_backend_get_default()
assert backend
type_name = gio.g_type_name_from_instance(backend)
assert type_name == b'DConfSettingsBackend', type_name
