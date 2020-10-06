DAQlib_variadic


class Fake:
    lib_name = None


sys.modules["DAQmxConfigTest"] = Fake  # trick PyDAQmx

import PyDAQmx  # verify install

