#!/bin/bash

set -e

rsync -avzH --exclude '#cvs.*' --delete anoncvs.postgresql.org::pgsql-cvs /cvsroot

# Clean up issues in the existing cvs repository (must always be done *after* the rsync
# of course, since a new rsync will overwrite it)
./repository_fixups


# Do the conversion
P=$(pwd)
rm -rf /opt/gitrepo_cvs2git
cvs2git --options=cvs2git.options
mkdir /opt/gitrepo_cvs2git
pushd /opt/gitrepo_cvs2git
git init --bare
(cat $P/cvs2svn-tmp/git-blob.dat && cat $P/cvs2svn-tmp/git-dump.dat) | git fast-import --stats
popd
rm -rf cvs2svn-tmp

cd /opt/gitrepo_cvs2git

# Remove bogus branches
git branch -D unlabeled-1.44.2
git branch -D unlabeled-1.51.2
git branch -D unlabeled-1.59.2
git branch -D unlabeled-1.87.2
git branch -D unlabeled-1.90.2

# Remove unwanted tags
git tag -d SUPPORT
git tag -d MANUAL_1_0
git tag -d Release-1-6-0
git tag -d Release_2_0_0
git tag -d Release_2_0
git tag -d creation
git tag -d REL6_5
git tag -d REL7_1
git tag -d REL7_1_2

# Convert 8.0.0 branch to tag
git tag REL8_0_0 REL8_0_0
git branch -D REL8_0_0

# Garbage collect, making the repo half the size
git gc --aggressive --prune

