package VcsTools::GraphMgr ;

use Tk ;
use VcsTools::GraphWidget ;
use Carp ;

use strict;
use vars qw(@ISA $VERSION $arrow_dy $branch_dx);
use AutoLoader qw/AUTOLOAD/ ;

$VERSION = sprintf "%d.%03d", q$Revision: 1.1 $ =~ /(\d+)\.(\d+)/;

# use this to tune the shape of nodes and arrows
$arrow_dy = 40 ;
$branch_dx = 120 ;

sub new
  {
    my $type = shift ;
    my %args = @_ ;

    my $self = {} ;
    
    # must add a canvas and a text window in the Multi manager
    foreach (qw/name multiMgr/)
      {
        $self->{$_} = delete $args{$_} ;
      }

    my $name     = $self->{'name'} ;
    my $multiMgr = $self->{'multiMgr'} ;

    $self->carp("GraphMgr $name: no multi manager passed\n") 
      unless defined $multiMgr;

    my $graphSlave = $self->{graphObj} =
      $multiMgr->newSlave('type' => 'MultiVcsGraph', 
                          'title' => $name.' history graph',
                          'hidden' => 0,
                          'help' => $args{help});

    $self->{graph}{selected} = {} ; #empty hash

    # bind button <1> on nodes to select a version
    $graphSlave->bind ('node', 
                       '<1>' => sub {$self->toggleCurrentNode('blue')});

    bless $self,$type ;
  }


1;

__END__

=head1 NAME

VcsTools::GraphMgr - Perl class to draw VCS revision in a GraphWidget

=head1 SYNOPSIS

 use Tk ;
 use VcsTools::GraphMgr;
 use Tk::Multi::Manager ;

 use strict ;

 my $mw = MainWindow-> new ;

 my $wmgr = $mw -> MultiManager ( 'title' => 'log test' ,
                             'menu' => $w_menu ) -> pack ();

 my $mgr = new VcsTools::GraphMgr('name' => 'test', multiMgr => $wmgr ) ;

 $mgr -> addLabel ('big test on-going');

 my $ref = [1000..1005];
 my ($ox,$oy) = (100,100);

 $mgr -> addNode ('1.0',$ref,\$ox,\$oy) ;

 my ($x,$y)= ($ox,$oy) ;
 $mgr -> addDirectArrow('1.0','1.1',\$x,\$y) ;
 $mgr -> addNode ('1.1',$ref,\$x,\$y) ;

 my ($bx,$by)=($ox,$oy) ;
 my $dx ;
 $mgr -> addBranchArrow('1.0','1.0.1.1',\$bx,\$by,\$dx) ;
 $mgr -> addNode ('1.0.1.1',$ref,\$bx,\$by) ;
 $mgr->arrowBind('<1>','orange',
                sub {print "clicked arrow ",shift," -> ",shift,"\n";});
 $mgr->nodeBind('<2>','red',
                sub {print "clicked 2 on node ",shift,"\n";});

 $mgr->command(-label => 'unselect all', -command => 
               sub {$mgr->unselectAllNodes}) ;

 MainLoop ; # Tk's


=head1 DESCRIPTION

GraphMgr is a class designed to help to draw revision graph on the 
VcsTools::GraphWidget.

GraphMgr is able to draw the following items:

=over 4

=item *

node: some text for each revision of your VCS file.

=item *

direct arrow: an arrow to represent a regular new version 
(e.g. from revision 1.1 to revision 1.2)

=item *

branch arrow: an arrow to represent a new branch (e.g. from 
revision 1.1 to revision 1.1.1.1)

=item *

merges arrow: an arrow to represent a merge between 2 revisions from
different branches.

=back

GraphMgr also provides :

=over 4

=item *

a binding on nodes on button 1 to 'select' them.

=item *

Methods to bind nodes and arrows on user's call-back.

=item *

a command method to easily add menu command.

=back

=cut

#'

=head1 Constructor

=head2 new('name'=> '...', 'multiMgr' => 'object_ref', ['help' => ...])

multiMgr is the Tk::Multi::Manager object. The help parameter value
is forwarded as is to the newSlave() method of Tk::Multi::Manager(3).

=head1 Drawing Methods

In each drawing methods, passing a reference (here x_ref, y_ref and 
delta_x_ref) means that the value refered to will be modified by the
method.

Note that all revision parameters as treated as string.

=head2 addDirectArrow(revision,next_revision, x_ref, y_ref)

Add a new staight (i.e. vertical) revision arrow from coordinate (x,y).

x and y are modified so that their new value is the coordinate of the tip
of the arrow.

=head2 addBranchArrow(revision,branch_revision, x_ref, y_ref, delta_x_ref)

Add a new branch to revision 'revision'. The first revision of this new
branch being 'branch_revision'.

The arrow will be drawn from (x,y) to (x+delta_x, y).

