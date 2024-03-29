#!/bin/sh
#set -x

# Work directory of this repository.
if [ "$1" != "" ]; then
    workdir=$1
else
    workdir=.
fi

cd $workdir
if [ ! -d .github ]; then
    echo "Wrong directory."
    exit 1
fi

# older git does not know about --no-edit for git-pull
# e.g. 1.7.9.5
# git pull --no-edit
git pull

if [ ! -d vim/src ]; then
    git submodule init
fi
git submodule update

# Get the latest vim source code
cd vim
vimoldver=$(git rev-parse HEAD)
git checkout master
git pull
vimver=$(git describe --tags --abbrev=0)
cd -

# Check if it is updated
if git diff --exit-code > /dev/null; then
    echo "No changes found."
    exit 0
fi

# Commit the change and push it
git commit -a -m "Vim: $vimver"
git tag $vimver
git push origin master --tags
