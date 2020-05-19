# danny_installs_python
This is how you install `python` (>=3) from source.

## Pre-requisites
Prior to installing python, `python` itself requires several external dependencies if you wish to have a complete installation.
The external dependencies are detailed in the [python docs](https://devguide.python.org/setup/#build-dependencies).

You can install all `python` dependencies in one-go by running:

### Linux (rhel, centos)
```bash
$ sudo yum install yum-utils
$ sudo yum-builddep python3
```

### Linux (debian, ubuntu)
```bash
$ sudo apt-get build-dep python3.6 # <-- replace with your specific version of python3.X
```


### macOS
```bash
$ brew update
$ brew upgrade # <-- check this
$ brew install sqlite3
$ brew reinstall sqlite3
$ export LDFLAGS="-L/usr/local/opt/sqlite/lib"
$ export CPPFLAGS="-I/usr/local/opt/sqlite/include"
# ^^ repeate for the any other packages missing
# source install_python.sh
```
and thats it! This is detailed in the [python docs](https://devguide.python.org/setup/#build-dependencies).

Note that if you wish to install these external dependencies, you require root privileges (as indicated in the above).
This is primarily because python depends on many system and/or C libraries and it's default lookup table for
where these are located are in the "default" system location. You do not want to have to install each of these as
a normal user, individually, so you should acquire root privileges to run the steps above.

## Installing python
Checkout this package and do:
```bash
$ source <path-to-repo>/install_python.sh
```
This will install `python` into a directory `Python-3.X.Y/` in the directory where you ran the above.

The new `python` executable will be located under `Python-3.X.Y/bin/python`.