x and y are modified so that their new value is the coordinate of the tip
of the arrow.

delta_x is modified so that the next branch drawn using this delta_x value
will not overlap the first branch.

=head2 addLabel(text)

Put some text on the top of the graph.

=head2 addMergeInfo(revsion, merge_from_revision)

Declare that node 'revision' is a merge between the staight upper node 
(whose revision number does not need to be passed to this function) and
the node 'merge_from_revision'.

=head2 addAllMerges()

This method is to be called once all nodes, direct arrow and branch arrow
are drawn and all relevant calls to addAllMerges are done. 
It will add merge arrows between the revision declared with 
the addMergeInfo method.

=head2 addNode(revision,text_array_ref, x_ref, y_ref)

Will add a new node (made of a rectangle with the text inside). The node
will be drawn at coordinate (x,y)

x and y are modified so that their new value is the coordinate of the tip
of the arrow.

Note that this method will add 'vx.y' (i.e. the revision number)
on top of the text.

=head2 clear()

Clear the graph.

=head1 Management methods

=head2 command(-label => 'some text', -command => sub {...} )

Delegated to the menu entry managed by Multi::Manager. Calling this method
will add a new command to the aforementionned menu.

=head2 graphSlave()

Returns the ref of the graph widget.

=head2 nodeBind(button, color, sub{my $rev = shift; ...  })

Bind the 'button' on nodes. When 'button' is clicked, the node text color will
change to 'color' and the callback sub will be called with the revision number
as parameter.

=head2 arrowBind(button, color, sub{ ...})

Bind the 'button' on arrows. When 'button' is clicked, the arrow color will
change to 'color' and the callback sub will be called with the revision number
attached to the start of the arrow as first parameter and the revision number
attached to the tip of the arrow as second parameter.

The callback should be in this form :

 sub 
   {
     my $rev = shift;    # base of the arrow
     my $tiprev = shift; # tip of the arrow
     ...
   }

=head2 unselectAllNodes()

Unselect all previously selected nodes (see button <1> binding)

=head2 getSelectedNodes()

Return an array containing the version of currently selected nodes.

=head2 addRev( revision ,.. )

Add the passed revision in the revision listbox

=head2 listBind('<a button>' => sub {...} )

Bind the sub on the <a button> click on the revision list. All parameter
of listBinf() are passed as to the Tk bind command.

=head1 Private methods

=head2 resetColor(canvas_item_id)

Put the color of the canvas item back to black.

=head2 setSelArrow(color)

Will set the current arrow to the color.

=head2 setSelNode(color)

Will set the current node text to the color.

=head2 toggleCurrentNode(color)

Will toggle the current node rectangle to the color or to black.

=head2 toggleNode(id,color)

Will toggle the node (with text id) rectangle to the color or to black.

=head1 AUTHOR

Dominique Dumont, Dominique_Dumont@grenoble.hp.com

Copyright (c) 1998 Dominique Dumont. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

perl(1), Tk(3), Tk::Multi::Manager(3), VcsTools::GraphWidget(3)

=cut

sub graphSlave
  {
    my $self = shift ;
    return $self->{graphObj} ;
  }

sub addRev
  {
    my $self = shift ;
    my $l = $self->graphSlave()->Subwidget('list') ;
    
    foreach my $rev (@_)
      {
        my @full = $l -> get (0, 'end') ;
        my $index = 0;
        foreach (@full)
          {
            return if ($_ eq $rev) ; 
            last if ($_ gt $rev);
            $index++;
          } 

        $l->insert($index,$rev) ;
      }
  }

sub listBind
  {
    my $self = shift ;
    $self->graphSlave()->Subwidget('list')->bind(@_);
  }

sub command
  {
    my $self = shift ;
    return $self->{graphObj}->command(@_) ;
  }

# will call-back sub with ($start_revision,$tip_revison) rev numbers
sub arrowBind
  {
    my $self = shift ;
    my $button = shift ;
    my $color = shift ;
    my $callback = shift ;

    # bind button <1> on arrows to display history information
    $self->{graphObj}->bind
      (
       'arrow', $button => sub 
       {
         my @revs = $self->setSelArrow($color) ;
         $self->{graphObj}->idletasks;
         &$callback(@revs) ;
       });
  }

# will call-back sub with ($start_revision,$tip_revison) rev numbers
sub arrowCommand
  {
    my $self = shift ;
    my $label = shift ;
    my $sub = shift ;
    
    $self->{'arrowCommand'}{$label} = $sub ;
  }

sub popupArrowMenu
  {
    my $self = shift ;
    my ($from,$to) = @_ ;

    my $menu = $self->{graphObj} -> Menubutton (-text => 'menu test');
    foreach (keys %{$self->{'arrowCommand'}})
      {
        my $s = $self->{'arrowCommand'}{$_};
        $menu -> command
          (
           -label => $_, 
           '-command' => sub {&$s($from,$to) ;}
          );
      }
    $menu->menu->Popup(-popover => 'cursor', -popanchor => 'nw');
    
  }

