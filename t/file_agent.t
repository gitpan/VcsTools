# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..13\n"; }
END {print "not ok 1\n" unless $loaded;}
use ExtUtils::testlib;
use VcsTools::FileAgent;
$loaded = 1;
my $idx = 1;
print "ok ",$idx++,"\n";
my $trace = shift || 0;

######################### End of black magic.


use strict ;

sub got
  {
    my $res = shift ;
    my $str = shift || $res;

    if ($res)
      {
        print "ok ",$idx++,"\n";
        warn "good: got \n$str\n" if $trace ;
      }
    else
      {
        print "not ok ",$idx++,"\n";
        warn "bad: got \n$str\n" if $trace ;
      }
  }

sub statcb
  {
    my $res = shift ;
    my $s = shift ;

    if ($res)
      {
        print "ok ",$idx++,"\n";
        warn "good: got \n",join(' ',@$s),"\n" if $trace ;
      }
    else
      {
        print "not ok ",$idx++,"\n";
        warn "bad: got empty stat : $s\n" if $trace ;
      }

  }

sub wrong_statcb
  {
    my $res = shift ;
    my $s = shift ;

    if ($res)
      {
        print "not ok ",$idx++,"\n";
        warn "good: got \n",join(' ',@$s),"\n" if $trace ;
      }
    else
      {
        print "ok ",$idx++,"\n";
        warn "bad: got empty stat : $s\n" if $trace ;
      }

  }

my $dtest = "test_agent";

-d $dtest or mkdir($dtest,0755) or die "can't make dir $dtest \n";

print "ok ",$idx++,"\n";

my $agent = "VcsTools::FileAgent" ;

my $fa = new $agent(name => 'test.txt',
                    workDir => $ENV{'PWD'}.'/'.$dtest);
print "ok ",$idx++,"\n";

warn "writing 3 files \n" if $trace ;
$fa->writeFile(content => '$Revision: 1.46 $ '."\n\ndummy content\n", 
               callback => \&got) ;
$fa->writeFile(content => "dummy content\n\n_1\n", callback => \&got, 
               name => 'test_1.txt') ;
$fa->writeFile(content => "dummy content\n\n_2\n", callback => \&got, 
               name => 'test_2.txt') ;

warn "reading 1 file\n" if $trace ;
$fa->readFile(callback => \&statcb, name => 'test.txt') ;

warn "reading revision \n" if $trace ;
$fa->getRevision(callback => \&got, name => 'test.txt') ;

my $ans = 0  ;
if ($trace)
  {
    print "perform xemacs test ? (y/n)";
    my $rep = <STDIN> ;
    chomp ($rep);
    $ans = $rep eq 'y' ? 1 : 0 ;
  }

my $gnuc = `type gnuclient` ;
if ($ans and $gnuc =~ m!/!)
  {
    # gnuclient was found ...
    warn "editing 1 file\n" if $trace ;
    $fa->edit(callback => \&statcb) ;
  }
else
  {
    warn "skipping edit test" if $trace ;
    print "ok ",$idx++,"\n";
  }


$gnuc = `type gnudoit` ;
if ($ans and $gnuc =~ m!/!)
  {
    warn "merging the 3 files\n" if $trace ;
    $fa->merge(callback => \&statcb, 
               below => 'test_1.txt', other => 'test_2.txt',
               ancestor => 'test.txt') ;
  }
else
  {
    warn "skipping merge test" if $trace ;
    print "ok ",$idx++,"\n";
  }

warn "stat file\n" if $trace ;
$fa->stat(callback => \&statcb, name => 'test.txt') ;

warn "stat non existing file, failure trace is normal\n" if $trace ;
$fa->stat(callback => \&wrong_statcb, name => 'nofile.txt') ;

print "ok ",$idx++,"\n";


