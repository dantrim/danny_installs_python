# danny_installs_python
This is how you install `python` (>=3) from source.

## Pre-requisites
Prior to installing python, `python` itself requires several external dependencies if you wish to have a complete installation.
The external dependencies are detailed in the [python docs](https://devguide.python.org/setup/#build-dependencies).

You can install all necessary `python` dependencies for your architecture by following the steps outlined below:

### Linux (rhel, centos)
<details> <summary> Expand </summary>
  
```bash
$ sudo yum install yum-utils
$ sudo yum-builddep python3
```

</details>

### Linux (debian, ubuntu)
<details> <summary> Expand </summary>
  
```bash
$ sudo apt-get build-dep python3.6 # <-- replace with your specific version of python3.X
```

</details>


### macOS

<details> <summary> Expand </summary>
  
```bash
$ xcode-select --install 
$ brew update
$ brew upgrade # <-- check this
$ brew install sqlite3 # and other missing packages
$ brew reinstall sqlite3
$ export LDFLAGS="-L/usr/local/opt/sqlite/lib" # or wherever brew just installed sqlite
$ export CPPFLAGS="-I/usr/local/opt/sqlite/include" # or wherever brew just installed sqlite
# ^^ repeat for the any other packages missing
$ source install_python.sh
```

</details>

Once you have ensured that the `python` dependencies are installed you are ready to proceed with compiling and installing
`python` from source. Additional details on the `python` duild dependencies are provided [here](https://devguide.python.org/setup/#build-dependencies).

## Installing python
Checkout this package and do:
```bash
$ source <path-to-repo>/install_python.sh
```
This will install `python` into a directory `Python-3.X.Y/` in the directory where you ran the above.

The new `python` executable will be located under `Python-3.X.Y/bin/python`.

## Installation Options

The script [install_python.sh](install_python.sh) has a few command-line options that the user may provide.
These can be viewed by printing the help message:

```bash
$ source install_python.sh -h
---------------------------------------------------------
 install CPython from source

 This script will download and install CPython for you.
 It installs the python version of your choice, with
 pip as well.

 Usage:
   $ source install_python.sh [OPTIONS]

 Options:
  -v   Python version [default: 3.8.2]
  -o   Enable optimized installation
           This corresponds to the CPython configuration flag
           "--enable-optimizations"
           [default: false]
  -l   Enable link-time-optimization (lto)
           This corresponds to the CPython configuration flag "--with-lto"
           and providing this flag may not work on every build system.
           If providing this flag, and installation fails, try again
           without providing it.
           [default: false]

---------------------------------------------------------
```

The option `-v` is pretty well explained. The additional options `-o` and `-l` enable optimization flags.
Providing either (or both) optimization flags will slow down the overall build process quite a bit, but will lead to more performant
python runtime execution (10-20% improvements). See this [thread on StackOverflow](https://stackoverflow.com/questions/41405728/what-does-enable-optimizations-do-while-compiling-python) and/or the discussion [here](https://github.com/docker-library/python/issues/160) for more information.

**Note**: The `-l` option (--> `--with-lto`) may result in a build failure on your system (see linked-to discussions above).
