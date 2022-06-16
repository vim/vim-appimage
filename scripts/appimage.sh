#!/bin/bash

########################################################################
# Package the binaries built on GitHub Actions as an AppImage
# By Simon Peter 2016
# For more information, see http://appimage.org/
########################################################################

set -e

APP=GVim
LOWERAPP=${APP,,}

ARCH=$(arch)

script_dir="$(cd "$(dirname "$0")" && pwd)"

if [ -n "$GITHUB_ACTIONS" ]; then
    echo "GitHub Actions detected"
    BUILD_BASE=$HOME
else
    BUILD_BASE="$script_dir/../build"
    mkdir -p "$BUILD_BASE"
fi

# Did never work
#TAG=$(git describe --exact-match --tags HEAD 2> /dev/null)
#RE="^untagged-.*"
#if [[ $? != 0  ||  "$TAG" =~ "$RE" ]]; then
#    echo  "non-tag commit"
#    exit
#fi

cd vim

GIT_REV="$(git rev-parse --short HEAD)"

VERSION="$(git describe --tags --abbrev=0)"

SOURCE_DIR="$(git rev-parse --show-toplevel)"
make install DESTDIR="$BUILD_BASE/$APP/$APP.AppDir"

cd "$BUILD_BASE/$APP/"

wget -q https://github.com/AppImage/pkg2appimage/raw/master/functions.sh -O ./functions.sh
. ./functions.sh

cd "$APP.AppDir"

# Also needs grep for gvim.wrapper
cp /bin/grep ./usr/bin

# install additional dependencies for python
# this makes the image too big, so skip it
# and depend on the host where the image is run to fulfill those dependencies

#URL=$(apt-get install -qq --yes --no-download --reinstall --print-uris libpython2.7 libpython3.2 libperl5.14 liblua5.1-0 libruby1.9.1| cut -d' ' -f1 | tr -d "'")
#wget -c $URL
#for package in *.deb; do
#    dpkg -x $package .
#done
#rm -f *.deb


########################################################################
# Copy desktop and icon file to AppDir for AppRun to pick them up
########################################################################

get_apprun

get_desktop

find "${SOURCE_DIR}" -xdev -name "vim48x48.png" -exec cp {} "${LOWERAPP}.png" \;

mkdir -p ./usr/lib/x86_64-linux-gnu

# copy dependencies
copy_deps

# Move the libraries to usr/bin
move_lib

########################################################################
# Delete stuff that should not go into the AppImage
########################################################################

# include libpango, to avoid undefined symbol g_memdup2 on Ubuntu 22.04
#find . -name "libpango*" -delete
find . -name "libfreetype*" -delete
find . -name "libX*" -delete

# Delete dangerous libraries; see
# https://github.com/probonopd/AppImages/blob/master/excludelist
delete_blacklisted

########################################################################
# Determine the version of the app; also include needed glibc version
########################################################################

if [ -n "$GITHUB_ACTIONS" ]; then
    # Create release file
    dl_counter="![Github Downloads (by Release)](https://img.shields.io/github/downloads/$GITHUB_REPOSITORY/${VERSION}/total.svg)"
    version_info="**GVim: $VERSION** - Vim git commit: [$GIT_REV](https://github.com/vim/vim/commit/$GIT_REV) - glibc: $(glibc_needed)"
    gha_build="[GitHub Actions Logfile]($GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID)"

    echo "$dl_counter<br><br>Version Information:<br>$version_info<br><br>$gha_build" >  "$GITHUB_WORKSPACE/release.body"
fi

########################################################################
# Patch away absolute paths; it would be nice if they were relative
########################################################################

sed -i -e "s|/usr/share/|././/share/|g" usr/bin/vim
sed -i -e "s|/usr/lib/|././/lib/|g" usr/bin/vim
sed -i -e "s|/usr/share/doc/vim/|././/share/doc/vim/|g" usr/bin/vim

# Possibly need to patch additional hardcoded paths away, replace
# "/usr" with "././" which means "usr/ in the AppDir"

# remove unneeded stuff
rmdir ./usr/lib64 || true
rm -rf ./usr/bin/*tutor* || true
rm -rf ./usr/share/doc || true
#rm -rf ./usr/bin/vim || true
# remove unneeded links
find ./usr/bin -type l \! -name "gvim" -delete || true

########################################################################
# Patch gvim.desktop file and copy start script
########################################################################

# Remove duplicate keys from desktop file. This might occure while localisation
# for the desktop file is progressing.
mv gvim.desktop gvim.desktop.orig
awk '{x=$0; sub(/=.*$/, "", x);if(!seen[x]++){print $0}}' gvim.desktop.orig > gvim.desktop
rm gvim.desktop.orig

# change Exec line to script
sed -i 's/^Exec=gvim.*$/Exec=vim.start.sh %F/' gvim.desktop

# copy script
cp "$script_dir/vim.start.sh"  ./usr/bin
chmod +x ./usr/bin/vim.start.sh

########################################################################
# AppDir complete
# Now packaging it as an AppImage
########################################################################

cd "$BUILD_BASE/$APP" # Go out of AppImage

generate_type2_appimage -u "gh-releases-zsync|vim|vim-appimage|latest|$APP-*x86_64.AppImage.zsync"

if [ -n "$GITHUB_ACTIONS" ]; then
    TARGET_NAME=$(find "$BUILD_BASE/out" -type f -name "$APP-*.AppImage" -printf '%f\n')
    echo "Copy $BUILD_BASE/out/$TARGET_NAME -> $GITHUB_WORKSPACE"
    cp "$BUILD_BASE/out/$TARGET_NAME" "$GITHUB_WORKSPACE"
    cp "$BUILD_BASE/out/$TARGET_NAME.zsync" "$GITHUB_WORKSPACE"
fi

########################################################################
# Upload the AppDir
########################################################################

#transfer ../out/*
