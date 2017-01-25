#!/bin/bash

########################################################################
# Package the baries built on Travis-CI as an AppImage
# By Simon Peter 2016
# For more information, see http://appimage.org/
########################################################################

export ARCH="$(arch)"

APP=GVim
LOWERAPP=${APP,,}

TAG=$(git describe --exact-match --tags HEAD 2> /dev/null)
RE="^untagged-.*"
if [[ $? != 0  ||  "$TAG" =~ "$RE" ]]; then
    echo  "non-tag commit"
    exit
fi

cd vim
GIT_REV="$(git rev-parse --short HEAD)"

VIM_VER="$(git describe --tags --abbrev=0)"

SOURCE_DIR="$(git rev-parse --show-toplevel)"
make install DESTDIR=/home/travis/$APP/$APP.AppDir

cd $HOME/$APP/

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

get_apprun

get_desktop

find "${SOURCE_DIR}" -name "vim48x48.png" -xdev -exec cp {} "${LOWERAPP}.png" \;

mkdir -p ./usr/lib/x86_64-linux-gnu
# copy custom libruby.so 1.9
find $HOME/.rvm/ -name "libruby.so.1.9" -xdev -exec cp {} ./usr/lib/x86_64-linux-gnu/ \;
# add libncurses5
find /lib -name "libncurses.so.5" -xdev -exec cp -v -rfL {} ./usr/lib/x86_64-linux-gnu/ \;

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
# desktopintegration asks the user on first run to install a menu item
########################################################################

get_desktopintegration "$LOWERAPP"

########################################################################
# Determine the version of the app; also include needed glibc version
########################################################################

GLIBC_NEEDED=$(glibc_needed)
VERSION=$VIM_VER-git$GIT_REV-glibc$GLIBC_NEEDED

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
# remove unneded links
find ./usr/bin -type l \! -name "gvim" -delete || true

########################################################################
# AppDir complete
# Now packaging it as an AppImage
########################################################################

cd .. # Go out of AppImage

generate_appimage

cp ../out/*.AppImage "$TRAVIS_BUILD_DIR"

########################################################################
# Upload the AppDir
########################################################################

#transfer ../out/*
