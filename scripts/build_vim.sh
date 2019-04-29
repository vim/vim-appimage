#!/bin/sh
#
# build vim
#

set -e

script_dir="$(cd "$(dirname "$0")" && pwd)"

SRCDIR=$script_dir/../vim/src
FEATURES=huge
CONFOPT='--enable-gui=gtk2 --enable-perlinterp --enable-pythoninterp --enable-python3interp --enable-rubyinterp --enable-luainterp --enable-tclinterp --prefix=/usr'

NPROC=$(getconf _NPROCESSORS_ONLN)

cd "${SRCDIR}"
./configure --with-features=$FEATURES $CONFOPT --enable-fail-if-missing
make -j$NPROC

