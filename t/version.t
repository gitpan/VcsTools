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
use VcsTools::Version;
use VcsTools::GraphMgr;
use Fcntl ;
use MLDBM qw(DB_File);
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
     { 'name' => 'interface change' , 'type' => 'enum','var' => 'interfaceChange',
       'values' => $changeData },
     { 'name' => 'inter-peer change' , 'type' => 'enum','var' => 'interPeerChange',
       'values' => $changeData },
     { 'name' => 'misc' , 'var' => 'log', 'type' => 'text', 'pile' => 'concat'}
  ];

sub new 
  {
    my $type = shift ;

    my $self = new Puppet::Any(@_) ;
    
    bless $self,$type ;
  }

sub getGraphMgr 
  {
    my $self = shift ;
    return $self->{gmgr} ;
  }

sub display
  {
    my $self = shift ;
    $self->SUPER::display();

    my $gmgr = new VcsTools::GraphMgr('name' => 'dummy', 
                                      'multiMgr' => $self->{tk}{multiMgr}) ;
    $self->{gmgr} = $gmgr;

    my @v_new=  (
                 keyRoot => $self->{myDbKey},
                 topTk => $self->{tk}{toplevel},
                 dataFormat => $logDataFormat,
                 manager => $self,
                 dbHash => $self->{dbHash}) ;

    my %info = (
                'log' => "Nothing to tell\n",
                keywords => [qw/salut les copains/],
                date => '23/03/98'
               );

    $gmgr->command(-label=>'find ancestor', 
                   command =>
                   sub{
                     my @revs = $gmgr->getSelectedNodes();
                     if (defined @revs and scalar(@revs) == 2)
                       {
                         my $rev = shift @revs;
                         my $anc = $self->getVersionObj($rev)->
                           findAncestor(shift @revs);
                         # must set color of ancestor node TBD
                         $gmgr->setNodeFromRev($anc,'brown');
                       }
                     else
                       {
                         print scalar(@revs)," nodes selected\n";
                       }
                   });

    $gmgr->command(-label=>'unselect all', 
                   command => sub{$gmgr->unselectAllNodes();});

    foreach my $root (qw/1. 1.1.1. 1.2.1. 1.4.1. 1.1.1.2.1. 2./)
      {
        foreach my $i (1 .. 5 )
          {
            my $v = $root.$i ;
            # warn "making version $v\n";
            my $name = 'v'.$v ;
            $self->{version}{$v} = 
              new VcsTools::Version (name => $name,
                                     @v_new,revision => $v) ;
            $self->acquire($name,$self->{version}{$v});

            $gmgr->addRev($v) ;
          }
      }

    # store info after all version objects are known by getVersionObj
    foreach my $v (keys %{$self->{version}})
      {
        my %local = %info ;
        $local{branches} = ['1.1.1','1.2.1']     if $v eq '1.1' ;
        $local{branches} = ['1.1.1.2.1'] if $v eq '1.1.1.2' ;
        $local{branches} = ['1.4.1']     if $v eq '1.4' ;
        $local{mergedFrom} = '1.1.1.1'   if $v eq '1.3' ;
        
        $self->{version}{$v}->storeLog (\%local);
      }

    my @orphan =();
    foreach my $v (keys %{$self->{version}})
      {
        unless ($self->{version}{$v}->hasParent)
          {
            $self->printEvent("Version $v has no previous version\n");
            push @orphan,$v;
          }
      }

    if (scalar @orphan > 1)
      {
        $self->printEvent
          ("Warning: $self->{name} has more than one revision without parent\n". join(' - ',@orphan)."\n") ;
        $self->showEvent();
      }

    $gmgr->listBind('<Double-1>' =>
                    sub  {
                      my $item = shift ;
                      my $name = $item->get ('active') ;
                      $self->{version}{$name}->drawTree() ;
                    }
                   );
    
    $gmgr->listBind
      (
       '<2>' =>
       sub  {
         my $item = shift ;
         my $name = $item->get ('active') ;
         $gmgr->graphSlave()->
           ObjScanner('top' => 1,
                      'caller' =>$self->getVersionObj($name)) ;
       }
      );
    $gmgr->listBind
      (
       '<3>' =>
       sub  {
         my $item = shift ;
         my $name = $item->get ('active') ;
         $self->getVersionObj($name)->display(graphMgr => $gmgr) ;
       }
      );
    
    
#    $mgr->arrowBind('<1>','orange',
#                    sub {print "clicked arrow ",shift," -> ",shift,"\n";});
#    $mgr->nodeBind('<2>','red',
#                   sub {print "clicked 2 on node ",shift,"\n";});

#    $mgr->command(-label => 'unselect all', -command => 
#                  sub {$mgr->unselectAllNodes}) ;

#    # create version sub objects

  }

sub getVersionObj
  {
    my $self = shift ;
    my $rev = shift ;
    if (defined $self->{version}{$rev})
      {
        return $self->{version}{$rev} ;
      }
    return undef ;
  }

package main ;

use Tk::Multi::Manager ;

use strict ;

my $file = 'test.db';
unlink($file) if -r $file ;

my %dbhash;
tie %dbhash,  'MLDBM',    $file , O_CREAT|O_RDWR, 0640 or die $! ;

#my $mw = MainWindow-> new ;

#my $w_menu = $mw->Frame(-relief => 'raised', -borderwidth => 2);
#$w_menu->pack(-fill => 'x');

#my $f = $w_menu->Menubutton(-text => 'File', -underline => 0) 
#  -> pack(side => 'left' );
#$f->command(-label => 'Quit',  -command => sub{$mw->destroy;} );


my $mgr = new Dummy (dbHash => \%dbhash,
                     keyRoot => 'key root',
                     name =>"dummy history");
$mgr -> display() ;

MainLoop ; # Tk's

print "ok 2\n";
