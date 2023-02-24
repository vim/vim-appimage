#!/bin/sh
#
# Finds and dumps failed screen tests from the vim repository in the gvim shadowdir

if [ -d vim/src/gvim/testdir/failed ]; then
  find vim/src/gvim/testdir/failed -type f -name "*.dump" -size +0 -exec sh -c 'for i; do echo "failed: " $i && cat $i && echo ""; done'  find-sh {} +
fi
