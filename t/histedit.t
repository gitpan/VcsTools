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
use VcsTools::HistEdit;
require Tk::ErrorDialog; 
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

package Dummy ;
use Puppet::Any ;
use vars qw(@ISA);
@ISA=qw/Puppet::Any/;


  my $bChangeData = ['none', 'cosmetic', 'minor','major'] ;
  my $changeData = ['none', 'cosmetic', 'major'] ;
  my @state = qw(Dead Exp Team Lab Special Product) ;

  # each entry is a hash made of 
  # - name : name of the field stored in log
  # - var : variable name used in internal hash (default = name) 
  # - type : is line, enum or array or text
  # - values : possible values of enum type
  # - mode : specifies if the value can be modified (r|w) (default 'w')
  # - pile : define how to pile the data when building a log resume.
  # - help : help string
  
my $logDataFormat = 
    [
     { 'name' => 'state', 'type' => 'enum',  'values' => \@state},
     { 'name' => 'date', 'type' => 'line', 'mode' => 'r' },
     { 'name' => 'merged from', 'type' => 'line','var' => 'mergedFrom' },
     { 'name' => 'comes from', 'type' => 'line','var' => 'previous', 
       'help' => 'enter a version if it cannot be figured out by the tool' },
     { 'name' => 'equal to', 'type' => 'line','var' => 'equalTo','type' => 'array' },
     # will fit better in the description field TBD
     #   { 'name' => 'visibility', 'values' => ['none', 'team', 'lab','client']},
     { 'name' => 'writer','type' => 'line', 'mode' => 'r' },
     { 'name' => 'keywords', 'type' => 'array', 'pile' => 'push' },
     { 'name' => 'fix','type' => 'array','pile' => 'push',
       'help' => 'enter number a la GREhp01243' },
     { 'name' => 'behavior change' , 'type' => 'enum','var' => 'behaviorChange',
       'values' => $bChangeData },
     { 'name' => 'misc' , 'var' => 'log', 'type' => 'text', 'pile' => 'concat',
     'help' => {'class' => 'Puppet::Any', 'section' => 'DESCRIPTION'} }
  ];


sub new 
  {
    my $type = shift ;

    my $self = new Puppet::Any(@_) ;

    $self->{info} = {'log' => "Nothing to tell\n"} ;
    bless $self,$type ;
  }

sub display
  {
    my $self = shift ;
    $self->SUPER::display();
    $self->{tk}{menu}{File}->command(-label=>'edit',
                                     -command => sub{$self->editH()});
  }

sub editH
  {
    my $self = shift ;
    
    $self->{topTk}->HistoryEditor( name => 'dummy', 
                                   revision=> '1.1', 
                                   'format' => $logDataFormat,
                                   callback => sub{$self->setInfo(@_)}, 
                                   'info' => $self->{info} ) ;
  }

sub setInfo
  {
    my $self = shift ;
    my $new = shift ; # hash ref
    $self->{info}=$new ;
  }

package main ;


use strict ;

#my $mw = MainWindow-> new ;

#my $w_menu = $mw->Frame(-relief => 'raised', -borderwidth => 2);
#$w_menu->pack(-fill => 'x');

#my $f = $w_menu->Menubutton(-text => 'File', -underline => 0) 
#  -> pack(side => 'left' );
#$f->command(-label => 'Quit',  -command => sub{$mw->destroy;} );

my $d = new Dummy(name =>"dummy history");
$d -> display();
$d -> editH ;

MainLoop ; # Tk's

print "ok 2\n";

