#!/bin/bash
#set -e
default_python_version_tag=3.8.2
default_optimized=0
default_prefix=${PWD}

function print_usage {
    printf "\nUsage...\n"
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

function version {
    # from: https://stackoverflow.com/questions/4023830/how-to-compare-two-strings-in-dot-separated-version-format-in-bash
    echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }';
}

function build_cpython {
    # 1: version tag
    # 2: flag for optimized build
    # 3: installation prefix

    printf "\n### Installing Python-${1} with prefix=${3}\n"

    configure_options="--prefix=${3} \
        --exec_prefix=${3} \
        #--with-lto \
        --enable-loadable-sqlite-extensions \
        --with-ensurepip=install \
        --enable-ipv6"

    if [ ${2} -eq 1 ]; then
        configure_options="${configure_options} --enable-optimizations "
    fi

    # --with-threads is removed in Python 3.7 (threading already on)
    if [ $(version ${1}) -lt $(version "3.7.0") ]; then
        configure_options="${configure_options} --with-threads "
    fi

    printf "\n### Configuring: ${configure_options}\n"
    ./configure ${configure_options}

#ensurepip, enable-optimizations

    printf "\n### make -j2\n"
    make -j2
    printf "\n### make -j2 test\n"
    make -j2 test
    printf "\n### make install\n"
    make install
}

function main {

    PYTHON_VERSION_TAG=${default_python_version_tag}
    OPTIMIZED_BUILD=${default_optimized}
    INSTALL_PREFIX=${default_prefix}

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
            *)
                printf "\n### ERROR Invalid argument provided: $1\n"
                return 1
                ;;
        esac
        shift
    done

    if ! has_wget ; then
        return 1
    fi

    if ! download_cpython ${PYTHON_VERSION_TAG}; then
        return 1
    fi

    pushd Python-${PYTHON_VERSION_TAG}

    #if ! build_cpython ${PYTHON_VERSION_TAG} ${OPTIMIZED_BUILD} ${INSTALL_PREFIX}; then
    #    return 1
    #fi

    popd
    
}

#______________________________
main $*
