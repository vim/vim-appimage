#!/bin/sh

if [ -z "$VIM" ]; then
    export VIM=$APPDIR/usr/share/vim
fi
if [ -z "$VIMRUNTIME" ]; then
    export VIMRUNTIME=$APPDIR/usr/share/vim/vim90
fi

# We don't pack Python stuff, so unset the PYTHON vars set by AppRun.
# see https://github.com/AppImage/AppImageKit/blob/master/src/AppRun.c
unset PYTHONPATH
unset PYTHONHOME
unset PYTHONDONTWRITEBYTECODE

# Change back to OWD - Original Working Directory
# Set by AppImage
# see https://github.com/AppImage/AppImageKit/blob/master/src/runtime.c
cd "$OWD"

# ARGV0 should always be set, if not fall back to AppImage name
if [ -n "$ARGV0" ]; then
    basename="$(basename "$ARGV0" | tr '[:upper:]' '[:lower:]')"
else
    basename="$(basename "$APPIMAGE" | tr '[:upper:]' '[:lower:]')"
fi
case $basename in
    vim*)
        exec vim "$@"
        ;;
    *)
        exec gvim -f "$@"
        ;;
esac
