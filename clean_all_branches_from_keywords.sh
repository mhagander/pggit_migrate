#!/bin/bash

set -e
REPO=/opt/gitrepo_cvs2git
HERE=$(pwd)

BRANCHES="master REL9_0_STABLE REL8_4_STABLE REL8_3_STABLE REL8_2_STABLE REL8_1_STABLE REL8_0_STABLE"

cd $REPO

for B in $BRANCHES ; do
   if [ "$B" != "master" ]; then
      echo Creating branch $B
      git branch -f $B --track origin/$B
   fi
   echo Switching to $B
   git checkout $B
   echo Cleaning $B
   perl $HERE/clean_keywords.pl $REPO
   echo Committing cleanup
   git commit -a -F - <<EOF
Remove cvs keywords from all files.

Also remove some related lines, such as the IDENTIFICATION line present
in most C files (but not other sources).
EOF
done

echo "All branches updated, don't forget to push!"

