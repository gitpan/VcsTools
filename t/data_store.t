# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..4\n"; }
END {print "not ok 1\n" unless $loaded;}
use ExtUtils::testlib;
use VcsTools::DataSpec::HpTnd;
$loaded = 1;
my $idx = 1;
print "ok ",$idx++,"\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

package main ;

use strict ;

my $ds = new VcsTools::DataSpec::HpTnd ;

print "ok ",$idx++,"\n";

my $info = 
  {
   'state' => 'Exp',
   'author' => 'pierres',
   'writer' => 'pierres',
   'date' => '1998/02/11 11:40:54',
   'fix' => [
             'GREhp12347'
            ],
   'log' => "bugs fixed:\n\nGREhp12347: Prepare source module for NT\n"
  } ;

my $template = 
"writer: pierres
fix: GREhp12347
bugs fixed:

GREhp12347: Prepare source module for NT\n" ;

my $str = $ds->buildLogString($info) ;
print "ok ",$idx++,"\n";


if ($str eq $template) {print "ok ",$idx++,"\n" ;}
else {print "not ok ",$idx++,"\n" ;}


