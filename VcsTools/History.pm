package VcsTools::History ;

use strict;
use VcsTools::Version ;
use VcsTools::GraphMgr ;
use Puppet::Any ;
use Carp ;

use vars qw($VERSION @ISA);

@ISA=qw/Puppet::Any/;
use AutoLoader qw/AUTOLOAD/ ;

$VERSION = sprintf "%d.%03d", q$Revision: 1.1 $ =~ /(\d+)\.(\d+)/;

sub new
  {
    my $type = shift ;
    my %args = @_ ;

    my $self = new Puppet::Any(@_) ;

    # mandatory name
    croak "No name passed to VcsTools::history object\n" unless
      defined $self->{name} ;

    # mandatory parameter
    foreach (qw/manager dataScanner/)
      {
        croak "No $_ passed to $self->{name}\n" unless 
          defined $args{$_};
        $self->{$_} = delete $args{$_} ;
      }


    bless $self,$type ;

    # if created the history object should either get the DB hash
    # or reload the log from the manager object
    $self->loadFromVcs() unless (defined $self->{myDbHash}) ;

#    foreach (qw//)
#      {
#        $self->{$_} = delete $args{$_} ;
#      }

    return $self ;
  }


1;

__END__

=head1 NAME

VcsTools::History - Perl class to manage a VCS history.

=head1 SYNOPSIS

 require VcsTools::DataSpec::HpTnd ; # for instance
 my $ds = new VcsTools::DataSpec::HpTnd ;
 my $hist = new VcsTools::History (dbHash => \%dbhash,
                                  keyRoot => 'history root',
                                  'topTk' => $mw,
                                  name => 'History test',
                                  dataScanner => $ds ,
                                  manager => $file_object );


=head1 DESCRIPTION

This class represents a whole history of a VCS file. It holds all the 
necessary Version object that makes the complete history of the file.

Its main function is to deal with the File object with all contained
Version objects. 

History object contains a GraphWidget that is used by the Version objects to
draw the history tree. Furthermore History object adds some bindings and
menu to the GraphWidget to offer more functionnalities from the GUI


=head1 WIDGET USAGE

The display of the history object is made of :

=over 4

=item *

A canvas to draw a revision tree.

=item *

A revision list 

=item *

A text window to display informations related to the revision tree.

=back

To draw a revision tree from a revision 'x', double click on this revision 
on the listbox on the right.

=head2 Nodes 

Each rectangle in the tree represent a revision (aka a node). 
The text in the rectangle is bound to some keys :

=over 4

=item *

button-1 selects the node for further operation (See below)

=item *

button-3 pops-up a menu

=item *

double button-1 redraws the tree from this revision

=back

The node popup menu features :

=over 4

=item *

edit History: Launch a window to modify the history of this revision

=item *

draw from here: Re-draws the tree from this revision

=item *

open version object: Opens the display of the VcsTools::Version(3) object.

=back

=head2 Arrows

Each arrow is bound to some keys :

=over 4

=item *

button-1 shows the log of this revision

=item *

button-3 pops up a menu

=back

The arrow popup menu features :

=over 4

=item *

edit History: Launch a window to modify the history of this revision

=item *

show log: shows the log of this revision

=item *

show full log: shows the full log of this revision with all fields.

=back

=head2 global features

The graph widget features a global menu invoked on the title of the graph 
widget. It features :

=over 4

=item *

unselect all: unselect all nodes.

=item *

reload from archive:
Reloads information from the VCS archive. This will also update your local 
information data base. Use this menu when other people
have worked on your VCS files.

=item *

show cumulated log: 
Will show a concatenation of logs between 2 selected revisions. One of this
revision B<must> be the ancestor of the other.

=back

The VcsTools::File(3) object have also some bindings 
(See L<VcsTools::File/"WIDGET USAGE">)

=head1 Constructor

=head2 new('name'=> '...', ...)

Will create a new history object.

Parameters are those of Puppet::Any(3) plus :

=over 4

=item *

revision : revision number of this version

=item *

manager : VcsTools::File object reference

=item *

dataScanner : VcsTools::DataSpec::HpTnd (or equivalent) object reference

=back

=head1 Methods

=head2 loadFromVcs()

Will call manager->getLog method to get the history log of the VCS file.
Then it will call storeLog().

=head2 storeLog(array_ref_of_all_log_lines)

Parses the content of the log and will create all needed Version
object from the revision listed in the history log.

=head2 hasVersion(revision)

