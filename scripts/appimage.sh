#!/bin/bash

set -e

patch_desktop_files()
{
	# Remove duplicate keys from desktop file. This might occure while localisation
	# for the desktop file is progressing.
	pushd "${SOURCE_DIR}/runtime"
	mv ${LOWERAPP}.desktop ${LOWERAPP}.desktop.orig
	awk '{x=$0; sub(/=.*$/, "", x);if(!seen[x]++){print $0}}' ${LOWERAPP}.desktop.orig > ${LOWERAPP}.desktop
	rm ${LOWERAPP}.desktop.orig

	if [[ "$LOWERAPP" == "vim" ]]; then
		sed -i "s/^Icon=gvim/Icon=vim/" ${LOWERAPP}.desktop
	fi
	find . -xdev -name "vim48x48.png" -exec cp {} "${LOWERAPP}.png" \;
	popd
}

make_appimage()
{
	cd ${BUILD_BASE}
	test -x ./linuxdeploy.appimage || ( \
		wget -q https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage \
			-O linuxdeploy.appimage \
		&& chmod +x linuxdeploy.appimage )

	if [[ "$APP" == "GVim" ]]; then
		wget -c "https://raw.githubusercontent.com/linuxdeploy/linuxdeploy-plugin-gtk/master/linuxdeploy-plugin-gtk.sh"
		chmod +x linuxdeploy-plugin-gtk.sh
		PLUGIN="--plugin gtk"
	fi

	pushd ${APP}.AppDir
	cat <<'EOF' > AppRun
#!/bin/sh
set -ue
: "${ARGV0:=$0}"  # run without AppImage too
this_dir=$(readlink -f "$0")
this_dir=${this_dir%/*}  # empty for '/'
VIMRUNTIME=${this_dir}/usr/share/vim/vim91; export VIMRUNTIME
test -x "${this_dir}/usr/bin/gvim" || ARGV0=/vim
case "${ARGV0##*/}" in
  (vim*) set -- "${this_dir}/usr/bin/vim"  "$@" ;;
  (*)    set -- "${this_dir}/usr/bin/gvim" "$@" ;;
esac
unset ARGV0
exec "$@"
EOF
	popd

	export UPDATE_INFORMATION="gh-releases-zsync|vim|vim-appimage|latest|$APP-*x86_64.AppImage.zsync"
	export OUTPUT="${APP}-${VERSION}.glibc${GLIBC}-${ARCH}.AppImage"

	./linuxdeploy.appimage --appdir "$APP.AppDir" \
		-d "${SOURCE_DIR}/runtime/${LOWERAPP}.desktop" \
		-i "${SOURCE_DIR}/runtime/${LOWERAPP}.png" \
		${PLUGIN:-} \
		--output appimage
}

github_actions_deploy()
{
	if [ -n "$GITHUB_ACTIONS" ]; then
		# Copy artifacts to $GITHUB_WORKSPACE
		TARGET_NAME=$(find "$BUILD_BASE/" -type f -name "$APP-*.AppImage" -printf '%f\n')
		echo "Copy $BUILD_BASE/$TARGET_NAME -> $GITHUB_WORKSPACE"
		cp "$BUILD_BASE/$TARGET_NAME" "$GITHUB_WORKSPACE"
		cp "$BUILD_BASE/$TARGET_NAME.zsync" "$GITHUB_WORKSPACE"

		# Github Release Notes
		pushd "$script_dir"
		. release_notes.sh > "$GITHUB_WORKSPACE/release.body"
		popd
	fi
}

if [ -z "$1" ]; then
  APP=GVim
else
  APP=$1
fi

script_dir="$(cd "$(dirname "$0")" && pwd)"

if [ -n "$GITHUB_ACTIONS" ]; then
    echo "GitHub Actions detected"
    BUILD_BASE=$HOME
else
    BUILD_BASE="$script_dir/../build"
    mkdir -p "$BUILD_BASE"
fi

pushd vim
GIT_REV="$(git rev-parse --short HEAD)"
# should use tag if available, else use 7-hexdigit hash
VERSION="$(git describe --tags --abbrev=0 || git describe --always)"
# SOURCE_DIR: /home/<user>/vim-appimage/vim
SOURCE_DIR="$(git rev-parse --show-toplevel)"
ARCH=$(arch)
LOWERAPP=${APP,,}
popd

# uses the shadowdir from build_vim.sh
pushd vim/src/$LOWERAPP

GLIBC=$(find ${SOURCE_DIR} -type f -executable -exec strings {} \; | grep "^GLIBC_2" | sed s/GLIBC_//g | sort --version-sort | uniq | tail -n 1)
# Prepare some source files
patch_desktop_files

make install VIMPROG=$PWD/vim DESTDIR="${BUILD_BASE}/${APP}.AppDir" >/dev/null

# Create Appimage
make_appimage

# Perform Github Deployment
github_actions_deploy

popd
