#!/bin/bash
export GIT_DIR=/opt/gitrepo_cvs2git

#BRANCHES="REL8_4_STABLE REL8_3_STABLE REL8_2_STABLE REL8_1_STABLE REL8_0_STABLE"
#TAGS="REL8_4_0 REL8_4_1"
SYMBOLS=$(perl find_all_symbols.pl)

test -d /opt/diffs || mkdir /opt/diffs

for B in ${SYMBOLS} ; do
   echo Comparing $B
   set -e
   rm -rf /opt/compare_working
   mkdir -p /opt/compare_working/cvs /opt/compare_working/git
   set +e
   echo . Exporting cvs...
   cvs -q -d /cvsroot export -d /opt/compare_working/cvs -r $B pgsql |egrep -v "^U"
   set -e
   echo . Exporting git...
   git archive --format=tar $B | (cd /opt/compare_working/git && tar xf -)
   echo . Diffing...
   set +e
   diff -Nr /opt/compare_working/cvs /opt/compare_working/git > /opt/diffs/$B.diff
   if [ -s /opt/diffs/$B.diff ]; then
      echo "**** Differences found ****"
   else
      rm -f /opt/diffs/$B.diff
   fi
done