Returns 1 if the VCS file contains this revision of the file.

=head2 sortRevisions($rev1, $rev2)

Returns ($rev1, $rev2) if $rev1 is the ancestor of $rev2, ($rev2, $rev1) in
the other case.

Croaks if the revisions are not parents.

=head2 listGenealogy($rev1, $rev2)

Returns a list of all revision between $rev1 and $rev2.

Croaks if the revision are not parents.

=head2 buildCumulatedInfo($rev1, $rev2)

Returns an info array made of a concatenation of all revision 
 between $rev1 and $rev2.

Croaks if the revisions are not parents.

=head2 archive(revision)

Will raise a window to set the log of this new version and will
archive it.

=head2 getVersionObject(revision)

Returns the object ref of the Version object representing the passed 
revision. Will create the objects as necessary. 

Returns undef if the asked revision does not exist.

=head2 getGrapghMgr()

Returns the Graph manager object reference.

=head2  display()

Will launch a widget for this object.

=head2  drawTree(revision)

Will start drawing a tree from the passed revision.

=head2 archiveHistory(revision, info_hash_ref)

Will call File object to perform the history archive.




=head1 AUTHOR

Dominique Dumont, Dominique_Dumont@grenoble.hp.com

Copyright (c) 1998 Dominique Dumont. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

perl(1), Tk(3), Puppet::Any(3), VcsTools::DataSpec::HpTnd(3), 
VcsTools::Version(3), VcsTools::File(3)

=cut




sub loadFromVcs
  {
    my $self = shift ;
    
    $self->{manager}->getLog
      (
       'callback' => sub
       {
         my $result = shift ;
         if ($result) {$self->storeLog(@_);}
         else {$self->printDebug("Can't get log of $self->{name}\n");}
       }
      );
  }

