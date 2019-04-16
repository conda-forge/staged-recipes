#!/bin/bash -e

# ahhhhh yeah ascii art
cat << EOF






YYYYYYY       YYYYYYYEEEEEEEEEEEEEEEEEEEEEETTTTTTTTTTTTTTTTTTTTTTTIIIIIIIIII
Y:::::Y       Y:::::YE::::::::::::::::::::ET:::::::::::::::::::::TI::::::::I
Y:::::Y       Y:::::YE::::::::::::::::::::ET:::::::::::::::::::::TI::::::::I
Y::::::Y     Y::::::YEE::::::EEEEEEEEE::::ET:::::TT:::::::TT:::::TII::::::II
YYY:::::Y   Y:::::YYY  E:::::E       EEEEEETTTTTT  T:::::T  TTTTTT  I::::I
   Y:::::Y Y:::::Y     E:::::E                     T:::::T          I::::I
    Y:::::Y:::::Y      E::::::EEEEEEEEEE           T:::::T          I::::I
     Y:::::::::Y       E:::::::::::::::E           T:::::T          I::::I
      Y:::::::Y        E:::::::::::::::E           T:::::T          I::::I
       Y:::::Y         E::::::EEEEEEEEEE           T:::::T          I::::I
       Y:::::Y         E:::::E                     T:::::T          I::::I
       Y:::::Y         E:::::E       EEEEEE        T:::::T          I::::I
       Y:::::Y       EE::::::EEEEEEEE:::::E      TT:::::::TT      II::::::II
    YYYY:::::YYYY    E::::::::::::::::::::E      T:::::::::T      I::::::::I
    Y:::::::::::Y    E::::::::::::::::::::E      T:::::::::T      I::::::::I
    YYYYYYYYYYYYY    EEEEEEEEEEEEEEEEEEEEEE      TTTTTTTTTTT      IIIIIIIIII









BBBBBBBBBBBBBBBBB                                    hhhhhhh
B::::::::::::::::B                                   h:::::h
B::::::BBBBBB:::::B                                  h:::::h
BB:::::B     B:::::B                                 h:::::h
  B::::B     B:::::B  aaaaaaaaaaaaa      ssssssssss   h::::h hhhhh
  B::::B     B:::::B  a::::::::::::a   ss::::::::::s  h::::hh:::::hhh
  B::::BBBBBB:::::B   aaaaaaaaa:::::ass:::::::::::::s h::::::::::::::hh
  B:::::::::::::BB             a::::as::::::ssss:::::sh:::::::hhh::::::h
  B::::BBBBBB:::::B     aaaaaaa:::::a s:::::s  ssssss h::::::h   h::::::h
  B::::B     B:::::B  aa::::::::::::a   s::::::s      h:::::h     h:::::h
  B::::B     B:::::B a::::aaaa::::::a      s::::::s   h:::::h     h:::::h
  B::::B     B:::::Ba::::a    a:::::assssss   s:::::s h:::::h     h:::::h
BB:::::BBBBBB::::::Ba::::a    a:::::as:::::ssss::::::sh:::::h     h:::::h
B:::::::::::::::::B a:::::aaaa::::::as::::::::::::::s h:::::h     h:::::h
B::::::::::::::::B   a::::::::::aa:::as:::::::::::ss  h:::::h     h:::::h
BBBBBBBBBBBBBBBBB     aaaaaaaaaa  aaaa sssssssssss    hhhhhhh     hhhhhhh









UUUUUUUU     UUUUUUUU        tttt            iiii  lllllll
U::::::U     U::::::U     ttt:::t           i::::i l:::::l
U::::::U     U::::::U     t:::::t            iiii  l:::::l
UU:::::U     U:::::UU     t:::::t                  l:::::l
 U:::::U     U:::::Uttttttt:::::ttttttt    iiiiiii  l::::l     ssssssssss
 U:::::D     D:::::Ut:::::::::::::::::t    i:::::i  l::::l   ss::::::::::s
 U:::::D     D:::::Ut:::::::::::::::::t     i::::i  l::::l ss:::::::::::::s
 U:::::D     D:::::Utttttt:::::::tttttt     i::::i  l::::l s::::::ssss:::::s
 U:::::D     D:::::U      t:::::t           i::::i  l::::l  s:::::s  ssssss
 U:::::D     D:::::U      t:::::t           i::::i  l::::l    s::::::s
 U:::::D     D:::::U      t:::::t           i::::i  l::::l       s::::::s
 U::::::U   U::::::U      t:::::t    tttttt i::::i  l::::l ssssss   s:::::s
 U:::::::UUU:::::::U      t::::::tttt:::::ti::::::il::::::ls:::::ssss::::::s
  UU:::::::::::::UU       tt::::::::::::::ti::::::il::::::ls::::::::::::::s
    UU:::::::::UU           tt:::::::::::tti::::::il::::::l s:::::::::::ss
      UUUUUUUUU               ttttttttttt  iiiiiiiillllllll  sssssssssss




EOF

: '
--------------------------------------------------------------------------------
usage documentation:

  ./bash_util.sh -h

parameters
  $1 - help
       valid values: help, --help, -help, h, --h, -h

load bash_util functions into memory

  source bash_util.sh

--------------------------------------------------------------------------------
'

GREEN='\033[0;32m'
RED='\033[0;31m'
NO_COLOR='\033[0m'
COMPANY_NS="${COMPANY_NAMESPACE:-yeti-coolers}"
CONDA_BLD_NS="${CONDA_BLD_NAMESPACE:-$HOME/miniconda3/conda-bld}"

