#!/bin/bash
#
# build vim
#

set -e

script_dir="$(cd "$(dirname "$0")" && pwd)"

SRCDIR=$script_dir/../vim/src
FEATURES=huge

typeset -a CFG_OPTS
CFG_OPTS+=( "--enable-gui=gtk3" )
CFG_OPTS+=( "--enable-perlinterp" )
CFG_OPTS+=( "--enable-pythoninterp" )
CFG_OPTS+=( "--enable-python3interp" )
CFG_OPTS+=( "--enable-rubyinterp" )
CFG_OPTS+=( "--enable-luainterp" )
CFG_OPTS+=( "--enable-tclinterp" )
CFG_OPTS+=( "--prefix=/usr" )

NPROC=$(getconf _NPROCESSORS_ONLN)

# Apply experimental patches
shopt -s nullglob
pushd "${SRCDIR}"/..
for i in ../patch/*.patch; do git apply -v "$i"; done
popd
shopt -u nullglob

cd "${SRCDIR}"
./configure --with-features=$FEATURES "${CFG_OPTS[@]}" --enable-fail-if-missing
make -j$NPROC
