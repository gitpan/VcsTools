package VcsTools::Version ;

use strict;
use vars qw(@ISA $VERSION);
use Puppet::Any ;
use AutoLoader qw/AUTOLOAD/ ;

$VERSION = sprintf "%d.%03d", q$Revision: 1.1 $ =~ /(\d+)\.(\d+)/;

@ISA=qw/Puppet::Any/;

# must pass the info data structure when creating it
sub new
  {
    my $type = shift ;
    my %args = @_ ;

    my $self = new Puppet::Any(@_) ;

    # mandatory parameter
    foreach (qw/revision manager dataFormat/)
      {
        die "No $_ passed to $self->{name}\n" unless 
          defined $args{$_};
        $self->{$_} = delete $args{$_} ;
      }
    
    bless $self,$type ;
  }



1;

__END__

=head1 NAME

VcsTools::Version - Perl class to manage VCS revision.

=head1 SYNOPSIS

No synopsis given. This object is better used with the History module.

=head1 DESCRIPTION

This class represents one version of a VCS file. It holds all the 
information relevant to this version including the log of this version, the
parent revision, child revision and do on.

Its main function is to deal with the History object and its Graph Manager
object to draw the history revision tree in the Graph contained by the 
History object. The Version object will perform all necessary calls to the
drawing methods of GraphMgr to get the correct drawing. 

It can also interact with other Version object (with the help the History
object) to known who is the ancestor of 2 revisions numbers, or if this 
revision number is a child or parent of it.

The information structure stored in each Version object are described
in the dataFormat HASH reference passed to the constructor 
(See VcsTools::DataSpec::HpTnd(3) for more details).

All these information can be stored in a database. See Puppet::Any(3) for
more details.

=head1 WIDGET USAGE

Well, By itself, the Version widget cannot do much. The only function 
available is to edit the history through the "File->edit history" menu.

Future version may be better depending on user inputs.

=head1 Constructor

=head2 new('name'=> '...', ...)

Parameters are :

=over 4

=item *

revision : revision number of this version

=item *

manager : VcsTools::History object reference

=item *

dataFormat : data format HASH reference.

=back

=head1 Methods

=head1  display()

Will launch a widget for this object.

=head1  drawTree()

Will start drawing a tree (from the revision of this Version object) calling
History object's graph manager.


=cut

#'

=head1  drawSubTree(x, y, width_reference)

Called recursively to draw all nodes, internal method.

x,y are the coordinates of the root of the sub-tree. The width will be changed
to the actual width (in pixels) of the sub-tree. Note that the width of the
sub-tree depends on the number of branches.

=head1  storeLog(log_reference)

This methods takes a hash reference containing all informations extracted 
from the VCS log of this version. Then all other complementary informations
(such as upper revision, branches revisions, revision that were eventually
merged in this one) are computed and stored in the database.

=head1  editHistory(...)

Will launch a VcsTools::HistEdit widget for this version. 
All parameters will be passes as is
to the archiveHistory() method.

=head1  archiveHistory(info_hash_ref)

Will call VcsTools::History() archiveHistory method. info_hash contains all the
information to be archived in the VCS archive system.

=head1  getRevision()

Returns the revision number of this object.

=head1  getUpperRev()

Returns the revision number of the "parent" of this object.

=head1  getSubLog()

Returns the log of this version object.
 
=head1  getInfoRef()

Returns the hash ref containing all version informations.

=head1  hasParent()

Returns true if this version has a "parent" object.

=head1  findAncestor(other_revision_number)

Returns the ancestor number of this revision and the other.

Returns undef in case of problems.

=head1 AUTHOR

Dominique Dumont, Dominique_Dumont@grenoble.hp.com

Copyright (c) 1998 Dominique Dumont. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

perl(1), Tk(3), Puppet::Any(3), VcsTools::DataSpec::HpTnd(3), VcsTools::History(3)

=cut



sub display
  {
    my $self = shift ;

    return unless $self->SUPER::display();

    $self->{tk}{menu}{File}->command
      (
       -label => 'edit history',
       command => sub {$self->editHistory}
      ) ;
    
  }

sub graphWidgetDead
  {
    my $self = shift ;
    delete  $self->{graphMgr} ;
  }

sub drawTree
  {
    my $self = shift ;
    my $x = 100 ;
    my $y = 100 ;
    my $widthR = 0 ;
    
    #ask manager the graphMgr ref
    $self->{graphMgr} = $self->{manager}->getGraphMgr() 
      unless defined $self->{graphMgr} ;

    $self->{graphMgr}->clear();
    $self->drawSubTree($x,$y,\$widthR) ;
    $self->{graphMgr}->addAllMerges ;
    # We give up the equalTo stuff. Too many potential problems with it.
  }