# will return with $revison numbers
sub toggleCurrentNode
  {
    my $self = shift ;
    my $color = shift ;

    my $id = $self->{graphObj}->find('withtag' => 'current');
    $self->toggleNode($id,$color);
  }

sub toggleNode
  {
    my $self = shift ;
    my $id = shift ;
    my $color = shift ;

    my $rev = $self->{graph}{nodeRev}{$id} ;
    my $rid = $self->{graph}{nodeRect}{$rev} ; # retrieve id of rectangle

    if (defined $self->{graph}{selected}{$rev})
      {
        $self->{graphObj}->itemconfigure($rid, outline => 'black') ; #unselect
        $self->{graph}{fill}{$rid} = 'black' ;
        delete $self->{graph}{selected}{$rev} ;
      } 
    else
      {
        die "Error no color specified while selecting node\n"
          unless defined $color ;
        $self->{graphObj}->itemconfigure($rid, outline => $color) ;
        $self->{graph}{fill}{$rid} = $color ;
        $self->{graph}{selected}{$rev} = $id ; # store id of text
      } 

    $self->{graphObj}->idletasks;
    return $rev ;
  }

sub getSelectedNodes
  {
    my $self = shift ;
    return keys %{$self->{graph}{selected}} ;
  }

sub unselectAllNodes
  {
    my $self = shift ;

    foreach my $id (values %{$self->{graph}{selected}})
      {
        $self->toggleNode($id);
      }
  }

# will call-back sub with node $rev
sub nodeBind
  {
    my $self = shift ;
    my $button = shift ;
    my $color = shift ;
    my $callback = shift ;

    $self->{graphObj}->bind
      (
       'node', $button => sub 
       {
         my $rev = $self->setSelNode($color) ;
         $self->{graphObj}->idletasks;
         &$callback($rev) ;
       });
  }

# will call-back sub with node $rev
sub nodeCommand
  {
    my $self = shift ;
    my $label = shift ;
    my $sub = shift ;
    
    $self->{nodeCommand}{$label}= $sub ;
  }

sub popupNodeMenu
  {
    my $self = shift ;
    my $rev = shift ;

    my $menu = $self->{graphObj} -> Menubutton (-text => 'menu test');
    foreach (keys %{$self->{'nodeCommand'}})
      {
        my $s = $self->{'nodeCommand'}{$_};
        $menu -> command
          (
           -label => $_, 
           '-command' => sub {&$s($rev) ;}
          );
      }
    $menu->menu->Popup(-popover => 'cursor', -popanchor => 'nw');
    
  }

# will return with ($tip_revison,$start_revision) rev numbers
sub setSelNode
  {
    my $self = shift ;
    my $color = shift ;
    
    my $id = $self->{graphObj}->find('withtag' => 'current');
    return $self->setNodeId($id,$color) ;
  }

sub setNodeId
  {
    my $self = shift ;
    my $id = shift ;
    my $color = shift ;
    
    # reset any selected Node
    $self->resetColor($self->{graph}{oldNode}) 
      if (defined $self->{graph}{oldNode});

    $self->{graph}{oldNode} = $id ;
    $self->{graphObj}->itemconfigure($id, fill => $color) ;

    return $self->{graph}{nodeRev}{$id} ;
  }

sub setNodeRev
  {
    my $self = shift ;
    my $rev = shift ;
    my $color = shift ;
    
    my $id = $self->{graph}{nodeId}{$rev} ;

    unless (defined $id)
      {
        $self->{graphObj}->bell ;
        return ;
      }
    return $self->setNodeId($id,$color) ;
  }

# will return with ($start_revision,$tip_revison) rev numbers
sub setSelArrow
  {
    my $self = shift ;
    my $color = shift ;
    
    # reset any selected arrow
    $self->resetColor($self->{graph}{oldArrow}) 
      if (defined $self->{graph}{oldArrow});

    my $id = $self->{graphObj}->find('withtag' => 'current');
    $self->{graph}{oldArrow} = $id ;
    $self->{graphObj}->itemconfigure($id, fill => $color) ;
    my $tipRev = $self->{graph}{arrowTip}{$id} ;
    my $endRev = $self->{graph}{arrowStart}{$id} ;

    return ($endRev,$tipRev) ;
  }


sub resetColor
  {
    my $self = shift ;
    my $id = shift ;
    my $color = $self->{graph}{fill}{$id} || 'black' ;
    $self->{graphObj}->itemconfigure($id,fill => $color) ;
  }

sub clear
  {
    my $self = shift ;
    delete $self->{graph} ;
    $self->{graphObj}-> clear() ;
    $self->{graphObj}->configure(scrollregion => [0,0, 1000 , 400 ])
  }

