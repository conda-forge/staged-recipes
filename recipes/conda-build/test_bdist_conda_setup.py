from distutils.core import setup, Extension
import distutils.command.bdist_conda

setup(
    name="package",
    version="1.0.0",
    distclass=distutils.command.bdist_conda.CondaDistribution
)
