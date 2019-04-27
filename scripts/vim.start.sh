#!/bin/sh

export VIM=$APPDIR/usr/share/vim
export VIMRUNTIME=$APPDIR/usr/share/vim/vim81

# We don't pack Python stuff, so unset the PYTHON vars set by AppRun.
# see https://github.com/AppImage/AppImageKit/blob/master/src/AppRun.c
unset PYTHONPATH
unset PYTHONHOME
unset PYTHONDONTWRITEBYTECODE

# OWD - Original Working Directory - set by AppImage
# see https://github.com/AppImage/AppImageKit/blob/master/src/runtime.c
cd "$OWD"

# ARGV0 should always be set, if not fall back to AppImage name
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

