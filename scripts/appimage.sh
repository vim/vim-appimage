#!/bin/bash

########################################################################
# Package the binaries built on Travis-CI as an AppImage
# By Simon Peter 2016
# For more information, see http://appimage.org/
########################################################################

set -e

APP=GVim
LOWERAPP=${APP,,}

AppImageKitVersion=11

export ARCH="$(arch)"
script_dir="$(cd "$(dirname "$0")" && pwd)"

if [ -n "$TRAVIS" ]; then
    echo "Travis detected"
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

VIM_VER="$(git describe --tags --abbrev=0)"

SOURCE_DIR="$(git rev-parse --show-toplevel)"
make install DESTDIR="$BUILD_BASE/$APP/$APP.AppDir"

cd "$BUILD_BASE/$APP/"

wget -q https://github.com/probonopd/AppImages/raw/master/functions.sh -O ./functions.sh
. ./functions.sh

cd $APP.AppDir

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


# Don't use `get_apprun`, as we want to specify the AppImageKit version.
# get_apprun
wget -c "https://github.com/AppImage/AppImageKit/releases/download/${AppImageKitVersion}/AppRun-${ARCH}" -O AppRun
chmod a+x AppRun

get_desktop

find "${SOURCE_DIR}" -xdev -name "vim48x48.png"  -exec cp {} "${LOWERAPP}.png" \;

mkdir -p ./usr/lib/x86_64-linux-gnu
# copy custom libruby.so 1.9
find "$HOME/.rvm/" -xdev -name "libruby.so.1.9" -exec cp {} ./usr/lib/x86_64-linux-gnu/ \; || true
# add libncurses5
find /lib -xdev -name "libncurses.so.5" -exec cp -v -rfL {} ./usr/lib/x86_64-linux-gnu/ \; || true

# copy dependencies
copy_deps

# Move the libraries to usr/bin
move_lib

########################################################################
# Delete stuff that should not go into the AppImage
########################################################################

# if those libraries are present, there will be a pango problem
find . -name "libpango*" -delete
find . -name "libfreetype*" -delete
find . -name "libX*" -delete

# Delete dangerous libraries; see
# https://github.com/probonopd/AppImages/blob/master/excludelist
delete_blacklisted

########################################################################
# Determine the version of the app; also include needed glibc version
########################################################################

GLIBC_NEEDED=$(glibc_needed)
VERSION=$VIM_VER

if [ -n "$TRAVIS" ]; then
    # Create release file
    # Travis cannot handle a multi-line release body,
    # see https://github.com/travis-ci/dpl/issues/155
    # so add a single line with <br> for the line breaks
    dl_counter="![Github Downloads (by Release)](https://img.shields.io/github/downloads/$TRAVIS_REPO_SLUG/$TRAVIS_TAG/total.svg)"
    version_info="**GVim: $VIM_VER** - Vim git commit: [$GIT_REV](https://github.com/vim/vim/commit/$GIT_REV) - glibc: $GLIBC_NEEDED"
    travis_build="[Travis Build Logfile]($TRAVIS_BUILD_WEB_URL)"

    echo "$dl_counter<br><br>Version Information:<br>$version_info<br><br>$travis_build" >  "$TRAVIS_BUILD_DIR/release.body"
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
mv gvim.desktop gvim.desktop.org
awk '{x=$0; sub(/=.*$/, "", x);if(!seen[x]++){print $0}}' gvim.desktop.org > gvim.desktop
rm gvim.desktop.org

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

# Don't use `generate_appimage` from function.sh, as we want to work with
# AppImageKit V11. The function `generate_appimage` is hardcoded to V6.

URL="https://github.com/AppImage/AppImageKit/releases/download/${AppImageKitVersion}/appimagetool-${SYSTEM_ARCH}.AppImage"
wget -c "$URL" -O AppImageAssistant
chmod a+x ./AppImageAssistant

BIN=$(find . -name \*.so\* -type f | head -n 1)
INFO=$(file "$BIN")
if [ -z "$ARCH" ] ; then
    if [[ $INFO == *"x86-64"* ]] ; then
        ARCH=x86_64
    elif [[ $INFO == *"i686"* ]] ; then
        ARCH=i686
    elif [[ $INFO == *"armv6l"* ]] ; then
        ARCH=armhf
    else
        echo "Could not automatically detect the architecture."
        echo "Please set the \$ARCH environment variable."
        exit 1
    fi
fi

mkdir -p "$BUILD_BASE/out" || true
rm "$BUILD_BASE/out/$APP-$VERSION.glibc$GLIBC_NEEDED-$ARCH.AppImage" 2>/dev/null || true
GLIBC_NEEDED=$(glibc_needed)

TARGET_NAME="$APP-$VERSION.glibc$GLIBC_NEEDED-$ARCH.AppImage"

./AppImageAssistant -u "gh-releases-zsync|vim|vim-appimage|latest|GVim-*x86_64.AppImage.zsync" ./$APP.AppDir/ "../out/$TARGET_NAME"

if [ -n "$TRAVIS" ]; then
    echo "Copy $BUILD_BASE/out/$TARGET_NAME -> $TRAVIS_BUILD_DIR"
    cp "$BUILD_BASE/out/$TARGET_NAME" "$TRAVIS_BUILD_DIR"
    # use lowercase "appimage" here, so it is not picked up by travis deploy
    ln -s "$TRAVIS_BUILD_DIR/$TARGET_NAME" "$TRAVIS_BUILD_DIR/vim.appimage"
    ln -s "$TRAVIS_BUILD_DIR/$TARGET_NAME" "$TRAVIS_BUILD_DIR/gvim.appimage"

fi

########################################################################
# Upload the AppDir
########################################################################

#transfer ../out/*
