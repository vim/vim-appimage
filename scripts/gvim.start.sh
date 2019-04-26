#!/bin/sh

export VIM=$APPDIR/usr/share/vim
export VIMRUNTIME=$APPDIR/usr/share/vim/vim81
cd $OWD
exec gvim -f "$@"