bump_version () {
if [[ $1 == "help" || $1 == "--help" || $1 == "-help" || $1 == "h" || $1 == "-h" || $1 == "--h"  ]]; then
printf """

  bump_version - Update release tag and version and commit and push release and tag

  optional arguments:
    ARG1 = version part to bump
    ARG2 = git commit message

  installation:

    conda install -c conda-forge bumpversion
    pip install --upgrade bumpversion

- usage:
# Default behavior:
    - bump patch version and files configured in .bumpversion.cfg
    - git commit, tag and push tags

bump_version

# Example: both commands below will bump patch version 0.5.172 to 0.5.173:

bump_version
bump_version patch

# Example: bump minor version 0.5.0 to 0.6.0:

bump_version minor

# Example: bump patch version with custom message

bump_version patch \"insert commit message here\"

"""
else

PART=${1:-patch}

#./banner.sh

# add all changes to index and commit
if ! git diff-index --quiet HEAD --; then
printf """

    bumpversion - WARNING
        - Working directory Git repo not clean, executing
        - git add .

    To not see this message in the future
    clean the working directory by adding
    outstanding changes to the index (git add .)
    and committing (git commit) before executing bumpversion

"""
git add .

fi

if [[ $(git config --get push.followTags) != "true" ]]; then

printf """

  bumpversion - configuring git to enable pushing commits and tags together

      git config --global push.followTags true

"""
git config --global push.followTags true

fi

printf """

    bumpversion
        - incrementing .bumpversion.cfg version
        - git push committed files with bumped version
        - git push commit and annotated signed tag

"""
# annotated signed release tags
#     Install gpg (NOTE: use gpg tools installer, I could not get the gpg version brew installed to work)
#       https://gpgtools.org/
#     Signing commits with GPG
#       see: https://docs.gitlab.com/ee/user/project/repository/gpg_signed_commits/
#     Configure git to use your key for signing
#       git config --global commit.gpgsign true
#       git config --global user.signingkey <INSERT-YOUR-GPG-KEY-HERE>
#     Show gpg keys on your machine
#       gpg --list-keys
#     Generate a new gpg key you can use to sign commits and tags
#       gpg --gen-key

# bump versions in all configured files and capture new version number
ANNOTATED_TAG=$(bumpversion --list --allow-dirty --message "${2:-bumping version}" ${PART} | grep new_version | sed -r s,"^.*=",,)
# generate annotated signed tag
git tag -s ${ANNOTATED_TAG} -m "${2:-bumping version}"
# push commit and signed tag
git push --follow-tags

fi
}

pip_build_package () {
if [[ $1 == "help" || $1 == "--help" || $1 == "-help" || $1 == "h" || $1 == "-h" || $1 == "--h"  ]]; then
printf """

  pip_build_package - use setuptools setup.py to build source distribution tar archive and wheel packages

  description:

    change to component home directory then execute
    python setup.py sdist bdist_wheel --universal

  parameters - parameter values can not contain spaces, underscores or special characters and must be all lower case

  \$1 - COMPONENT_HOME
        (Optional) Local file system directory path for the root of the component source code project.
        Defaults to ${COMPONENT_HOME}

- usage:
pip_build_package

"""
else

  C_HOME="${1:-$COMPONENT_HOME}"

  pushd ${C_HOME}

  printf """


  pip_build_package:

       COMPONENT_HOME: ${C_HOME}

  python setup.py sdist bdist_wheel --universal



  """

  python setup.py sdist bdist_wheel --universal

  popd

fi
}

conda_configure () {
if [[ $1 == "help" || $1 == "--help" || $1 == "-help" || $1 == "h" || $1 == "-h" || $1 == "--h"  ]]; then
printf """

  conda_configure - configure conda build tools and disable automatic upload to anaconda.org

  description:

    conda config --set always_yes yes
    conda config --add channels conda-forge
    conda config --set anaconda_upload no

- usage:
conda_configure

"""
else
  # disable interactive y/n prompts
  conda config --set always_yes yes
  # enable the Anaconda conda-forge and yeti-coolers python package organizations
  conda config --add channels conda-forge
  conda config --add channels yeti-coolers
  # move the defaults anaconda channel to the top of the list so it is the highest priority
	conda config --add channels defaults
	# disable automatic upload to the anaconda.org public channel
  conda config --set anaconda_upload no
fi
}

conda_install_build_tools () {
if [[ $1 == "help" || $1 == "--help" || $1 == "-help" || $1 == "h" || $1 == "-h" || $1 == "--h"  ]]; then
printf """

  conda_install_build_tools - install anaconda build tools

  description:

    conda install conda-build
    conda install anaconda-client

- usage:
conda_install_build_tools

"""
else
  conda install conda-build
  conda install conda-verify
  conda install anaconda-client
fi
}

conda_build_package () {
if [[ $1 == "help" || $1 == "--help" || $1 == "-help" || $1 == "h" || $1 == "-h" || $1 == "--h"  ]]; then
printf """

  conda_build_package - build source distribution, tar archive, wheel and conda package

  description:

    change to component home directory then execute
    conda build --debug --python ${PYTHON_VERSION_NUMBER} conda

  parameters - parameter values can not contain spaces, underscores or special characters and must be all lower case

  \$1 - CONFIG
        Operating system abbreviation underscore python version.
        Valid values
            linux_python2.7
            linux_python3.6
            linux_python3.7
            osx_python2.7
            osx_python3.6
            osx_python3.7
        Defaults to osx_python2.7
  \$2 - COMPONENT_HOME
        (Optional) Local file system directory path for the root of the component source code project.
        Defaults to ${COMPONENT_HOME}

- usage:
conda_build_package

"""
else

  CONF="${1-${CONFIG:-osx_python2.7}}"
  C_HOME="${2:-$COMPONENT_HOME}"

  pushd ${C_HOME}

  printf """


  conda_build_package:

       COMPONENT_HOME: ${C_HOME}
               CONFIG: ${CONF}

  conda build ./recipe -m ./.ci_support/${CONF}.yaml --clobber-file ./.ci_support/clobber_${CONF}.yaml



  """

  # source is downloaded from https://pypi.io/packages/source
  # build conda package
  conda build ./recipe -m ./.ci_support/${CONF}.yaml --clobber-file ./.ci_support/clobber_${CONF}.yaml

  popd

fi
}

