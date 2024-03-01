import platform
import subprocess

def check_r_installed():
    current_platform = platform.system()

    if current_platform == "Windows":
        # Check if R is installed on Windows by checking the registry
        try:
            subprocess.run(
                ["reg", "query", "HKLM\\Software\\R-core\\R"], check=True
            )
            print("R is already installed on Windows.")
            return True
        except subprocess.CalledProcessError:
            print("R is not installed on Windows.")
            return False

    elif current_platform == "Linux":
        # Check if R is installed on Linux by checking if the 'R' executable is available
        try:
            subprocess.run(["which", "R"], check=True)
            print("R is already installed on Linux.")
            return True
        except subprocess.CalledProcessError:
            print("R is not installed on Linux.")
            return False

    elif current_platform == "Darwin":  # macOS
        # Check if R is installed on macOS by checking if the 'R' executable is available
        try:
            subprocess.run(["which", "R"], check=True)
            print("R is already installed on macOS.")
            return True
        except subprocess.CalledProcessError:
            print("R is not installed on macOS.")
            return False

    else:
        print("Unsupported platform. Unable to check for R installation.")
        return False

def install_r():

    current_platform = platform.system()

    if current_platform == "Windows":
        # Install R on Windows using PowerShell
        install_command = "Start-Process powershell -Verb subprocess.runAs -ArgumentList '-Command \"& {Invoke-WebRequest https://cran.r-project.org/bin/windows/base/R-4.1.2-win.exe -OutFile R.exe}; Start-Process R.exe -ArgumentList '/SILENT' -Wait}'"
        subprocess.run(install_command, shell=True)

    elif current_platform == "Linux":
        # Install R on Linux using the appropriate package manager (e.g., apt-get)
        install_command = (
            "sudo apt update -qq && sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9"
            + "&& sudo add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/'"
            + "&& sudo apt update"
            + "&& sudo apt -y install r-base"
        )
        subprocess.run(install_command, shell=True)

    elif current_platform == "Darwin":  # macOS
        # Install R on macOS using Homebrew
        install_command = "brew install r"
        subprocess.run(install_command, shell=True)

    else:

        print("Unsupported platform. Unable to install R.")

def install_packages():
    try:	
        # subprocess.run(["sudo", "Rscript", "-e", "utils::install.packages(remotes, dependencies=TRUE)"])
        # subprocess.run(["sudo", "Rscript", "-e", "utils::install.packages('curl', dependencies=TRUE)"])
        # subprocess.run(["sudo", "Rscript", "-e", "utils::install.packages('e1071', dependencies=TRUE)"])				
        # subprocess.run(["sudo", "Rscript", "-e", "utils::install.packages('ranger', dependencies=TRUE)"])				
        # subprocess.run(["sudo", "Rscript", "-e", "utils::install.packages('fGarch', dependencies=TRUE)"])	
        # subprocess.run(["sudo", "Rscript", "-e", "utils::install.packages('foreach', dependencies=TRUE)"])
        # subprocess.run(["sudo", "Rscript", "-e", "utils::install.packages('curl', dependencies=TRUE)"])							
        # subprocess.run(["sudo", "Rscript", "-e", "utils::install.packages('randtoolbox', dependencies=TRUE)"])
        # subprocess.run(["sudo", "Rscript", "-e", "utils::install.packages('Rcpp', dependencies=TRUE)"])
        # subprocess.run(["sudo", "Rscript", "-e", "utils::install.packages('snow', dependencies=TRUE)"])						
        # subprocess.run(["sudo", "Rscript", "-e", "utils::install.packages('VineCopula', dependencies=TRUE)"])
        # subprocess.run(["sudo", "Rscript", "-e", "utils::install.packages('tseries', dependencies=TRUE)"])
        # subprocess.run(["sudo", "Rscript", "-e", "utils::install.packages('forecast', dependencies=TRUE)"])        
        subprocess.run(["sudo", "Rscript", "-e", "utils::install.packages('ahead', repos='https://techtonique.r-universe.dev', dependencies=TRUE)"])
    except: 	
        # subprocess.run(["mkdir", "-p", "r-ahead"])		 
        # subprocess.run(["sudo", "Rscript", "-e", "utils::install.packages(remotes, lib='r-ahead', dependencies=TRUE)"])
        # subprocess.run(["sudo", "Rscript", "-e", "utils::install.packages('curl', lib='r-ahead', dependencies=TRUE)"])
        # subprocess.run(["sudo", "Rscript", "-e", "utils::install.packages('e1071', lib='r-ahead', dependencies=TRUE)"])				
        # subprocess.run(["sudo", "Rscript", "-e", "utils::install.packages('ranger', lib='r-ahead', dependencies=TRUE)"])				
        # subprocess.run(["sudo", "Rscript", "-e", "utils::install.packages('fGarch', lib='r-ahead', dependencies=TRUE)"])	
        # subprocess.run(["sudo", "Rscript", "-e", "utils::install.packages('foreach', lib='r-ahead', dependencies=TRUE)"])
        # subprocess.run(["sudo", "Rscript", "-e", "utils::install.packages('curl', lib='r-ahead', dependencies=TRUE)"])							
        # subprocess.run(["sudo", "Rscript", "-e", "utils::install.packages('randtoolbox', lib='r-ahead', dependencies=TRUE)"])
        # subprocess.run(["sudo", "Rscript", "-e", "utils::install.packages('Rcpp', lib='r-ahead', dependencies=TRUE)"])
        # subprocess.run(["sudo", "Rscript", "-e", "utils::install.packages('snow', lib='r-ahead', dependencies=TRUE)"])						
        # subprocess.run(["sudo", "Rscript", "-e", "utils::install.packages('VineCopula', lib='r-ahead', dependencies=TRUE)"])
        # subprocess.run(["sudo", "Rscript", "-e", "utils::install.packages('tseries', lib='r-ahead', dependencies=TRUE)"])
        # subprocess.run(["sudo", "Rscript", "-e", "utils::install.packages('forecast', lib='r-ahead', dependencies=TRUE)"])
        subprocess.run(["sudo", "Rscript", "-e", "utils::install.packages('ahead', repos='https://techtonique.r-universe.dev', lib='r-ahead', dependencies=TRUE)"])


# Check if R is installed; if not, install it
if not check_r_installed():
    print("Installing R...")
    install_r()
else:
    print("No installation needed.")

install_packages()

subprocess.run(["pip", "install", "rpy2"])

from setuptools import setup, find_packages
from codecs import open
from os import path

__version__ = "0.10.0"

here = path.abspath(path.dirname(__file__))

# get the dependencies and installs

with open(
    path.join(here, "requirements.txt"), encoding="utf-8"
) as f:
    all_reqs = f.read().split("\n")

install_requires = [
    x.strip() for x in all_reqs if "git+" not in x
]
dependency_links = [
    x.strip().replace("git+", "")
    for x in all_reqs
    if x.startswith("git+")
]

setup(
    name="ahead",
    version=__version__,
    description="Time series forecasting with Machine Learning and uncertainty quantification",
    long_description="A package for time series forecasting with Machine Learning and uncertainty quantification",
    license="BSD3 Clause Clear",
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "Programming Language :: Python :: 3",
    ],
    keywords="",
    packages=find_packages(exclude=["docs", "tests*"]),
    include_package_data=True,
    author="T. Moudiki",
    install_requires=install_requires,
    dependency_links=dependency_links,
    author_email="thierry.moudiki@gmail.com",
    python_requires=">=3.8"
)
