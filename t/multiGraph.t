# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..4\n"; }
END {print "not ok 1\n" unless $loaded;}
use Tk ;
use ExtUtils::testlib;
use Tk::Multi::Manager;
use VcsTools::GraphWidget;
require Tk::ErrorDialog; 
$loaded = 1;
my $idx = 1;
print "ok ",$idx++,"\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

use strict ;
my $toto ;
my $mw = MainWindow-> new ;

my $w_menu = $mw->Frame(-relief => 'raised', -borderwidth => 2);
$w_menu->pack(-fill => 'x');

my $f = $w_menu->Menubutton(-text => 'File', -underline => 0) 
  -> pack(side => 'left' );
$f->command(-label => 'Quit',  -command => sub{$mw->destroy;} );

my $wmgr = $mw -> MultiManager ( 'title' => 'log test' ,
                             'menu' => $w_menu ) 
  -> pack (qw/expand 1 fill both/);

$toto = $wmgr -> newSlave('type'=>'MultiVcsGraph', title => 'graph try',
                         'list' => [1 .. 50 ]) ;
print "ok ",$idx++,"\n";
$toto -> createLine(1,1,100,100, -fill => 'red') ;
print "ok ",$idx++,"\n";

MainLoop ; # Tk's

print "ok ",$idx++,"\n";
