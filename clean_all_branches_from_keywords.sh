#!/bin/bash

set -e
REPO=/opt/gitrepo_cvs2git
HERE=$(pwd)

# clean master only
BRANCHES="master"

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
EOF
done

echo "All branches updated, don't forget to push!"