# called recursively to draw all nodes, internal method
sub drawSubTree
  {
    my $self = shift ;
    my $x = shift ;
    my $y = shift ;
    my $widthR = shift ;

    #ask manager the graphMgr ref
    $self->{graphMgr} = $self->{manager}->getGraphMgr() 
      unless defined $self->{graphMgr} ;

    my $rev = $self->{revision} ;
    my $dbHash = $self->{"myDbHash"} ;
    my $date = $dbHash->{'date'} || '';
    $date =~ s/ .*$//;

    # print "drawing $rev : x $x y $y widthR $$widthR\n";

    my @array = ($date) ;
    push @array, @{$dbHash->{keywords}} if defined $dbHash->{keywords};
    push @array, @{$dbHash->{fix}}      if defined $dbHash->{fix} ;

    $self->{graphMgr}->addNode($rev,\@array,\$x,\$y) ;

    # check if this node is a merge
    # we must store the info now, and draw them later on.
    if (defined $dbHash->{mergedFrom})
      {
        $self->{graphMgr}->addMergeInfo($rev,$dbHash->{mergedFrom}) ;
      }

    if (defined $dbHash->{lower})
      {
        my ($lx,$ly)=($x,$y);
        $self->{graphMgr}->addDirectArrow($rev,$dbHash->{lower},
                                          \$lx,\$ly);
        $self->{manager}->getVersionObj($dbHash->{lower}) 
          ->drawSubTree($lx, $ly, $widthR );
      }
    
    if (defined $dbHash->{branches})
      {
        foreach my $branch ( @{$dbHash->{branches}} )
          {
            my ($lx,$ly)=($x,$y);
            my $subWidth = 0;
            $self->{graphMgr}->addBranchArrow($rev,$branch,\$lx,\$ly,$widthR);
            $self->{manager}->getVersionObj($branch)
              ->drawSubTree( $lx ,$ly, \$subWidth );
            $$widthR += $subWidth ;
          }
      }
    # print "end     $rev : x $x y $y widthR $$widthR\n";
  }

# return 1 if a previous object was found, 0 if not
sub storeLog
  {
    my $self = shift ;
    my $log = shift ; #hash ref
    
    # must update the info gotten from the log info
    my $tmp = $self->{revision} ;
    $tmp =~ s/(\d+)$/$1-1/e ; # decrement rev

    my $upperObj = $self->{manager}->getVersionObj($tmp) ;
    if (defined $upperObj )
      {
        if (defined $log->{previous})
          {
            die "Major problem: $self->{name} version $self->{revision} has ",
            "declared previous rev ", $log->{previous},
            " and implicit previous rev $tmp\n" 
              unless $tmp eq $log->{previous};
          }
        $log->{upper} = $tmp ;
        $upperObj->storeDbInfo(lower=> $self->{revision}) ;
      }
    elsif (defined $log->{previous})
      {
        my $prevObj = $self->{manager}->getVersionObj($log->{previous}) ;
        die "Major problem: $self->{name} version $self->{revision} has a ",
        "non-existent previous version $log->{previous}\n"
          unless defined $prevObj ;
        $log->{upper} = $log->{previous} ;
        $prevObj->storeDbInfo(lower=> $self->{revision}) ;
      }

    if (defined $log->{branches})
      {
        # find first rev of a branch (could be 4.1.1.0 or 4.1.1.1 where
        # stored branch is 4.1.1
        map 
          {
            $_ .= '.0' ;
            my $v;
            while (not defined ($v = $self->{manager}->getVersionObj($_)))
              {
                s/(\d+)$/$1+1/e ;
              };
            # actually stores the upper info
            $v->storeDbInfo (upper => $self->{revision}) ;
          }
        @{$log->{branches}} ;
      }

    if (defined $log->{mergedFrom})
      {
        my $otherObj = $self->{manager}->getVersionObj($log->{mergedFrom}) ;
        #my $upper = $log->{upper} ;
        #            $info->{mergeList}{"$upper-$other"} = $rev ;

        die "Non existant version $log->{mergedFrom} in mergedFrom field\n"
          unless defined $otherObj ;

        # emulate a push 
        my @array = defined $otherObj->{myDbHash}{mergedIn} ?
          @{$otherObj->{myDbHash}{mergedIn}} : () ;
        push @array, $self->{revision} ;
        $otherObj->storeDbInfo(mergedIn => \@array) ;
      }

    $self->storeDbInfo(%$log) ;
    
  }


sub editHistory
  {
    my $self = shift ;
    my %args = @_ ;

    my $callback = $args{callback} || sub{$self->archiveHistory(@_)} ;
    
    require VcsTools::HistEdit ;

    $self->{topTk}->HistoryEditor( name     => $self->{name}, 
                                   revision => $self->{revision}, 
                                   'format' => $self->{dataFormat},
                                   callback => $callback,
                                   'info'   => $self->{myDbHash} ) ;
  }

# can only archive an history
sub archiveHistory
  {
    my $self = shift ;
    my $infoRef = shift ;
    $self->storeLog($infoRef) ;
    
    # must call history for an update of HMS base
    $self->{manager}->archiveHistory($self->{revision},$infoRef) ;
  }

