# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..2\n"; }
END {print "not ok 1\n" unless $loaded;}
use Tk ;
use Tk::ObjScanner ;
use ExtUtils::testlib;
use VcsTools::Process ;

require Tk::ROText;
require Tk::ErrorDialog; 
$loaded = 1;
print "ok 1\n";
my $trace = shift || 0 ;

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

use strict ;
my $t ;

sub result
  {
    my $result = shift ;
    $t->insert('end', "command result is $result\n");
  }

sub treatStdout
  {
    my $result = shift ;
    my $ref = shift ;
    $t->insert('end', "command result is $result,\nOutput is :\n".
               join("\n",@$ref)."\nend output\n");
  }

my $mw = MainWindow-> new ;

my $w_menu = $mw->Frame(-relief => 'raised', -borderwidth => 2);
$w_menu->pack(-fill => 'x');

my $f = $w_menu->Menubutton(-text => 'File', -underline => 0) 
  -> pack(side => 'left' );

$t = $mw->Scrolled(qw/ROText wrap none/) ->pack ;

my $p = VcsTools::Process -> new (
                                 command => 'll',
                                 workDir => $ENV{'PWD'},
                                  trace => $trace
                                 ) ;

#$mw -> Button (text => 'do ll', 
#               command => sub {$p->run (callback=> \&result)})
#  -> pack ;

$mw -> Button 
  (
   text => 'do ll,get result', 
   command => sub 
   {
     $t->delete('1.0','end');
     $p->pipe (callback=> \&treatStdout);
   }
  ) -> pack ;

my $s = VcsTools::Process -> new (command => 'bc',
                                  trace => $trace) ;

$mw -> Button 
  (
   text => 'do 3+4+2', 
   command => sub 
   {
     $t->delete('1.0','end');
     $s->pipeIn (input => "3+4+2\nquit\n", callback=> \&treatStdout)
   }
  ) -> pack ;


my $s2 = VcsTools::Process->new (command => 'fhist /7UP/ultimateBd.pl 2>&1',
                                  trace => $trace);

$mw -> Button 
  (
   text => 'do fhist', 
   command => sub 
   {
     $t->delete('1.0','end');
     $t->insert('end',"An error will be normal if you are not in HP TND\n\n");
     $s2->pipe (callback=> \&treatStdout)
   }
  ) -> pack ;


$f->command(-label => 'Quit',  -command => sub{$mw->destroy;} );


MainLoop ; # Tk's

print "ok 2\n";