conda_build_cleanup () {
if [[ $1 == "help" || $1 == "--help" || $1 == "-help" || $1 == "h" || $1 == "-h" || $1 == "--h"  ]]; then
printf """

  conda_build_cleanup - remove conda source and build intermediates files from ${CONDA_BLD_NS}

  description:
    conda build purge

- usage:
conda_build_cleanup

"""
else

  conda build purge

fi
}

conda_convert_package () {
if [[ $1 == "help" || $1 == "--help" || $1 == "-help" || $1 == "h" || $1 == "-h" || $1 == "--h"  ]]; then
printf """

  conda_convert_package - use the conda package built for the operating system of the container/machine running this script
                          to convert and build conda packages for use on multiple platforms

  description:

    change to component home directory then execute
    conda convert --force --platform all 'ls CONDA_BLD_NAMESPACE/OS/COMPONENT_NAME-COMPONENT_VERSION-PYTHON_INTERPRETER_VERSION_CONDA_BUILD.tar.bz2' -o CONDA_BLD_NAMESPACE/

  parameters - parameter values can not contain spaces, underscores or special characters and must be all lower case

  \$1 - COMPONENT_NAME
        String name of the component.  This should match the python package name.
  \$2 - COMPONENT_VERSION
        Component python package version.
  \$3 - PYTHON_INTERPRETER_VERSION
        (Optional) Short abbreviation of the python interpreter version used to build the conda package.
        Valid values
            py27
            py36
            py37
        Defaults to py27
  \$4 - CONDA_BUILD
        (Optional) Conda build number.  This number should be incremented when rebuilding an existing conda package.
        Defaults to 0
  \$5 - COMPONENT_HOME
        (Optional) Local file system directory path for the root of the component source code project.
        Defaults to ${COMPONENT_HOME}
- usage:
conda_convert_package

"""
else

  C_NAME="${1:-$COMPONENT_NAME}"
  C_VERSION="${2:-$COMPONENT_VERSION}"
  INTERPRETER="${3-${PYTHON_INTERPRETER_VERSION:-py27}}"
  C_BUILD="${4-${CONDA_BUILD:-0}}"
  C_HOME="${5:-$COMPONENT_HOME}"

  pushd ${C_HOME}

  # identify the operating system kernel of the container/machine running this script.
  if [[ `uname` == Darwin ]]; then
    LOCAL_OS=osx-64
  fi
  if [[ `uname` == Linux ]]; then
    LOCAL_OS=linux-64
  fi
  LOCAL_OS=noarch
  CONDA_PACKAGE_ARCHIVE="${CONDA_BLD_NS}/${LOCAL_OS}/${C_NAME}-${C_VERSION}-${INTERPRETER}_${C_BUILD}.tar.bz2"

  printf """

  conda_convert_package:

             COMPANY_NAMESPACE: ${COMPANY_NS}
                COMPONENT_NAME: ${C_NAME}
             COMPONENT_VERSION: ${C_VERSION}
                COMPONENT_HOME: ${C_HOME}
                   CONDA_BUILD: ${C_BUILD}
           CONDA_BLD_NAMESPACE: ${CONDA_BLD_NS}
         CONDA_PACKAGE_ARCHIVE: ${CONDA_PACKAGE_ARCHIVE}
                      LOCAL_OS: ${LOCAL_OS}
    PYTHON_INTERPRETER_VERSION: ${INTERPRETER}

  conda convert --force --platform all ${CONDA_PACKAGE_ARCHIVE} -o ${CONDA_BLD_NS}/


  """

  # use the conda package built for the operating system of the container/machine running this script
  # to convert and build conda packages for use on multiple platforms
  conda convert --force --platform all ${CONDA_PACKAGE_ARCHIVE} -o ${CONDA_BLD_NS}/

  popd

fi
}

