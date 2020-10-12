import os
import sys
import shutil
import tarfile
import fnmatch
import platform
from pathlib import Path
from subprocess import check_call
from argparse import ArgumentParser
from tempfile import TemporaryDirectory as tempdir

# To accommodate nvtoolsext not being present as a DLL in the installer PE32s on windows,
# the windows variant of this script supports assembly directly from a pre-installed
# CUDA toolkit. The environment variable "NVTOOLSEXT_INSTALL_PATH" can be set to the
# installation path of the CUDA toolkit's NvToolsExt location (this is not the user
# defined install directory) and the DLL will be taken from that location.


class Extractor(object):
    """Extractor base class, platform specific extractors should inherit
    from this class.
    """

    def __init__(self, platform, version, version_patch):
        """Base class for extracting cudatoolkit

        Parameters
        ----------
        platform : str
            Normalized platform name of system arch, e.g. "linux" or "windows"
        version : str
            Full version sting for cudatoolkit in X.Y.Z form, i.e. 11.0.3

        Attributes
        ----------
        cuda_libraries : list of str
            The shared libraries to copy in.
        cuda_static_libraries : list of str
            The static libraries to copy in.
        libdevice_versions : list of str
            The library device versions supported (.bc files)
        runfile : str
            The name of the downloaded file to extract, for linux this is the .run file
        embedded_blob : str or None
            CUDA 11 installer has channed, there are no embedded blobs
        patches : list of str
            A list of the patch files for the blob, they are applied in order
        cuda_lib_fmt : str
            String format for the cuda libraries
        nvvm_lib_fmt : str
            String format for the nvvm libraries
        libdevice_lib_fmt : str
            string format for the libdevice.compute bitcode file
        """
        self.version = version
        version_parts = version.split(".")
        if len(version_parts) == 2:
            self.major, self.minor = version_parts
        elif len(version_parts) > 2:
            self.major, self.minor, self.micro = version_parts[:3]
        else:
            raise ValueError(f"{version!r} not a valid version string")

        # set attrs
        self.cuda_libraries = [
            "cublas",
            "cublasLt",
            "cudart",
            "cufft",
            "cufftw",
            "curand",
            "cusolver",
            "cusolverMg",
            "cusparse",
            "nppc",
            "nppial",
            "nppicc",
            "nppidei",
            "nppif",
            "nppig",
            "nppim",
            "nppist",
            "nppisu",
            "nppitc",
            "npps",
            "nvToolsExt",
            "nvblas",
            "nvjpeg",
            "nvrtc",
            "nvrtc-builtins",
        ]
        self.cuda_static_libraries = ["cudadevrt"]
        self.libdevice_versions = [self.major]
        self.libdevice_lib_fmt = "libdevice.10.bc"
        self.patches = []
        self.prefix = os.environ["PREFIX"]
        self.src_dir = os.environ["SRC_DIR"]
        self.debug_install_path = os.environ.get("DEBUG_INSTALLER_PATH")

        # additional prep
        os.makedirs(self.output_dir, exist_ok=True)

    def copy(self, *args):
        """The method to copy extracted files into the conda package platform
        specific directory. Platform specific extractors must implement.
        """
        raise RuntimeError("Must implement")

    def extract(self, *args):
        """The method to extract files from the cuda binary blobs.
        Platform specific extractors must implement.
        """
        raise RuntimeError("Must implement")

    def get_paths(self, libraries, dirpath, template):
        """Gets the paths to the various cuda libraries and bc files"""
        pathlist = []
        for libname in libraries:
            filename = template.format(libname)
            paths = fnmatch.filter(os.listdir(dirpath), filename)
            if not paths:
                msg = "Cannot find item: %s, looked for %s" % (libname, filename)
                raise RuntimeError(msg)
            if (not self.symlinks) and (len(paths) != 1):
                msg = "Aliasing present for item: %s, looked for %s" % (
                    libname,
                    filename,
                )
                msg += ". Found: \n"
                msg += ", \n".join([str(x) for x in paths])
                raise RuntimeError(msg)
            pathsforlib = []
            for path in paths:
                tmppath = os.path.join(dirpath, path)
                assert os.path.isfile(tmppath), "missing {0}".format(tmppath)
                pathsforlib.append(tmppath)
            if self.symlinks:  # deal with symlinked items
                # get all DSOs
                concrete_dsos = [x for x in pathsforlib if not os.path.islink(x)]
                # find the most recent library version by name
                target_library = max(concrete_dsos)
                # remove this from the list of concrete_dsos
                # all that remains are DSOs that are not wanted
                concrete_dsos.remove(target_library)
                # drop the unwanted DSOs from the paths
                [pathsforlib.remove(x) for x in concrete_dsos]
            pathlist.extend(pathsforlib)
        return pathlist

    def copy_files(self, cuda_lib_dir, nvvm_lib_dir, libdevice_lib_dir):
        """Copies the various cuda libraries and bc files to the output_dir"""
        filepaths = []
        # nvToolsExt is different to the rest of the cuda libraries,
        # it follows a different naming convention, this accommodates...
        cudalibs = [x for x in self.cuda_libraries if x != "nvToolsExt"]
        filepaths += self.get_paths(cudalibs, cuda_lib_dir, self.cuda_lib_fmt)
        if "nvToolsExt" in self.cuda_libraries:
            filepaths += self.get_paths(
                ["nvToolsExt"], cuda_lib_dir, self.nvtoolsext_fmt
            )
        filepaths += self.get_paths(
            self.cuda_static_libraries, cuda_lib_dir, self.cuda_static_lib_fmt
        )
        filepaths += self.get_paths(["nvvm"], nvvm_lib_dir, self.nvvm_lib_fmt)
        filepaths += self.get_paths(
            self.libdevice_versions, libdevice_lib_dir, self.libdevice_lib_fmt
        )

        for fn in filepaths:
            if os.path.islink(fn):
                # replicate symlinks
                symlinktarget = os.readlink(fn)
                targetname = os.path.basename(fn)
                symlink = os.path.join(self.output_dir, targetname)
                print("linking %s to %s" % (symlinktarget, symlink))
                os.symlink(symlinktarget, symlink)
            else:
                print("copying %s to %s" % (fn, self.output_dir))
                shutil.copy(fn, self.output_dir)


