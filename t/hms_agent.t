# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..14\n"; }
END {print "not ok 1\n" unless $loaded;}
use ExtUtils::testlib;
use VcsTools::HmsAgent;
use VcsTools::Process;
$loaded = 1;
my $idx = 1;
print "ok ",$idx++,"\n";

######################### End of black magic.

my $trace = shift || 0 ;

package dummyP ;
use strict ;
use vars qw/@ISA/ ;
@ISA = qw/VcsTools::Process/ ;


sub pipe
  {
    my $self =shift ;
    my %args = @_ ;

    
    my @a ;
    if ($self->{command} =~ /^fll/)
      {
        print "Dummy pipe of fll specific : $self->{command}\n" if $trace;
        @a = ('-r--r--r--     domi@marlis      4579 nov 02  1994 /7UP/treeScan.pl [1.2]') ;
      }
    else
      {
        print  "Dummy pipe of $self->{command}\n" if $trace;
        @a= qw/dummy result/;
      }

    # The process class will always return a chomped array ref.
    &{$args{callback}}(1,\@a);
  }

sub pipeIn
  {
    my $self =shift ;
    my %args = @_ ;

    
    my @a ;
    print  "Dummy pipe of $self->{command}\n" if $trace;
    print "With input :\n",$args{input} if $trace;;
    @a= qw/dummy pipe in result/;

    # The process class will always return a chomped array ref.
    &{$args{callback}}(1,\@a);
  }


# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

package main ;

use Tk::Multi::Manager ;

use strict ;

sub cb
  {
    my $res = shift ;

    print "callback result is ",$res,"\n" if $trace ;
  }

sub lockCb
  {
    my $res = shift ;
    my $rev = shift ;
    my $locker = shift ;

    print "Locked rev is $rev\n" if $trace ;
  }

my $h = new VcsTools::HmsAgent (
                                processClass => 'dummyP',
                                hmsHost => 'hptnofs',
                                hmsDir =>'adir',
                                hmsBase => 'abase',
                                hmsHost => 'hptnofs',
                                name => 'dummy.txt',
                                trace => $trace,
                                workDir => $ENV{'PWD'}
                               );

print "ok ",$idx++,"\n";
$h -> getLog(callback => \&cb) ;

print "ok ",$idx++,"\n";
$h -> checkOut(callback => \&cb, revision => '1.51', lock => 0) ;
print "ok ",$idx++,"\n";
$h -> checkOut(callback => \&cb, revision => '1.51.1.1', lock => 1) ;
print "ok ",$idx++,"\n";
$h -> getContent(callback => \&cb, revision => '1.52') ;
print "ok ",$idx++,"\n";
$h -> checkLock(callback => \&lockCb) ;
print "ok ",$idx++,"\n";
$h -> changeLock(callback => \&cb, lock => 1,revision => '1.51.1.1' ) ;
print "ok ",$idx++,"\n";
$h -> changeLock(callback => \&cb, lock => 0,revision => '1.51.1.1' ) ;

print "ok ",$idx++,"\n";
$h -> archiveHistory(callback => \&cb, 'log' => "new dummy\nhistory\n",
                     state => 'Dummy', revision => '1.52') ;
print "ok ",$idx++,"\n";
$h -> getLog(callback => \&cb) ;
print "ok ",$idx++,"\n";
$h -> showDiff(callback => \&cb, rev1 => '1.41') ;
print "ok ",$idx++,"\n";
$h -> showDiff(callback => \&cb, rev1 => '1.41', rev2 => '1.43') ;
print "ok ",$idx++,"\n";
$h -> checkIn(callback => \&cb, revision => '1.52', 
              'log' => "dummy log\nof a file\n") ;


print "ok ",$idx++,"\n";