conda_upload_package () {
if [[ $1 == "help" || $1 == "--help" || $1 == "-help" || $1 == "h" || $1 == "-h" || $1 == "--h"  ]]; then
printf """

  conda_upload_package - upload public conda packages to the https://anaconda.org/${COMPANY_NS}/ organization
                         for the following operating system kernels: osx-64 linux-64 linux-32 win-64 win-32

  description:

    change to component home directory then execute
    anaconda upload -u ${COMPANY_NS} --force 'ls ${CONDA_BLD_NS}/OS/COMPONENT_NAME-COMPONENT_VERSION-PYTHON_INTERPRETER_VERSION_CONDA_BUILD.tar.bz2'

  parameters - parameter values can not contain spaces, underscores or special characters and must be all lower case

  \$1 - COMPONENT_NAME
        String name of the component.  This should match the python package name.
  \$2 - COMPONENT_VERSION
        Component python package version.
  \$3 - PYTHON_INTERPRETER_VERSION
        (Optional) Short abbreviation of the python interpreter version used to build the conda package.
        Valid values
            py27
            py36
            py37
        Defaults to py27
  \$4 - CONDA_BUILD
        (Optional) Conda build number.  This number should be incremented when rebuilding an existing conda package.
        Defaults to 0
  \$5 - COMPONENT_HOME
        (Optional) Local file system directory path for the root of the component source code project.
        Defaults to ${COMPONENT_HOME}

- usage:
# upload the apache-airflow conda package version 1.10.1
# located in the default location for python 2.7 with a conda build number of 0
conda_upload_package apache-airflow 1.10.1

"""
else

  C_NAME="${1:-$COMPONENT_NAME}"
  C_VERSION="${2:-$COMPONENT_VERSION}"
  INTERPRETER="${3-${PYTHON_INTERPRETER_VERSION:-py27}}"
  C_BUILD="${4-${CONDA_BUILD:-0}}"
  C_HOME="${5:-$COMPONENT_HOME}"

  pushd ${C_HOME}

  # list of package os versions to upload to the company private https://anaconda.org organization
  OS_KERNELS=(osx-64 linux-64 linux-32 win-64 win-32)

  for OS in "${OS_KERNELS[@]}" ; do

    CONDA_PACKAGE_ARCHIVE="${CONDA_BLD_NS}/${OS}/${C_NAME}-${C_VERSION}-${INTERPRETER}_${C_BUILD}.tar.bz2"

    if [[ -f ${CONDA_PACKAGE_ARCHIVE} ]]; then
      printf """

      conda_upload_package

        anaconda upload -u ${COMPANY_NS} --force ${CONDA_PACKAGE_ARCHIVE}

      """
      anaconda upload -u ${COMPANY_NS} --force ${CONDA_PACKAGE_ARCHIVE}
    else
      printf """
      ${RED}
      ERROR - conda_upload_package: conda package not found: ${CONDA_PACKAGE_ARCHIVE}

                 COMPANY_NAMESPACE: ${COMPANY_NS}
                    COMPONENT_NAME: ${C_NAME}
                 COMPONENT_VERSION: ${C_VERSION}
                    COMPONENT_HOME: ${C_HOME}
                       CONDA_BUILD: ${C_BUILD}
               CONDA_BLD_NAMESPACE: ${CONDA_BLD_NS}
             CONDA_PACKAGE_ARCHIVE: ${CONDA_PACKAGE_ARCHIVE}
                                OS: ${OS}
        PYTHON_INTERPRETER_VERSION: ${INTERPRETER}

      anaconda upload -u ${COMPANY_NS} --force ${CONDA_PACKAGE_ARCHIVE}

      ${NO_COLOR}
      """
    fi
  done

  popd

fi
}

conda_shazam () {
if [[ $1 == "help" || $1 == "--help" || $1 == "-help" || $1 == "h" || $1 == "-h" || $1 == "--h"  ]]; then
printf """

  conda_shazam - Holy Anaconda Batman!  conda config, install, build, convert and upload all in one command!

  description:

    configure conda build tools and disable automatic upload to anaconda.org
    install anaconda build tools
    build source distribution, tar archive, wheel and conda package
    convert conda package for use on multiple platforms
    upload conda package to https://anaconda.org/${COMPANY_NAMESPACE}/ private organization

- usage:
conda_shazam

"""
else

  conda_configure
  conda_install_build_tools
  conda_build_package
  conda_convert_package
  conda_upload_package

fi
}

docker_log_status () {
if [[ $1 == "help" || $1 == "--help" || $1 == "-help" || $1 == "h" || $1 == "-h" || $1 == "--h"  ]]; then
printf """

  docker_log_status - Convenience function to log docker build and push command status.

  status values supported:
    - build
    - push
    - complete

- usage:
docker_log_status \"status\"

# Log to the console that a docker build command is starting
docker_log_status \"build\"

# Log to the console that a docker push command is starting
docker_log_status \"push\"

# Log to the console that the docker build and push command has completed
docker_log_status \"complete\"

"""
fi
if [[ $1 == "build" ]]; then
printf """

    $1ing ${BUILD_CMD}

"""
fi
if [[ $1 == "push" ]]; then
printf """

    ${BUILD_CMD} build complete
    $1ing ${DOCKER_IMAGE}:${__version__}

"""
fi
if [[ $1 == "complete" ]]; then
printf """

    ${DOCKER_IMAGE}:${__version__} push complete


"""
fi
}

docker_build_and_push () {
if [[ $1 == "help" || $1 == "--help" || $1 == "-help" || $1 == "h" || $1 == "-h" || $1 == "--h"  ]]; then
printf """

  docker_build_and_push - Build and push docker image to GitLab repository and Google repository.

- usage:
docker_build_and_push

"""
else

# GitLab
DOCKER_REGISTRY="${GITLAB_DOCKER_REGISTRY}"
GITLAB_GROUP="${COMPANY_NAMESPACE}/${DOCKER_NAMESPACE}/${ENV}"
# set IMAGE_NAME to GitLab project name which is the name of the current directory
export IMAGE_NAME=$(basename "$PWD")
DOCKER_IMAGE=${DOCKER_REGISTRY}/${GITLAB_GROUP}/${IMAGE_NAME}
export GIT_COMMIT_SHA="$(git rev-parse --short HEAD)"
BUILD_CMD="${DOCKER_IMAGE} --tag ${__version__} --tag ${GIT_COMMIT_SHA}"
docker_log_status "build"
docker build -t ${BUILD_CMD} .
docker_log_status "push"
docker push ${DOCKER_IMAGE}:${__version__}
docker_log_status "complete"

# GCP
DOCKER_REGISTRY="${GCP_US_DOCKER_REGISTRY}"
DOCKER_IMAGE=${DOCKER_REGISTRY}/${GCP_PROJECT}/${IMAGE_NAME}
BUILD_CMD="${DOCKER_IMAGE} --tag ${__version__} --tag ${GIT_COMMIT_SHA}"
docker_log_status "build"
docker build -t ${BUILD_CMD} .
docker_log_status "push"
docker push ${DOCKER_IMAGE}:${__version__}
docker_log_status "complete"

fi
}

