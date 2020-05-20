#!/bin/bash

## macOS
if [ "$(uname)" == "Darwin" ]; then
    printf "\n### Setting compiler flags for macOSX\n"
    export LDFLAGS="-L/usr/local/opt/sqlite/lib"
    export CPPFLAGS="-I/usr/local/opt/sqlite/include"
    export CFLAGS="-I/usr/local/opt/sqlite/include"
fi
