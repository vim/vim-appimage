#!/bin/bash
#
# build vim
#

set -e

script_dir="$(cd "$(dirname "$0")" && pwd)"

SRCDIR=$script_dir/../vim/src
FEATURES=huge

typeset -a CFG_OPTS
CFG_OPTS+=( "--enable-gui=gtk2" )
CFG_OPTS+=( "--enable-perlinterp" )
CFG_OPTS+=( "--enable-pythoninterp" )
CFG_OPTS+=( "--enable-python3interp" )
CFG_OPTS+=( "--enable-rubyinterp" )
CFG_OPTS+=( "--enable-luainterp" )
CFG_OPTS+=( "--enable-tclinterp" )
CFG_OPTS+=( "--prefix=/usr" )

NPROC=$(getconf _NPROCESSORS_ONLN)

cd "${SRCDIR}"
./configure --with-features=$FEATURES "${CFG_OPTS[@]}" --enable-fail-if-missing
make -j$NPROC