gcloud_auth_application_default () {
if [[ $1 == "help" || $1 == "--help" || $1 == "-help" || $1 == "h" || $1 == "-h" || $1 == "--h"  ]]; then
printf """

  gcloud_auth_application_default - Authenticate as the application default login

- usage:
gcloud_auth_application_default

"""
else
  gcloud auth application-default login
fi
}

gcloud_authenticate () {
if [[ $1 == "help" || $1 == "--help" || $1 == "-help" || $1 == "h" || $1 == "-h" || $1 == "--h"  ]]; then
printf """

  gcloud_authenticate - Activate default compute service account

- usage:
gcloud_authenticate

"""
else
  gcloud --quiet auth activate-service-account --key-file ${HOME}/.config/gcloud/${GCP_PROJECT}-compute.json --project=${GCP_PROJECT}
fi
}

gcloud_authenticate_docker () {
if [[ $1 == "help" || $1 == "--help" || $1 == "-help" || $1 == "h" || $1 == "-h" || $1 == "--h"  ]]; then
printf """

  gcloud_authenticate_docker - Configure Google Cloud docker repositories

- usage:
gcloud_authenticate_docker

"""
else
  # configure Google Docker container registries
  gcloud --quiet auth configure-docker
fi
}

gcloud_install () {
if [[ $1 == "help" || $1 == "--help" || $1 == "-help" || $1 == "h" || $1 == "-h" || $1 == "--h"  ]]; then
printf """

  gcloud_install - Install Google Cloud SDK and Authenticate to private GitLab Docker Registry

  IMPORTANT - if this command fails you probably do not have the GITLAB_DOCKER_REGISTRY_TOKEN environment variable setup which stores the personal access token.
              This token value is excluded from source control on purpose, security tokens should not be committed to source control.
              You can copy the token value from the DOCKER_AUTH_CONFIG GitLab yeti-coolers CI/CD variable located here:
                https://gitlab.com/groups/yeti-coolers/-/settings/ci_cd

  description:
    - if gcloud is not installed (or on the path), wget install gcloud cli
    - Apply any outstanding gcloud cli software updates (just in case)
    - if gcloud .json credential file does not exists create it
    - if GitLab Docker Registry authentication .json file does not exists create it

- usage:
gcloud_install

"""
else

GCLOUD_PATH="google-cloud-sdk/bin"
if [[ ${PATH} != *${GCLOUD_PATH}* ]]; then
  echo "installing gcloud"
  # Download and install Google Cloud SDK
  wget https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz
  tar zxvf google-cloud-sdk.tar.gz && ./google-cloud-sdk/install.sh --usage-reporting=false --path-update=true
  PATH="${GCLOUD_PATH}:${PATH}"
fi

# apply any outstanding gcloud cli software updates (just in case)
gcloud --quiet components update
# enable beta required by some terraform google provider resources
# gcloud --quiet components install beta

if [[ ! -f ${GOOGLE_APPLICATION_CREDENTIALS} ]]; then
  echo "creating gcp credentials file"
  # Authenticate as Compute Engine default service
  # credentials are a GitLab CI/CD variable stored here: https://gitlab.com/groups/yeti-coolers/-/settings/ci_cd
  # create the default gcloud configuration directory ~/.config/gcloud
  # NOTE: the credentials file below needs to exist at the same path on your laptop
  mkdir -p ${HOME}/.config
  mkdir -p ${HOME}/.config/gcloud
  # GCE_SERVICE_ACCOUNT_CREDENTIALS is a GitLab user defined CI/CD Variables
  echo ${GCE_SERVICE_ACCOUNT_CREDENTIALS?${MANY_STARS} GCE_SERVICE_ACCOUNT_CREDENTIALS is a GitLab user defined CI/CD Variable is not set ${MANY_STARS}} > ${HOME}/.config/gcloud/${GCP_PROJECT}-compute.json
  ls -la ${HOME}/.config/gcloud/
fi

# Authenticate to private GitLab Docker Registry (required for stage image: source)
# see: https://docs.gitlab.com/ce/ci/docker/using_docker_images.html#define-an-image-from-a-private-container-registry
DOCKER_CONFIG_JSON="$HOME/.docker/config.json"
if [[ ! -f ${DOCKER_CONFIG_JSON} ]]; then
  echo "creating GitLab Docker Registry authentication file: ${DOCKER_CONFIG_JSON}"
  mkdir -p $HOME/.docker
  DOCKER_AUTH_CONFIG=```echo '{
   "auths": {
       "registry.gitlab.com": {
           "auth": "'${GITLAB_DOCKER_REGISTRY_TOKEN?${MANY_STARS} Is not set ${MANY_STARS}}'"
       }
   }
}'```
echo "$DOCKER_AUTH_CONFIG" >> "${DOCKER_CONFIG_JSON}"
fi

fi
}

