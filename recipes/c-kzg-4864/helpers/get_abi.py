import sysconfig
import platform

def create_tag():
    python_impl = sysconfig.get_config_var('SOABI').split('-')[0]
    python_version = sysconfig.get_config_var('py_version_nodot')
    system_arch = platform.machine()
    return f"{python_impl}{python_version}-{python_impl}{python_version}-win_{system_arch}"

if __name__ == "__main__":
    print(create_tag())