sub storeLog
  {
    my $self = shift ;
    my $log = shift ; # array ref of log lines
    
    my $hash = $self->{dataScanner} -> analyseLog($log) ;
    # must add findUpperLeaves to add lower and upper informations
    #$self->findUpperLeaves($hash) ;
    
    # must destroy and re-create all relevant version object
    $self->dropAll();

    # version hash must have all revision as keys
    my @version = keys %$hash ;

    $self->storeDbInfo(versionList => \@version);

    # must clean up the old version list
    undef $self->{version} ;

    # create the version object and store relevant info in it
    foreach my $rev (@version)
      {
        $self->getVersionObj($rev)->storeLog($hash->{$rev}) ;
      }

    # verify if all (minus 1) versions have a parent ...
    my @orphan =();
    foreach my $v (@version)
      {
        unless ($self->{content}{$v}->hasParent)
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
  }


sub hasVersion
  {
    my $self = shift ;
    my $rev = shift ;

    unless (defined $self->{version})
      {
        map( $self->{version}{$_} = 1,@{$self->{myDbHash}{versionList}}) ;
      }
    
    return defined $self->{version}{$rev} ;
  }

# return ancestor, child
sub sortRevisions
  {
    my $self = shift ;

    croak "cannot sort more than 2 revs \n" if scalar(@_) != 2 ;

    my $rev1 = shift ;
    my $rev2 = shift ;

    my $obj1 = $self->getVersionObj($rev1) ;
    
    croak "undefined version for $self->{name}  v $rev1\n" unless defined $obj1;

    my $anc = $obj1 -> findAncestor($rev2) ;

    croak "cannot sort these rev $rev1 and $rev2 for $self->{name} (different branches)\n"
      unless defined $anc and ($anc eq $rev1 or  $anc eq $rev2) ;

    return $anc eq $rev1 ? ($rev1, $rev2) :  ($rev2, $rev1) ;
  }

sub listGenealogy
  {
    my $self = shift ;
    croak "cannot sort more than 2 revs \n" if scalar(@_) != 2 ;

    my ($anc,$child) = $self->sortRevisions(@_);
    my $tmpRev = $child ;
    my @result = () ;

    while ($tmpRev ne $anc)
      {
        unshift @result, $tmpRev ;
        $tmpRev = $self->getVersionObj($tmpRev)->getUpperRev();
      }

    return \@result ;
  }

sub buildCumulatedInfo
  {
    my $self = shift ;

    croak "cannot build cumul info on more than 2 revs \n" if scalar(@_) != 2 ;
    
    my @array = ( );
    foreach (@{$self->listGenealogy(@_)})
      {
        push @array, [$_, $self->getVersionObj($_)->getInfoRef()] ;
      }
    return $self->{dataScanner}->pileLog($self->{name}, \@array);
  }

sub archive
  {
    my $self = shift ;
    my %args = @_ ;
    
    foreach (qw/revision/)
      {
        croak "No $_ passed to $self->{name}-> archive\n" unless
          defined $args{$_};
      }

    my $revision = $args{revision} ;

    croak "Can't archive an existing version ($args{revision})\n"
      if defined $self->{version}{$revision} ;
    
    # create new version object
    my $obj = $self->createVersionObj($revision) ;
    
    # store any info in this new object
    $obj->storeDbInfo($args{info}) if defined $args{info} ;

    # now edit the history of the new version
    $obj->editHistory
      (
       callback => sub
       {
         my $infoRef = shift ;
         my $str = $self->{dataScanner}->buildLogString($infoRef) ;
         $self->{manager}->checkIn
           (
            revision => $revision,
            'log' => \$str,
            state => $infoRef->{state},
            callback => sub
            {
              $self->archiveDone($args{callback},@_, $revision, $obj,$infoRef);
            }
           )
         }
      );

  }

#internal
sub archiveDone
  {
    my $self = shift ;
    my $callback = shift ;
    my $result = shift ;

    if ($result)
      {
        my $ref = shift ;
        my $revision = shift ;
        my $obj = shift ;
        $self->printDebug("Archive OK:\n".join("\n",@$ref)."\n");
        my $infoRef = shift ;
        $obj -> storeLog($infoRef) ;
        $self->{tk}{graphMgr}->addRev($revision) 
          if defined $self->{tk}{graphMgr} ;

        # store this new revision in my data base
        my @array = @{$self->{myDbHash}{versionList}};
        push @array, $revision ;
        $self->storeDbInfo(versionList => \@array) ;

        $self->{version}{$revision} =1 ;

        $self->acquire($revision,$obj) ;
        
        &$callback($result) if defined $callback ;
      }
    else
      {
        my $ref = shift ;
        $self->printDebug("Archive failed : \n".join("\n",@$ref)."\n");
      }
  }

sub getVersionObj
  {
    my $self = shift ;
    my $rev = shift ;
    return $self->{content}{$rev} if defined $self->{content}{$rev} ;

    unless (defined $self->{version})
      {
        map( $self->{version}{$_} = 1,@{$self->{myDbHash}{versionList}}) ;
      }

    if (defined $self->{version}{$rev})
      {
        my $obj = $self->createVersionObj($rev) ;
        $self->acquire($rev,$obj) ;
        return $obj ;
      }
    
    $self->printEvent("Attempted to create ghost version for rev $rev\n");
    return undef ;
  }

#internal do not call from outside because there's no sanity checks
sub createVersionObj
  {
    my $self = shift ;
    my $rev = shift ;

    $self->printDebug("Creating version object for rev $rev\n");
    
    return new VcsTools::Version  
      (
       name => "v$rev",
       keyRoot => $self->{myDbKey},
       topTk => $self->{topTk},
       dataFormat => $self->{dataScanner}->getDataFormat,
       manager => $self,
       dbHash => $self->{dbHash},
       revision => $rev
      ) ;
  }

sub getGraphMgr
  {
    my $self = shift ;
    return  $self->{tk}{graphMgr};
  }


sub display
  {
    my $self = shift ;
    return unless $self->SUPER::display();

    require Tk::Menubutton;

    # create graph Manager
    my $gmgr = $self->{tk}{graphMgr} = 
      new VcsTools::GraphMgr
        (
         'name' => $self->{name},
         'multiMgr' => $self->{tk}{'multiMgr'},
         'help'=>sub{$self->showHelp('VcsTools::History','WIDGET USAGE')}
        ) ;
    
    $gmgr->addRev(@{$self->{myDbHash}{versionList}}) ;

    # a garder TBD ?
    my $textSlave = $self->{textObj} =
      $self->{tk}{multiMgr}->newSlave
        (
         'type' => 'MultiText', 
         'title' => $self->{name},
         'hidden' => 0 ,
         'help' => 'This text window display the results of the operations '.
         'invoked within the History graph widget'
        );


    # must add menu button related to the graph funcionnality
    # i.e draw, merge, show diff
    # these function will ask for currently selected nodes


    $gmgr->command(-label=>'unselect all', 
                   command => sub{$gmgr->unselectAllNodes();});

    $gmgr->command(-label=>'reload from archive', 
                   command => sub{$self->loadFromVcs();});

    $gmgr->command
      (
       -label=>'show cumulated log', 
       command => sub
       {
         my $info = $self->buildCumulatedInfo($gmgr->getSelectedNodes()) ;
         my $str = $self->{dataScanner}->buildLogString($info) ;
         $self->showResult(1,$self->{dataScanner}->buildLogString($info));
       }
      );

    $gmgr->listBind('<Double-1>' => sub 
                    {
                      my $item = shift ;
                      my $rev = $item->get ('active') ;
                      $self->printEvent("drawing tree from rev $rev\n") ;
                      $self->drawTree($rev) ;
                    }
                   ) ;

    my $showLog = sub 
      {
        my ($from,$to) = @_ ;
        my $str = $self->{content}{$to}->getSubLog() ;
        $self->showResult(1,$str) ;
      } ;
    
    my $showFullLog = sub 
      {
        my ($from,$to) = @_ ;
        my $ref = $self->{content}{$to}->getInfoRef() ;
        my $str = $self->{dataScanner}->buildLogString($ref) ;
        $self->showResult(1,$str) ;
      } ;
    
    $gmgr->arrowBind('<1>','red', $showLog) ;
    $gmgr->arrowCommand('show log', $showLog) ;
    $gmgr->arrowCommand('show full log', $showFullLog) ;
    

    $gmgr->arrowCommand('edit History',
                        sub
                        {
                          my  ($from,$to) = @_ ;
                          $self->{content}{$to}->editHistory() ;
                        }
                       );

    $gmgr->arrowBind('<3>','orange', sub {$gmgr->popupArrowMenu(@_);}) ;


    # bind double-1 to redraw the whole graph 
    $gmgr->nodeBind('<Double-1>','black', sub {$self->drawTree(@_)});

    # bind button <3> on nodes to edit history (redundant with arrow <3> )
    $gmgr->nodeBind('<3>','red', sub {$gmgr->popupNodeMenu(@_);}) ;
    $gmgr->nodeCommand('edit History',
                    sub {
                      my $rev = shift ;
                      $self->{content}{$rev}->editHistory() ;
                    }) ;

    $gmgr->nodeCommand('draw from here',sub {$self->drawTree(@_)});
    $gmgr->nodeCommand('open version object',sub {
                      my $rev = shift ;
                      $self->{content}{$rev}->display() ;
                    }) ;
  }

sub closeDisplay
  {
    my $self = shift ;
    foreach my $version ( values %{$self->{content}})
      {
        $version->graphWidgetDead() ;
      } 

    $self->SUPER::closeDisplay() ;
  }

#internal
sub showResult
  {
    my $self = shift ;
    my $result = shift ;
    $self->{textObj}->clear() ;

    my $ref =shift ;
    my $str = ref($ref) eq 'ARRAY' ? join("\n",@$ref) : $ref ;

    if ($result)
      {
        $self->{textObj}->insertText($str) ;
      }
    else
      {
        $self->printEvent("failed command: \n$str\n");
      }
  }

sub drawTree
  {
    my $self = shift ;
    my $rev = shift ; # start from this rev

    my $revObj = $self->getVersionObj($rev);
    
    $revObj->drawTree();
  }

sub archiveHistory
  {
    my $self = shift ;
    my $rev = shift ;
    my $infoRef = shift ;

    my $str = $self->{dataScanner}->buildLogString($infoRef) ;
    $self->printEvent("Archiving history for revision $rev\n");
    $self->printDebug("Archiving history for revision $rev:\n$str\n");
    
    $self->{manager}->archiveHistory($rev,$str,$infoRef->{state}) ;
  }

1;

__END__




# Pas testee
# sub findMerge
#   {
#     my $self = shift ;
#     my $rev1 = shift ;
#     my $rev2 = shift ;

#     # find in history if rev1 and rev2 are merged. return the merge version
#     foreach (("$rev1-$rev2","$rev2-$rev1"))
#       {
#         if (defined $self->{myDbHash}{info}{mergeList}{$_}) 
#           {
#             my $rev =  $self->{myDbHash}{info}{mergeList}{$_} ;

#             while ($self->{myDbHash}{state} eq 'Dead')
#               {
#                 my $old = $rev ;
#                 $rev = $self->{myDbHash}{lower} ;
#                 unless (defined $rev)
#                   {
#                     croak "Found Dead $self->{name} version $old for merge\n"  ;
#                     return undef ;
#                   } 
#               }
#             return $rev ;
#           }
#       }

#     return undef ;
#   }
