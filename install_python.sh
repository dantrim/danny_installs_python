#!/bin/bash

##
## Script to install CPython from source on your machine.
## Adapted from Matthew M. Feickert: https://github.com/matthewfeickert/Docker-Python3-Ubuntu.
##
## author: Daniel Joseph Antrim
## e-mail: dantrim1023@gmail.com
## date: May 2020
##

default_python_version_tag=3.8.2
default_optimized=0
default_lto=0
#default_prefix=${PWD}/Python-${default_python_version_tag}

RED='\033[0;31m'
NC='\033[0m' # No Color

function print_usage {
    echo "---------------------------------------------------------"
    echo " install CPython from source"
    echo ""
    echo " This script will download and install CPython for you."
    echo " It installs the python version of your choice, with"
    echo " pip as well."
    echo ""
    echo " Usage:"
    echo "   $ source install_python.sh [OPTIONS]"
    echo ""
    echo " Options:"
    echo "  -v   Python version [default: ${default_python_version_tag}]"
    echo "  -o   Enable optimized installation"
    echo "           This corresponds to the CPython configuration flag"
    echo "           \"--enable-optimizations\""
    echo "           [default: false]"
    echo "  -l   Enable link-time-optimization (lto)"
    echo "           This corresponds to the CPython configuration flag \"--with-lto\""
    echo "           and providing this flag may not work on every build system."
    echo "           If providing this flag, and installation fails, try again"
    echo "           without providing it."
    echo "           [default: false]"
    echo "" 
    echo "---------------------------------------------------------"
}

function download_cpython {
    # 1: python version tag
    printf "\n### Downloading CPython source as Python-%s.tgz\n" "${1}"
    wget "https://www.python.org/ftp/python/${1}/Python-${1}.tgz" &> /dev/null

    if [ ! -f "Python-${1}.tgz" ]; then
        printf "\n### Failed to download CPython\n"
        return 1
    fi
    tar -xzf "Python-${1}.tgz"
    if [ ! -d "Python-${1}" ]; then
        printf "\n### Failed to download CPython\n"
        return 1
    fi
    return 0
}

function has_wget {
    if ! command -v wget 2>&1 >/dev/null ; then
        printf "\n### ERROR You do not have \"wget\", please install it\n"
        return 1
    fi
    return 0
}

function set_num_processors {

    # Set the number of processers used for build to be 
    # 1 less than are available

    NPROC=1
    if [[ -f "$(command -v nproc)" ]]; then
        NPROC="$(nproc)"
        NPROC="$((NPROC - 1))"
    elif [[ -f "$(command -v sysctl)" ]]; then
        NPROC="$(sysctl -n hw.ncpu)" # macOS
        NPROC="$((NPROC - 1))"
    elif [[ -f "/proc/cpuinfo" ]]; then
        NPROC="$(grep -c '^processor' /proc/cpuinfo)"
        NPROC="$((NPROC - 1))"
    fi

    echo "$((NPROC))"
}

function version {
    # from: https://stackoverflow.com/questions/4023830/how-to-compare-two-strings-in-dot-separated-version-format-in-bash
    echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }';
}

