#!/bin/bash
#
# build vim
#

set -e

script_dir="$(cd "$(dirname "$0")" && pwd)"

SRCDIR=$script_dir/../vim/src
FEATURES=huge
export CFLAGS="-Wno-deprecated-declarations"
export CC=gcc-10

typeset -a CFG_OPTS
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

# Build Vim - no X11
rm -rf vim
SHADOWDIR=vim make -e shadow
pushd vim
ADDITIONAL_ARG="--without-x --enable-gui=no --enable-fail-if-missing --without-wayland"
./configure --with-features=$FEATURES "${CFG_OPTS[@]}" $ADDITIONAL_ARG
make -j$NPROC
popd

# Build GVim
rm -rf gvim
SHADOWDIR=gvim make -e shadow
pushd gvim
ADDITIONAL_ARG="--enable-fail-if-missing"
CFG_OPTS+=( "--enable-gui=gtk3" )
./configure --with-features=$FEATURES "${CFG_OPTS[@]}" $ADDITIONAL_ARG
make -j$NPROC
popd
