# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..13\n"; }
END {print "not ok 1\n" unless $loaded;}
use Tk ;
use ExtUtils::testlib;
use VcsTools::GraphMgr;
require Tk::ErrorDialog; 
$loaded = 1;
my $idx = 1;
print "ok ",$idx++,"\n";
my $trace = shift || 0 ;

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

use Tk::Multi::Manager ;

use strict ;

my $mw = MainWindow-> new ;

my $w_menu = $mw->Frame(-relief => 'raised', -borderwidth => 2);
$w_menu->pack(-fill => 'x');

my $f = $w_menu->Menubutton(-text => 'File', -underline => 0) 
  -> pack(side => 'left' );
$f->command(-label => 'Quit',  -command => sub{$mw->destroy();} );

my $wmgr = $mw -> MultiManager ( 'title' => 'log test' ,
                             'menu' => $w_menu ) 
  -> pack (qw/expand 1 fill both/);

my $mgr = new VcsTools::GraphMgr('name' => 'test', multiMgr => $wmgr ) ;
print "ok ",$idx++,"\n";

$mgr -> addLabel ('big test on-going');
print "ok ",$idx++,"\n";

my $ref = [1000..1005];
my ($ox,$oy) = (100,100);

$mgr -> addNode ('1.0',$ref,\$ox,\$oy) ;
print "ok ",$idx++,"\n";

my ($x,$y)= ($ox,$oy) ;
$mgr -> addDirectArrow('1.0','1.1',\$x,\$y) ;
print "ok ",$idx++,"\n";
$mgr -> addNode ('1.1',$ref,\$x,\$y) ;
$mgr -> addDirectArrow('1.1','1.2',\$x,\$y) ;
$mgr -> addNode ('1.2',$ref,\$x,\$y) ;
$mgr -> addDirectArrow('1.2','1.3',\$x,\$y) ;
$mgr -> addNode ('1.3',$ref,\$x,\$y) ;
print "ok ",$idx++,"\n";

my ($bx,$by)=($ox,$oy) ;
my $dx ;
$mgr -> addBranchArrow('1.0','1.0.1.1',\$bx,\$by,\$dx) ;
print "ok ",$idx++,"\n";
$mgr -> addNode ('1.0.1.1',$ref,\$bx,\$by) ;
$mgr -> addDirectArrow('1.0.1.1','1.0.1.2',\$bx,\$by) ;
$mgr -> addNode ('1.0.1.2',$ref,\$bx,\$by) ;

my ($b2x,$b2y)=($ox,$oy) ;
$mgr -> addBranchArrow('1.0','1.0.2.1',\$b2x,\$b2y,\$dx) ;
$mgr -> addNode ('1.0.2.1',$ref,\$b2x,\$b2y) ;
$mgr -> addDirectArrow('1.0.2.1','1.0.2.2',\$b2x,\$b2y) ;
$mgr -> addNode ('1.0.2.2',$ref,\$b2x,\$b2y) ;

$mgr->addMergeInfo('1.2','1.0.2.1') ;
print "ok ",$idx++,"\n";

$mgr->addAllMerges() ;
print "ok ",$idx++,"\n";

$mgr->arrowBind('<1>','orange',
                sub {print "clicked arrow ",shift," -> ",shift,"\n" if $trace;});
print "ok ",$idx++,"\n";
$mgr->nodeBind('<2>','red',
                sub {print "clicked 2 on node ",shift,"\n" if $trace;});
print "ok ",$idx++,"\n";

$mgr->command(-label => 'unselect all', -command => 
              sub {$mgr->unselectAllNodes}) ;

$mgr->addRev(qw/1.1 1.2 1.4 1.3 1.0.2.1 1.0.2.3 1.0.2.2/);
print "ok ",$idx++,"\n";
MainLoop ; # Tk's

print "ok ",$idx++,"\n";

