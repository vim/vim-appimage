#!/bin/sh

export VIM=$APPDIR/usr/share/vim
export VIMRUNTIME=$APPDIR/usr/share/vim/vim81

# OWD - Original Working Directory - set by AppImage
# see https://github.com/AppImage/AppImageKit/blob/master/src/runtime.c
cd "$OWD"

if [ -n "$ARGV0" ]; then
    basename="$(basename "$ARGV0" | tr 'A-Z' 'a-z')"
else
    basename="$(basename "$APPIMAGE" | tr 'A-Z' 'a-z')"
fi
case $basename in
    vim*)
        exec vim "$@"
        ;;
    *)
        exec gvim -f "$@"
        ;;
esac

