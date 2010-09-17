#!/bin/bash

set -e

rsync -avzCH --exclude '#cvs.*' --delete anoncvs.postgresql.org::pgsql-cvs /cvsroot

# Clean up issues in the existing cvs repository (must always be done *after* the rsync
# of course, since a new rsync will overwrite it)
./repository_fixups


# Do the conversion
rm -rf /opt/gitrepo_cvs2git
cvs2git --options=/root/cvs2git.options
mkdir /opt/gitrepo_cvs2git
cd /opt/gitrepo_cvs2git
git init --bare
(cat /root/cvs2svn-tmp/git-blob.dat && cat /root/cvs2svn-tmp/git-dump.dat) | git fast-import --stats
rm -rf /root/cvs2svn-tmp

cd /opt/gitrepo_cvs2git

# Remove bogus branches
git branch -D unlabeled-1.44.2
git branch -D unlabeled-1.51.2
git branch -D unlabeled-1.59.2
git branch -D unlabeled-1.87.2
git branch -D unlabeled-1.90.2

# Convert 8.0.0 branch to tag
git tag REL8_0_0 REL8_0_0
git branch -D REL8_0_0