function build_cpython {

    # 1: version tag
    # 2: installation prefix
    # 3: flag for optimized build
    # 4: enable link-time-optimization (LTO)
    # 5: number of processor cores to use for compilation

    printf "\n### Installing Python-${1} with prefix=${2}\n"

    configure_options="--prefix=${2} \
        --exec_prefix=${2} \
        --enable-loadable-sqlite-extensions \
        --with-ensurepip=install \
        --enable-ipv6"

    if [ ${3} -eq 1 ]; then
        configure_options="${configure_options} --enable-optimizations "
    fi

    if [ ${4} -eq 1 ]; then
        configure_options="${configure_options} --with-lto "
    fi

    # --with-threads is removed in Python 3.7 (threading already on)
    if [ $(version ${1}) -lt $(version "3.7.0") ]; then
        configure_options="${configure_options} --with-threads "
    fi

    printf "\n### Configuring: ${configure_options}\n"
    ./configure ${configure_options} 2>&1 |tee configure_step.log

    printf "\n### make -j%s\n" "${5}"
    #if [ "$(uname)" == "Darwin" ]; then
    #    export LDFLAGS="-L/usr/local/opt/sqlite/lib"
    #    export CPPFLAGS="-I/usr/local/opt/sqlite/include"
    #    export CFLAGS="-I/usr/local/opt/sqlite/include"
    #fi
    make -j"${5}" 2>&1 |tee make_step.log
    status=$?
    if [[ $status -gt 0 ]] ; then
        printf "\n### Failed to make\n"
        return 1
    fi
    printf "\n### make install\n"
    make install 2>&1 |tee make_install_step.log
    status=$?
    if [[ $status -gt 0 ]]; then
        printf "\n### Failed to make install\n"
        return 1
    fi

    if [[ ! -f ${2}/bin/python3 ]]; then
        printf "\n### Failed to find python executable\n"
        return 1
    fi

    return 0
}

function update_pip {

    # 1: install prefix

    #if [[ ! -d ${1}/bin/ ]]; then
    #    printf "\n### ERROR No ${1}/bin/ directory\n"
    #    return 1
    #fi

    #if [[ ! -f ${1}/bin/pip3 ]]; then
    #    printf "\n### ERROR No pip3 found in ${1}/bin/\n"
    #    return 1
    #fi

    cmd="pip3 install --user --upgrade --no-cache-dir pip setuptools wheel"
    if [[ "$(id -u)" -eq 0 ]]; then
        cmd="pip3 install --upgrade --no-cache-dir pip setuptools wheel"
    fi
    printf "\n### ${cmd}\n"
    $cmd

    return 0
}

function main {

    PYTHON_VERSION_TAG=${default_python_version_tag}
    OPTIMIZED_BUILD=${default_optimized}
    WITH_LTO=${default_lto}

    while test $# -gt 0
    do
        case $1 in
            -h)
                print_usage
                return 0
                ;;
            -v)
                PYTHON_VERSION_TAG=${2}
                shift
                ;;
            -o)
                OPTIMIZED_BUILD=1
                ;;
            -p)
                INSTALL_PREFIX=${2}
                shift
                ;;
            -l)
                WITH_LTO=${2}
                shift
                ;;
            *)
                printf "\n### ERROR Invalid argument provided: $1\n"
                return 1
                ;;
        esac
        shift
    done

    INSTALL_PREFIX=${PWD}/Python-${PYTHON_VERSION_TAG}

    if ! has_wget ; then
        return 1
    fi

    if ! download_cpython ${PYTHON_VERSION_TAG}; then
        return 1
    fi

    pushd Python-${PYTHON_VERSION_TAG}

    NPROC="$(set_num_processors)" 
    printf "\n### Setting number of processors for build to: ${NPROC}\n"

    if ! build_cpython ${PYTHON_VERSION_TAG} ${INSTALL_PREFIX} ${OPTIMIZED_BUILD} ${WITH_LTO} ${NPROC}; then
        return 1
    fi

    if ! update_pip ${INSTALL_PREFIX} ; then
        return 1
    fi

    pyex=${INSTALL_PREFIX}/bin/python3
    printf "${NC}================================================================="
    printf "\n### Python-${PYTHON_VERSION_TAG} executable location:\n${pyex}\n"
    printf "\n### pip is available via python:\n$ python -m pip\n"
    printf "### ${RED}You must alias your \"python3\" command to the above location, e.g.:\n${NC}"
    printf "${RED}$ echo \"alias python=${pyex}\" >> ~/.bashrc ${NC}\n"
    printf "${NC}================================================================="

    popd
    return 0
}

#______________________________
main $*