gcloud_configure () {
if [[ $1 == "help" || $1 == "--help" || $1 == "-help" || $1 == "h" || $1 == "-h" || $1 == "--h"  ]]; then
printf """

  gcloud_configure - Configure gcloud cli and service API(s)

  description:
    - initialize GCLOUD_CORE_ACCOUNT environment variable with the gcloud authenticated user
    - configure gcloud cli default values (project, region, zone)
    - enable service API(s)

- usage:
gcloud_configure


"""
else

  # initialize environment variable with the gcloud authenticated user
  export GCLOUD_CORE_ACCOUNT=$(gcloud config get-value core/account)

  # configure gcloud cli default values
  gcloud config set project ${GCP_PROJECT}
  gcloud config set compute/region ${GCP_REGION}
  gcloud config set compute/zone ${GCP_ZONE}

fi
}

gcloud_configure_ssh () {
if [[ $1 == "help" || $1 == "--help" || $1 == "-help" || $1 == "h" || $1 == "-h" || $1 == "--h"  ]]; then
printf """

  gcloud_configure_ssh - Configure gcloud compute ssh

- usage:
gcloud_configure_ssh

"""
else
  GCP_SSH_KEY="${HOME}/.ssh/google_compute_engine"

  if [[ ! -f "${GCP_SSH_KEY}" ]]; then
    gcloud compute config-ssh
    ssh-add ~/.ssh/google_compute_engine
  fi
  printf """ gcloud ${GCP_SSH_KEY} ssh key configured  """
fi
}

gcs_bucket_label () {
if [[ $1 == "help" || $1 == "--help" || $1 == "-help" || $1 == "h" || $1 == "-h" || $1 == "--h"  ]]; then
printf """

  gcs_bucket_label - Label Google Cloud Storage bucket owner and purpose for audit and billing.

  parameters - parameter values can not contain spaces, underscores or special characters and must be all lower case

  \$1 - GCS_BUCKET_NAME
        Name of the Google Cloud Storage bucket to label
        Do not include gs://
  \$2 - APP
        Name of the GitLab Project
  \$3 - APP_NAMESPACE
        Name of the GitLab Group the GitLab Project is in.
        Defaults to yeti-dataflow
  \$4 - PROJECT
        Name of the business project funding the work.
        Defaults to 2019-architectural-analysis
  \$5 - TECHNOLOGY_LIFECYCLE
        Company overall direction on the technology being used.
        assess, adopt, ...
        Defaults to adopt
  \$6 - TIER
        Level of support required with tier1 being production revenue impacting
        tier1, tier2 or tier3
        Defaults to tier1
  \$7 - CONTACT
        Name of the Company employee that should be contacted regarding the labeled resource.
        Defaults to adam-cox

- usage:
gcs_bucket_label yeti-dev-data dataflow-templates


"""
else
  APP="${2:-JdbcToBigQuery}"
  APP_NAMESPACE="${3:-yeti-dataflow}"
  PROJECT="${4:-2019-architectural-analysis}"
  TECHNOLOGY_LIFECYCLE="${5:-adopt}"
  TIER="${6:-tier1}"
  CONTACT="${7:-adam-cox}"
  # label the bucket owner and purpose
  gsutil label ch -l contact:${CONTACT} gs://$1/
  gsutil label ch -l department:${DEPARTMENT} gs://$1/
  gsutil label ch -l environment:${ENV} gs://$1/
  gsutil label ch -l gitlab-group:${COMPANY_NAMESPACE}_${APP_NAMESPACE}_${ENV} gs://$1/
  gsutil label ch -l gitlab-project:${APP} gs://$1/
  gsutil label ch -l project-name:${PROJECT} gs://$1/
  gsutil label ch -l technology-lifecycle:${TECHNOLOGY_LIFECYCLE} gs://$1/
  gsutil label ch -l tier:${TIER} gs://$1/
fi
}

git_fetch_projects () {
if [[ $1 == "help" || $1 == "--help" || $1 == "-help" || $1 == "h" || $1 == "-h" || $1 == "--h"  ]]; then
printf """

  git_fetch_projects -  Recursively bring the GitLab projects in the supplied directory up to date with 'origin/master'.
                        This function displays the current git status and fetches remote changes
                        for all the GitLab Projects / GitHub Repos in the supplied directory
                        or when not supplied the parent directory of the current directory

                        Projects/repos with Changes not staged for display a message instructing the user
                        to 'git add <file>...' to update what will be committed
                        or to 'git checkout -- <file>...' to discard changes in the working directory.

  parameters
  \$1 - GIT_PROJECTS_DIR
        Directory containing the GitLab Projects / GitHub Repos to bring up to date with 'origin/master'
        (defaults to the parent directory of the current directory)

- usage:
# change one directory up and bring all the GitLab projects up to date with 'origin/master'
git_fetch_projects

# change to the /gitlab/src/yeti-coolers/yeti-terraform/dev directory located in the
# current users home directory and bring all the GitLab projects up to date with 'origin/master'
git_fetch_projects ${HOME}/gitlab/src/yeti-coolers/yeti-terraform/dev

"""
else

  GIT_PROJECTS_DIR="${1:-../}"

  pushd ${GIT_PROJECTS_DIR} # change to the supplied directory or when not supplied change to parent directory

  REPOSITORIES=`pwd`
  printf """

  git_fetch_projects

      Bringing all GitLab projects in ${REPOSITORIES} up to date with 'origin/master'.

  """

  IFS=$'\n'

  for REPO in `ls "${REPOSITORIES}/"`
  do
    if [[ -d "${REPOSITORIES}/${REPO}" ]]
    then
      if [[ -d "${REPOSITORIES}/${REPO}/.git" ]]
      then
        pushd "${REPOSITORIES}/${REPO}" # change to GitLab Project directory
        printf """



        Updating: ${REPO}

"""
        git status
        if ! git diff-index --quiet HEAD --; then
          printf """

              git_fetch_projects - WARNING
                  - ${REPO} - Working directory Git repo not clean

              To not see this message in the future
              clean the working directory by adding
              outstanding changes to the index (git add .)
              and committing (git commit) before executing git_fetch_projects

              ${REPO} - NOT UPDATED

          """
        else
          # working directory is clean with no outstanding changes, safe to get latest version from origin/master
#          echo "Fetching"
#          git fetch
#          sleep 1 # pause for 1 second before executing the next git command so GitLab Rate Limiting rules do not fail the ssh request
          echo "Pulling"
          git pull
          sleep 1 # pause for 1 second before executing the next git command so GitLab Rate Limiting rules do not fail the ssh request
          echo "Updating submodules"
           # check if submodule needs updating, -z string True if the string is null (an empty string)
          if ! [[ -z "$(git submodule update --recursive --remote)" ]]; then
            echo "bash-utils submodule updated, committing and pushing submodule changes"
            git add bash-utils
            git commit -m "updating submodule"
            git push
          fi
        fi
        popd # change back to repositories directory
        sleep 5 # pause for 5 seconds before executing the next git command so GitLab Rate Limiting rules do not fail the ssh request
      else
        echo "Skipping ${REPO} because it does not have a .git folder."
      fi
      echo "Done at `date`"

    fi
  done

  popd # change back to the directory you were in before changing to the conda build directory

fi
}

