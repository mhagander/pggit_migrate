#!/usr/bin/perl -w

#
# Attempt to remove all cvs keywords in the given directory tree
# (with "all keywords" meaning $PostgreSQL$ keyword)
#
# We don't want to change line numbers, so we simply reduce the keyword
# string to the file pathname part.  For example,
# $PostgreSQL: pgsql/src/port/unsetenv.c,v 1.12 2010/09/07 14:10:30 momjian Exp $
# becomes
# src/port/unsetenv.c
#


$REPODIR=$ARGV[0] || die "No repository specified\n";

chdir($REPODIR) || die "Could not chdir to $REPODIR\n";
open(L,"git grep -l \\\$PostgreSQL |") || die "Could not git-grep\n";
while (<L>) {
   chomp;
   my $fn = $_; 
   my $txt;
   open(F,"<$fn") || die "Could not read $_\n";
   while (<F>) {
      s|\$PostgreSQL: pgsql/(\S+),v [^\$]+\$|$1|;
      $txt .= $_;
   }
   close(F);
   open(F,">$fn") || die "Could not write $_\n";
   print F $txt;
   close(F);
   $txt = '';
}