class WindowsExtractor(Extractor):
    """The windows extractor"""

    def __init__(self, platform, version, version_patch):
        super().__init__(platform, version, version_patch)
        self.cuda_libraries.append("cuinj")
        self.runfile = (f"cuda_{version}_{version_patch}_win10.exe",)
        self.embedded_blob = None
        self.symlinks = False
        self.cuda_lib_fmt = "{0}64_1*.dll"
        self.cuda_static_lib_fmt = '{0}.lib'
        self.nvvm_lib_fmt = "{0}64_33_0.dll"
        self.nvtoolsext_fmt = '{0}64_1.dll'
        self.libdevice_lib_fmt = 'libdevice.10.bc'
        self.nvtoolsextpath = os.path.join('c:' + os.sep, 'Program Files',
                                    'NVIDIA Corporation', 'NVToolsExt', 'bin')
        self.libdir = "Library/bin"
        self.output_dir = os.path.join(self.prefix, self.libdir)

    def copy(self, *args):
        (store,) = args
        self.copy_files(cuda_lib_dir=store, nvvm_lib_dir=store, libdevice_lib_dir=store)

    def extract(self):
        try:
            with tempdir() as tmpd:
                extract_name = "__extracted"
                extractdir = os.path.join(tmpd, extract_name)
                os.mkdir(extract_name)

                check_call(
                    [
                        "7za",
                        "x",
                        "-o%s" % extractdir,
                        os.path.join(self.src_dir, self.runfile),
                    ]
                )
                for p in self.patches:
                    check_call(
                        [
                            "7za",
                            "x",
                            "-aoa",
                            "-o%s" % extractdir,
                            os.path.join(self.src_dir, p),
                        ]
                    )

                nvt_path = os.environ.get(
                    "NVTOOLSEXT_INSTALL_PATH", self.nvtoolsextpath
                )
                print("NvToolsExt path: %s" % nvt_path)
                if nvt_path is not None:
                    if not Path(nvt_path).is_dir():
                        msg = "NVTOOLSEXT_INSTALL_PATH is invalid " "or inaccessible."
                        raise ValueError(msg)

                # fetch all the dlls into DLLs
                store_name = "DLLs"
                store = os.path.join(tmpd, store_name)
                os.mkdir(store)
                for path, dirs, files in os.walk(extractdir):
                    if (
                        "jre" not in path and "GFExperience" not in path
                    ):  # don't get jre or GFExperience dlls
                        for filename in fnmatch.filter(files, "*.dll"):
                            if not Path(os.path.join(store, filename)).is_file():
                                shutil.copy(os.path.join(path, filename), store)
                        for filename in fnmatch.filter(files, "*.lib"):
                            if not Path(os.path.join(store, filename)).is_file():
                                shutil.copy(os.path.join(path, filename), store)
                        for filename in fnmatch.filter(files, "*.bc"):
                            if not Path(os.path.join(store, filename)).is_file():
                                shutil.copy(os.path.join(path, filename), store)
                if nvt_path is not None:
                    for path, dirs, files in os.walk(nvt_path):
                        for filename in fnmatch.filter(files, "*.dll"):
                            if not Path(os.path.join(store, filename)).is_file():
                                shutil.copy(os.path.join(path, filename), store)
                self.copy(store)
        except PermissionError:
            # TODO: fix this
            # cuda 8 has files that refuse to delete, figure out perm changes
            # needed and apply them above, tempdir context exit fails to rmtree
            pass


