#!/usr/bin/perl

$REPO="/cvsroot";

my %symbols;

for my $f ('configure,v', 'configure.in,v', 'README,v') {
   open(F,"<$REPO/pgsql/$f") || die "Could not open $f\n";
   while (<F>) {
      last if /^symbols/;
   }
   while (<F>) {
      last unless /^\s+([^:]+):\d+\.\d+[\d\.]*$/;
      $symbols{$1}++;
   }
   close(F);
}

for $k (sort keys %symbols) {
   print $k . " ";
}
print "\n";