sub addLabel
  {
    my $self = shift ;
    my $text = shift ;
    
    $self->{graphObj}->create('text', '7c' , 5 , anchor => 'n' , 
                               text=> $text, justify => 'center') ;
  }

# draw a node, return the y coord of the bottom of the node 
#($x does not change)
sub addNode
  {
    my $self = shift ;
    my $rev = shift ;
    my $textArrayRef = shift ;
    my $xr = shift ;
    my $yr = shift ;

    my $c = $self->{graphObj} ;

    # compute x coord 
    # find lower node and call addNode

    $self->{graph}{topCoord}{$rev} = [ $$xr, $$yr] ; # top of node text
    my $oldy = $$yr ;

    $$yr += 5 ; # give some breathing space 

    my $text = "v$rev\n".join ("\n", @$textArrayRef)."\n";

    # compute y coord
    # draw node
    my $tid = $c->create('text', $$xr, $$yr, text=>$text, justify => 'center', 
                         anchor => 'n' , width => '12c', tags => 'node') ;

    $$yr += 14 * (1+ scalar(@$textArrayRef)) + 10 ;

    my $rid = $c->create('rectangle', 
                         $$xr - $branch_dx/2 + 10 , $oldy,
                         $$xr + $branch_dx/2 - 10 , $$yr,
                         width => 2 
                        ) ;

    $self -> {graph}{nodeRev}{$tid}=$rev ;
    $self -> {graph}{nodeId}{$rev}=$tid ;
    $self -> {graph}{nodeRect}{$rev}=$rid ;

    $self->{graph}{bottomCoord}{$rev} = [ $$xr, $$yr] ; # bottom of node text

    my $array = $c->cget('scrollregion') ;
    my $incx = $array->[2] < $$xr ? 200 : 0 ;
    my $incy = $array->[3] < $$yr ? 200 : 0 ;

    if ($incx>0 or $incy>0)
      {
        my $newx = $array->[2] + $incx ;
        my $newy = $array->[3] + $incy ;
        $c->configure(scrollregion => [0,0, $newx , $newy ])
      }
  }

sub addMergeInfo
  {
    my $self = shift ;
    my $rev = shift ;
    my $mRev = shift ;
    $self->{graph}{mergeFrom}{$rev} = $mRev ;
  }

# add a an arrow for a regular revision, return the new $$yr at the bottom of
# the arrow
sub addDirectArrow
  {
    my $self = shift ;
    my $rev = shift ;
    my $lowerRev = shift ;
    my $xr = shift ;
    my $yr = shift ;

    my $old_y = $$yr;
    $$yr = $old_y + $arrow_dy ; # give length of arrow

    my $id = $self->{graphObj}->create('line', $$xr, $old_y, $$xr, $$yr ,  
                                       qw(-arrow last -tags arrow));
    $self->{graph}{arrowStart}{$id} = $rev ;
    $self->{graph}{arrowTip}{$id} = $lowerRev ;
    $self->{graph}{fill}{$id} = 'black' ;
  }
    
sub addBranchArrow
  {
    my $self = shift ;
    my $rev = shift ;
    my $branch = shift ;
    my $xr = shift ;
    my $yr = shift ;
    my $dxr = shift ; # must be undef or null for first branch

    $$dxr = 0 unless defined $dxr ;
    $$dxr += $branch_dx  ;

    my $old_x = $$xr ;
    my $old_y = $$yr ;

    $$yr += $arrow_dy ; # give length of arrow
    $$xr += $$dxr ;

    my $id = $self->{graphObj}->create('line', $old_x, $old_y, 
                                       $$xr, $$yr,  
                                       qw(arrow last tags arrow));


    $self->{graph}{arrowStart}{$id} = $rev ;
    $self->{graph}{arrowTip}{$id} = $branch ;
    $self->{graph}{fill}{$id} = 'black' ;
  }

sub addAllMerges
  {
    my $self = shift ;
    my $c = $self->{graphObj} ;

    foreach my $rev (keys %{$self->{graph}{mergeFrom}})
      {
        my $mRev = $self->{graph}{mergeFrom}{$rev} ;
        next unless defined $self->{graph}{bottomCoord}{$mRev} ;
        my ($x, $y) = @{$self->{graph}{bottomCoord}{$mRev}} ;
        my ($dx, $dy) = @{$self->{graph}{topCoord}{$rev}} ;
        my $id = $c->create('line', $x, $y, $dx, $dy,  
               'arrow' => 'last', 'tag' => 'arrow','fill'=> 'orange');
        $self->{graph}{fill}{$id} = 'orange' ;
        $self->{graph}{arrowStart}{$id} = $mRev ;
        $self->{graph}{arrowTip}{$id} = $rev ;
      }
  }