class LinuxExtractor(Extractor):
    """The linux extractor"""

    def __init__(self, platform, version, version_patch):
        super().__init__(platform, version, version_patch)
        self.cuda_libraries.extend(["accinj64", "cuinj64"])
        self.symlinks = True
        # need globs to handle symlinks
        self.cuda_lib_fmt = "lib{0}.so*"
        self.cuda_static_lib_fmt = "lib{0}.a"
        self.nvvm_lib_fmt = "lib{0}.so*"
        self.nvtoolsext_fmt = "lib{0}.so*"
        self.nvtoolsextpath = None
        self.libdir = "lib"
        self.output_dir = os.path.join(self.prefix, self.libdir)

        if platform.machine() == "ppc64le":
            # Power 8 Arch
            self.runfile = f"cuda_{version}_{version_patch}_linux_ppc64le.run"
            self.embedded_blob = None
        else:
            # x86-64 Arch
            self.runfile = (f"cuda_{version}_{version_patch}_linux.run",)
            self.embedded_blob = None

    def copy(self, *args):
        basepath = args[0]
        self.copy_files(
            cuda_lib_dir=os.path.join(basepath, "lib64"),
            nvvm_lib_dir=os.path.join(basepath, "nvvm", "lib64"),
            libdevice_lib_dir=os.path.join(basepath, "nvvm", "libdevice"),
        )

    def extract(self):
        os.chmod(self.runfile, 0o777)
        with tempdir() as tmpd:
            if self.embedded_blob is not None:
                with tempdir() as tmpd2:
                    cmd = [
                        os.path.join(self.src_dir, self.runfile),
                        "--extract=%s" % (tmpd2,),
                        "--nox11",
                        "--silent",
                    ]
                    check_call(cmd)
                    # extract the embedded blob
                    cmd = [
                        os.path.join(tmpd2, self.embedded_blob),
                        "-prefix",
                        tmpd,
                        "-noprompt",
                        "--nox11",
                    ]
                    check_call(cmd)
            else:
                # Current Nvidia's Linux based runfiles don't use embedded runfiles
                #
                # "--installpath" runfile command is used to install the toolkit to a specified
                #     directory with the contents and layout similar to an install to
                #     '/usr/local/cuda`
                # "--override" runfile command to disable the compiler check since we are not
                #     installing the driver here
                # "--nox11" runfile command prevents desktop GUI on local install
                cmd = [
                    os.path.join(self.src_dir, self.runfile),
                    "--installpath=%s" % (tmpd),
                    "--toolkit",
                    "--silent",
                    "--override",
                    "--nox11",
                ]
                check_call(cmd)
            for p in self.patches:
                os.chmod(p, 0o777)
                cmd = [
                    os.path.join(self.src_dir, p),
                    "--installdir",
                    tmpd,
                    "--accept-eula",
                    "--silent",
                ]
                check_call(cmd)
            self.copy(tmpd)


def getplatform():
    plt = sys.platform
    if plt.startswith("linux"):
        return "linux"
    elif plt.startswith("win"):
        return "windows"
    else:
        raise RuntimeError("Unknown platform")


DISPATCHER = {"linux": LinuxExtractor, "windows": WindowsExtractor}


def make_parser():
    p = ArgumentParser("build.py")
    p.add_argument("--version", dest="version")
    p.add_argument("--version-patch", dest="version_patch")
    return p


def main():
    print("Running build")
    p = make_parser()
    ns = p.parse_args()

    # get an extractor & extract
    plat = getplatform()
    extractor_impl = DISPATCHER[plat]
    extractor = extractor_impl(plat, ns.version, ns.version_patch)
    extractor.extract()


if __name__ == "__main__":
    main()
