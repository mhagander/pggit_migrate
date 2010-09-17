#!/bin/bash

set -e

rsync -avzCH --exclude '#cvs.*' --delete anoncvs.postgresql.org::pgsql-cvs /cvsroot

# Remove some broken revisions
pushd /
for r in 2.89 2.90 2.91; do rcs -x,v -sdead:$r ./cvsroot/pgsql/src/backend/parser/Attic/gram.c ; done
for r in 1.3 1.4 1.5 1.6; do rcs -x,v -sdead:$r ./cvsroot/pgsql/src/interfaces/ecpg/preproc/Attic/pgc.c ; done
for r in 1.7 1.8 1.9 1.10 1.11 1.12; do rcs -x,v -sdead:$r ./cvsroot/pgsql/src/interfaces/ecpg/preproc/Attic/preproc.c ; done
for r in 1.3 1.4 1.5 1.6 1.7 1.8; do rcs -x,v -sdead:$r ./cvsroot/pgsql/src/interfaces/ecpg/preproc/Attic/y.tab.h ; done
popd


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