gitlab_ci_setup () {
if [[ $1 == "help" || $1 == "--help" || $1 == "-help" || $1 == "h" || $1 == "-h" || $1 == "--h"  ]]; then
printf """

  gitlab_ci_setup - GitLab CI/CD, install and configure gcloud cli

  description:
    - Initialize environment variables
    - Authenticate as Compute Engine default service
    - Apply any outstanding gcloud cli software updates (just in case)
    - Configure Google Docker container registries
    - gcloud_configure
        - Configure gcloud cli default values (project, region, zone)

- usage:
gitlab_ci_setup


"""
else
  # install google cloud sdk
  # create json credentials file
  gcloud_install

  # Authenticate as Compute Engine default service
  gcloud_authenticate

  gcloud_configure

fi
}

gke_configure () {
if [[ $1 == "help" || $1 == "--help" || $1 == "-help" || $1 == "h" || $1 == "-h" || $1 == "--h"  ]]; then
printf """

  gke_configure - Initialize GKE node_tag and gke_instance_group_uri environment variables

  description:
    - gcloud container clusters get-credentials ${GKE_CLUSTER} --zone ${GCP_ZONE}

- usage:
gke_configure


"""
else
  gcloud container clusters get-credentials ${GKE_CLUSTER} --zone ${GCP_ZONE}
#  export ingress_load_balancer_ip=$(kubectl get svc --namespace=default nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
fi
}

docker_shazam () {
if [[ $1 == "help" || $1 == "--help" || $1 == "-help" || $1 == "h" || $1 == "-h" || $1 == "--h"  ]]; then
printf """

  docker_shazam - Holy Docker Batman!  docker build, push, git tag and commit it all in one command

  description:
    - GitLab CI/CD, install and configure gcloud cli
        gitlab_ci_setup
    - Build and push docker image to GitLab repository and Google repository.
        docker_build_and_push

- usage:
docker_shazam

"""
else
  gitlab_ci_setup
  # Authenticate to GCP Docker container registries
  gcloud_authenticate_docker
  docker_build_and_push
fi
}

terraform_install () {
if [[ $1 == "help" || $1 == "--help" || $1 == "-help" || $1 == "h" || $1 == "-h" || $1 == "--h"  ]]; then
printf """

  terraform_install - Configure environment to use the latest version of Terraform

  description:
    - if not installed, use curl to download latest version of Terraform into the users HOME directory
    - source .bashrc

- usage:
terraform_install

"""
else
  curl -sL https://goo.gl/yZS5XU | bash
  source ${HOME}/.bashrc
fi
}

terraform_tfvars () {
if [[ $1 == "help" || $1 == "--help" || $1 == "-help" || $1 == "h" || $1 == "-h" || $1 == "--h"  ]]; then
printf """

  terraform_tfvars - Create terraform.tfvars file used to populate Terraform input variable values

  description:
    - create terraform.tfvars
    - ensure required variable values are set

- usage:
terraform_tfvars

"""
else
#  Configure gcloud cli and service API(s)
gcloud_configure

rm -rf terraform.tfvars

cat > terraform.tfvars <<EOF
company_name        = "${COMPANY_NAME?${MANY_STARS} Is not set ${MANY_STARS}}"
gcloud_core_account = "${GCLOUD_CORE_ACCOUNT?${MANY_STARS} Is not set ${MANY_STARS}}"
gcp_project         = "${GCP_PROJECT?${MANY_STARS} Is not set ${MANY_STARS}}"
gcp_project_num     = "${GCP_PROJECT_NUM?${MANY_STARS} Is not set ${MANY_STARS}}"
gcp_region          = "${GCP_REGION?${MANY_STARS} Is not set ${MANY_STARS}}"
gcp_zone            = "${GCP_ZONE?${MANY_STARS} Is not set ${MANY_STARS}}"
gke_cluster         = "${GKE_CLUSTER?${MANY_STARS} Is not set ${MANY_STARS}}"
gke_cluster_domain  = "${GKE_CLUSTER_DOMAIN?${MANY_STARS} Is not set ${MANY_STARS}}"
network             = "${NETWORK?${MANY_STARS} Is not set ${MANY_STARS}}"
subnet              = "${SUBNET?${MANY_STARS} Is not set ${MANY_STARS}}"
top_level_domain    = "${TOP_LEVEL_DOMAIN?${MANY_STARS} Is not set ${MANY_STARS}}"
gce_service_account = "${GCE_SERVICE_ACCOUNT?${MANY_STARS} Is not set ${MANY_STARS}}"
EOF

cat terraform.tfvars
fi
}