sub getRevision
  {
    my $self = shift ;
    return $self->{revision};
  }

sub getUpperRev
  {
    my $self = shift ;
    return $self->{"myDbHash"}{upper} ;
  }

sub getSubLog 
  {
    my $self = shift ;

    return $self->{myDbHash}->{'log'} ;
  }

sub getInfoRef
  {
    my $self = shift ;
    return $self->{myDbHash} ;
  }

sub hasParent
  {
    my $self = shift ;
    return defined $self->{myDbHash}{upper} ;
  }

# Does not take merges into account

# if it takes  merge into account, it will get more than one ancestor,
# in this case, the different ancestor should all be children of the other,
# then different ancestor will have to be compared to find the youngest child
# of them 

sub findAncestor
  {
    my $self = shift ;
    my $other = shift ;

    my $rev = $self->{revision} ;

    my $top = $rev ;
    my $done = {} ;

    $self->{manager}->printDebug("Searching ancestor of $rev and $other\n");

    # first look down
    if ($self->isOtherRevDown($done,$other))
      {
        $self->{manager}->printDebug("$rev is child and ancestor\n") ;
        return $rev  ;
      }

    # search higher 
    if (defined $self->{myDbHash}{upper})
      {
        my $obj = $self->{manager}->getVersionObj( $self->{myDbHash}{upper});
        if ($obj->isAncestorUp($done, $other,\$top))
          {
            $self->{manager}->printDebug("Found ancestor $top\n");
            return $top ;
          }
      }
    else
      {
        $self->{manager}->printDebug("Can't find ancestor for $rev and $other\n");
        return undef ;
      }
  }

#internal method
sub isAncestorUp
  {
    my $self = shift ;
    my $done = shift ;
    my $other = shift ;
    my $topRef = shift ;

    my $rev = $self->{revision} ; 
    
    $self->{manager}->printDebug("Looking up  rev $rev, top is $$topRef, other $other\n");
    return 0 if defined $done->{$rev} ;

    if ($rev eq $other) { $$topRef = $rev; return 1 ;} ;
    $done->{$rev} = 1 ;

    my $dbHash = $self->{"myDbHash"} ;
    # if branches search down for each branch, store $top
    if (defined $dbHash->{branches})
      {
        $$topRef = $rev ;
        foreach my $branch ( @{$dbHash->{branches}} )
          {
            return 1 if $self->{manager} -> getVersionObj($branch)
              ->isOtherRevDown($done,$other) ;
          }
      }

    # follow main branch if we come from branch
    if (defined $dbHash->{lower})
      {
        return 1 if $self->{manager} -> getVersionObj($dbHash->{lower})
          ->isOtherRevDown($done,$other);
      }

    # else go higher
    if (defined $dbHash->{upper})
      {
        return $self->{manager} -> getVersionObj($dbHash->{upper})
          ->isAncestorUp($done,$other,$topRef);
      }
    else
      {
        #else fail
        return 0 ;
      }
  }

# internal method
sub isOtherRevDown
  {
    my $self = shift ;
    my $done = shift ;
    my $other = shift ;

    my $rev = $self->{revision} ; 

    $self->{manager}->printDebug("Looking down rev $rev, other $other\n");

    return 0 if defined $done->{$rev} ;
    $done->{$rev} = 1 ;


    # if rev eq leaf return 1
    return 1 if $rev eq $other ;

    my $dbHash = $self->{"myDbHash"} ;
    # if branches search down each branch
    if (defined $dbHash->{branches})
      {
        foreach my $branch ( @{$dbHash->{branches}} )
          {
            return 1 if $self->{manager}->getVersionObj($branch)
              ->isOtherRevDown($done,$other) ;
          }
      }

    # else go down
    if (defined $dbHash->{lower})
      {
        return $self->{manager}->getVersionObj($dbHash->{lower})
          ->isOtherRevDown($done,$other);
      }
    else
      {
        #else fail
        return 0 ;
      }
  }


# Pas testee car je ne suis pas sur de l'utilite ...

# will return all child revision (including the children resulting from 
# a merge)
sub findChildren
  {
    my $self = shift ;
    my $hash = shift ; # ref of a hash
    my $level = shift ;
    
    my $rev = $self->{revision} ; 

    $self->{manager}->printDebug("Finding children of rev $rev\n");
    $hash->{$rev} =$level++ ;

    my $dbHash = $self->{"myDbHash"} ;
    foreach my $what (qw/branches mergedIn/)
      {
        # if branches search down each branch
        next unless defined $dbHash->{$what} ;

        foreach my $branch ( @{$dbHash->{$what}} )
          {
            $self->{manager}->getVersionObj($branch)
              ->findChildren($hash, $level) ;
          }
      }

    # else go down
    if (defined $dbHash->{lower})
      {
        $self->{manager}->getVersionObj($dbHash->{lower})
          ->findChildren($hash,$level) ;
      }
  }
