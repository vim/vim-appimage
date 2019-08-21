#!/bin/sh
#
# Finds and dumps failed screen tests from the vim repository
#
# this is in an extra shell script, because Travis fails to parse the following line :(

if [ -d vim/src/testdir/failed ]; then
  find vim/src/testdir/failed -type f -name "*.dump" -size +0 -exec sh -c 'for i; do echo "failed: " $i && cat $i && echo ""; done'  find-sh {} +
fi