terraform_init () {
if [[ $1 == "help" || $1 == "--help" || $1 == "-help" || $1 == "h" || $1 == "-h" || $1 == "--h"  ]]; then
printf """

  terraform_init - shazam scared?  terraform_init to see the terraform plan but not apply

  description:
    - initialize the working directory and download and install terraform modules
        terraform init -backend=true -get=true -input=false
    - create a plan for changing resources to match the current configuration and save it to the local file terraform.tfplan
        terraform plan -out=terraform.tfplan -input=false

- usage:
terraform_init

"""
else
  # initialize the working directory
  # Download and install terraform modules
  terraform init -backend=true -get=true -input=false
  # create "terraform.tfplan" file
  # plan for changing resources to match the current configuration
  terraform plan -out=terraform.tfplan -input=false
fi
}

terraform_shazam () {

if [[ $1 == "help" || $1 == "--help" || $1 == "-help" || $1 == "h" || $1 == "-h" || $1 == "--h"  ]]; then
printf """

  terraform_shazam - Holy Terraform Batman!  Terraform it all in one command

  description:
    - initialize the working directory and ownload and install terraform modules
        terraform init -backend=true -get=true -input=false
    - create a plan for changing resources to match the current configuration and save it to the local file terraform.tfplan
        terraform plan -out=terraform.tfplan -input=false
    - apply the plan stored in the file terraform.tfplan
        terraform apply -input=false terraform.tfplan

- usage:
terraform_shazam

"""
else
  # initialize the working directory
  # Download and install terraform modules
  terraform init -backend=true -get=true -input=false

  # create "terraform.tfplan" file
  # plan for changing resources to match the current configuration
  terraform plan -out=terraform.tfplan -input=false

  # apply the exact commands you exported to terraform.tfplan
  terraform apply -input=false terraform.tfplan
fi
}

yaml_file_parse () {
if [[ $1 == "help" || $1 == "--help" || $1 == "-help" || $1 == "h" || $1 == "-h" || $1 == "--h"  ]]; then
printf """

  yaml_file_parse - Parse well behaved yaml files and create lower case environment variables (name and value both all lower case)

  parameters
  \$1 - YAML_FILE_PATH

  description:
    - parse yaml file and create environment variables
    - yaml file CAN ONLY BE ONE LEVEL DEEP
    - yaml keys should be lower case with no dashes, spaces or periods
    - yaml key should be delimited from value by a colon and 1 space like so ': ' without the single quotes
    - yaml file path should be relative to the directory this script is in, sourced from or fully qualified
    - yaml values containing colons should be enclosed in double quotes like so \"jdbc:sqlserver://yetidb01.database.windows.net:1433;databaseName=yetisqldw01\"

- usage:
yaml_file_parse <YAML_FILE_PATH>


"""
else

if [[ -f "$1" ]]
then
  echo "yaml_file_parse:  found $1 beginning parse"

  while IFS=': ' read -r key value
  do
    # remove double quotes from value if/when they exists
    value="${value%\"}"
    value="${value#\"}"
    # BigQuery write disposition and jdbc driver class name are case sensitive

#    if [[ "${key}" != "dataflow_template_java_class_name" && "${key}" != "footer_regex" && "${key}" != "driver_class_name" && "${key}" != "header_regex" && "${key}" != "input_file_section_regex" && "${key}" != "text_row_regex_filter" && "${key}" != "text_row_starts_with_list_filter" && "${key}" != "header_starts_with_list" && "${key}" != "write_disposition" ]]; then
#      # convert key and value to lower all lower case
#      key=`echo ${key} | tr '[:upper:]' '[:lower:]'`
#      value=`echo ${value} | tr '[:upper:]' '[:lower:]'`
#    fi
    echo "exporting: ${key}=${value}"
    export ${key}=${value}
  done < "$1"

else
  echo "yaml_file_parse:  $1 not found."
fi
fi
}

# --------------------------------------------------------------------------------
# usage documentation
# --------------------------------------------------------------------------------
if [[ $1 == "help" || $1 == "--help" || $1 == "-help" || $1 == "h" || $1 == "-h" || $1 == "--h"  ]]; then
printf """
--------------------------------------------------------------------------------
usage documentation:

  ./bash_util.sh -h

  parameters
  \$1 - help
        valid values: help, --help, -help, h, --h, -h

usage:
- display bash_util usage documentation:
./bash_util.sh -h

- load bash_util script functions into memory:
source bash_util.sh

- display usage documentation for a specific function:
-     <function_name> -h
conda_shazam -h

"""
bump_version -h
conda_configure -h
conda_install_build_tools -h
conda_build_package -h
conda_build_cleanup -h
conda_convert_package -h
conda_upload_package -h
conda_shazam -h
docker_log_status -h
docker_build_and_push -h
docker_shazam -h
gcloud_auth_application_default -h
gcloud_authenticate -h
gcloud_authenticate_docker -h
gcloud_install -h
gcloud_configure -h
gcloud_configure_ssh -h
gcs_bucket_label -h
git_fetch_projects -h
gitlab_ci_setup -h
gke_configure -h
pip_build_package
terraform_install -h
terraform_tfvars -h
terraform_init -h
terraform_shazam -h
yaml_file_parse -h

fi
