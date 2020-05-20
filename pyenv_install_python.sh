#!/bin/bash

##
## Script to install CPython from source on your machine.
##
## author: Daniel Joseph Antrim
## e-mail: dantrim1023@gmail.com
## date: May 2020
##

default_python_version_tag=3.8.2
default_optimized=0
default_lto=0

RED='\033[0;31m'
NC='\033[0m' # No Color

function print_usage {
    echo "---------------------------------------------------------"
    echo " install CPython from source, using pyenv"
    echo ""
    echo " This script will download and install CPython for you."
    echo " It installs the python version of your choice, with"
    echo " pip as well."
    echo ""
    echo " Usage:"
    echo "   $ source pyenv_install_python.sh [OPTIONS]"
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
    echo " References:"
    echo "  pyenv: https://github.com/pyenv/pyenv"
    echo "  realpython: https://realpython.com/intro-to-pyenv"
    echo "---------------------------------------------------------"
}

function has_pyenv {

    if ! command -v pyenv 2>&1 >/dev/null ; then
        printf "\n### ERROR You do not have \"pyenv\", please install it\n"
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

function install_python {
    # 1: python version tag
    # 2: optimized build
    # 3: with lto
    # 4: number of processor cores to use for compilation

    CONFIGURE_OPTS="--enable-shared --enable-loadable-sqlite-extensions --enable-ipv6"

    if [ ${2} -eq 1 ]; then
        CONFIGURE_OPTS="${CONFIGURE_OPTS} --enable-optimizations "
    fi

    if [ ${3} -eq 1 ]; then
        CONFIGURE_OPTS="${CONFIGURE_OPTS} --with-lto "
    fi

    # --with-threads is removed in Python 3.7 (threading already on)
    if [ $(version ${1}) -lt $(version "3.7.0") ]; then
        CONFIGURE_OPTS="${CONFIGURE_OPTS} --with-threads "
    fi


    MAKE_OPTS="-j${4}"

    printf "\n### CONFIGURE_OPTS=${CONFIGURE_OPTS}\n"
    printf "\n###MAKE_OPTS=${MAKE_OPTS}\n"

    MAKE_OPTS="${MAKE_OPTS}" \
        CONFIGURE_OPTS="${CONFIGURE_OPTS}" \
        pyenv install -v ${1}
    status=$?
    if [ ! ${status} -eq 0 ]; then
        return 1
    fi
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
            -l)
                WITH_LTO=1
                ;;
            *)
                printf "\n### ERROR Invalid argument provided: $1\n"
                return 1
                ;;
        esac
        shift
    done

    if ! has_pyenv ; then
        return 1
    fi

    NPROC="$(set_num_processors)" 
    if ! install_python ${PYTHON_VERSION_TAG} ${OPTIMIZED_BUILD} ${WITH_LTO} ${NPROC}; then
        return 1
    fi
    
    printf "${NC}=================================================================\n"
    printf "### Python-${PYTHON_VERSION_TAG} installed with pyenv\n"
    printf "### Current listing of python versions\n### pyenv versions\n"
    pyenv versions
    printf "${NC}=================================================================\n"
    return 0
}

#______________________________
main $*
