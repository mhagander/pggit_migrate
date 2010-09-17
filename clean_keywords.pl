#!/usr/bin/perl

#
# Attempt to remove all cvs keywords in the active branch.
# (with "all keywords" meaning $PostgreSQL$ keyword)
#
# Attempt to do this without line numbers changing in all files. This
# is done by some ugly analyzing of what type of line it is and replacement
# of it with an empty comment rather than with a blank line.
#


$REPODIR=$ARGV[0] || die "No repository specified\n";

chdir($REPODIR) || die "Could not chdir to $REPODIR\n";
open(L,"git grep -l \\\$PostgreSQL |") || die "Could not git-grep\n";
while (<L>) {
   chomp;
   next if (/add_cvs_markers/);
   my $fn = $_; 
   my $txt;
   open(F,"<$fn") || die "Could not read $_\n";
   while (<F>) {
      if (/\$PostgreSQL/) {
	# This is the line!
        if (/^ \*\s+\$PostgreSQL/) {
	   # C sourceode style file
           $_ = " *\n";
        }
        elsif (/^\*\s+\$PostgreSQL/) {
	   # C sourceode style file with no leading space
           $_ = "*\n";
        }
        elsif (/^\*\*\s+\$PostgreSQL/) {
	   # C sourceode style file with no leading space and two asterisks
           $_ = "**\n";
        }
	elsif (/^\/\*\s+\$PostgreSQL.*\*\/\n$/) {
	   # Single line SQL or C comment
	   $_ = "\n";
        }
        elsif (/^\/\*\s+\$PostgreSQL/) {
	   # C sourceode style, on first line, but no end of comment
           $_ = "/*\n";
        }
        elsif (/^#\s+\$PostgreSQL/) {
           # Shellscript or makefile
           $_ = "#\n";
	}
	elsif (/^<!-- \$PostgreSQL.*-->\n$/) {
	   # SGML style
	   $_ = "\n";
	}
	elsif (/^dnl \$PostgreSQL/) {
	   # m4
	   $_ = "\n";
	}
	elsif (/^\s*\$PostgreSQL.*\$\n$/) {
	   # Bare word
	   $_ = "\n";
	}
	elsif (/^REM \$PostgreSQL/) {
	   # evil batch flie
	   $_ = "\n";
	}
	elsif (/^--\s+\$PostgreSQL/) {
	   # SQL comment
	   $_ = "--\n";
	}
	elsif (/^([!\/])\s+\$PostgreSQL/) {
	   # Solaris assembly
	   $_ = "$1\n";
	}
	elsif (/^(\s+!!)\s+\$PostgreSQL/) {
	   # Solaris assembly again
	   $_ = "$1\n";
	}
	elsif (/\.\\" \$PostgreSQL/) {
	   # man page
	   $_ = "";
	}
	elsif (/\/\/ \$PostgreSQL/) {
	   # c++ style comment
	   $_ = "//\n";
	}
	elsif (/\/\*static .*"\$PostgreSQL.*\*\/$/) {
	   # variable storing
	   $_ = "\n";
	}
	elsif (/\/\* RCS \$PostgreSQL/) {
	   # incorrect load? only in corba interface?!
	   $_ = "/*";
	}
	elsif (/^% \$PostgreSQL/) {
	   # jade config nd more?
	   $_ = "\n";
        } else {
           die "Unknown tag line: $_ in $fn\n";
        }
      }
      elsif (/^ \* IDENTIFICATION/) {
	 # Need to remove this row too, for things to look nice.
	 $_ = " *\n";
      }
      $txt .= $_;
   }
   close(F);
   open(F,">$fn") || die "Could not write $_\n";
   print F $txt;
   close(F);
   $txt = '';
}
