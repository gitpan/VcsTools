package VcsTools::GraphWidget ;

use strict;
require Tk::Multi::Any;
require Tk::Derived;
require Tk::Frame;

use vars qw(@ISA $printCmd $defaultPrintCmd $VERSION);

@ISA = qw(Tk::Derived Tk::Frame Tk::Multi::Any);

$VERSION = sprintf "%d.%03d", q$Revision: 1.2 $ =~ /(\d+)\.(\d+)/;

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

$printCmd = $defaultPrintCmd = 'lp -opostscript';

Tk::Widget->Construct('MultiVcsGraph');

# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

sub Populate
  {
    my ($cw,$args) = @_ ;

    require Tk::Label;
    require Tk::ROText;

    # must add a canvas and a text window in the Multi manager
    $cw->{_printCmdRef} = \$printCmd ;
    
    my $title = delete $args->{'title'} || delete $args->{'-title'} || 
      'anonymous';
    $cw ->{'title'} = $title ;

    my $menu = delete $args->{'menu_button'} || delete $args->{'-menu_button'};
    die "Multi window $title: missing menu_button argument\n" 
      unless defined $menu ;

    my $titleLabel = $cw->Label(text => $title.' display')-> pack(qw/fill x/) ;
    my $frame = $cw -> Frame ->pack(-expand => 'yes', -fill => 'both');

    $menu->command(-label=>'print', command => [$cw, 'print' ]) ;
    $menu->command(-label=>'clear', command => [$cw, 'clear' ]);

    my $list = delete $args->{'list'} ;

    my $listW = $frame -> Scrolled(qw/Listbox -scrollbars osoe width 14/)->
        pack(-side => 'right', -expand => 0, -fill => 'y');
    $cw->Advertise(list => $listW) ;

    my $slaveWindow = $frame -> Scrolled(qw/Canvas relief sunken bd 2/,
                       -scrollregion => [0,0,400 , 200]
                     )->
        pack(-side => 'right', -expand => 'yes', -fill => 'both');
    $cw->Advertise(graph => $slaveWindow) ;
    
    $cw->Delegates('command' => $menu, 
                   'clear' => $slaveWindow,
                   DEFAULT => $slaveWindow) ;

    my $subref = sub {$menu->Popup(-popover => 'cursor', -popanchor => 'nw')};
    #$slaveWindow-> bind('<Button-3>', $subref);
    $titleLabel -> bind('<Button-3>', $subref);

    $cw->ConfigSpecs(
                     'relief' => [$cw],
                     'borderwidth' => [$cw],
                     'scrollbars'=> [$slaveWindow, undef, undef,'osoe'],
                     'width' => [$slaveWindow, undef, undef, 80],
                     'height' => [$slaveWindow, undef, undef, 5],
                     'DEFAULT' => [$slaveWindow]
                    ) ;

    $cw->SUPER::Populate($args);

    $listW->insert(0,@$list) if defined $list ;
  }

sub clear
  {
    my $cw = shift ;
    $cw->delete('all');
  }

sub resetPrintCmd
  {
    my $cw=shift ;
    $printCmd=$defaultPrintCmd ;
  }

sub printableDump
  {
    my $cw= shift ;
    my $array = $cw->cget('scrollregion') ;

    return  $cw-> postscript
      (qw/-colormode gray pageheight 29c pagewidth 21c/,
       -width        => $array->[2],
       -height       => $array->[3]);
  }


1;

__END__

# Below is the stub of documentation for your module. You better edit it!

=head1 NAME

Tk::Multi::Canvas - Tk composite widget with a scroll window and more

=head1 SYNOPSIS

 use Tk::Multi::Manager;

 use VcsTools::GraphWidget;

 my $wmgr = $mw -> MultiManager ( 'title' => 'log test' ,
                             'menu' => $w_menu ) -> pack ();

 $toto = $wmgr -> newSlave('type'=>'MultiVcsGraph', title => 'graph try',
                         'list' => [1 .. 50 ]) ;
 $toto -> createLine(1,1,100,100, -fill => 'red') ;

=head1 DESCRIPTION

This composite widget is intented to provide a canvas to draw a VCS revision
tree associated with a listbox containing a list of all the revisions.

Note that this widget is derived from Tk::Multi::Any, hence all the 
functionnalities provided by the Tk::Multi module are provided to this
widget.

This widget features :

=over 4

=item *

a scrollable Canvas. This canvas should be used to draw the revision graph

=item *

A print button (The shell print command may be modified by setting 
$printCmd to the appropriate shell command. By default, 
it is set to 'lp -opostscript') 

=item *

a clear button

=item * 

a list box 

=back

This widget will forward all unrecognized commands to the Canvas object.

Note that this widget should be created only by the Multi::Manager. 

=head1 WIDGET-SPECIFIC OPTIONS

=head2 title

Some text which will be displayed above the test window. 

=head2 menu_button

The log window feature a set of menu items which must be added in a menu.
This menu ref must be passed with the menu_button prameter 
to the object during its instaciation

=head1 WIDGET-SPECIFIC METHODS

=head2 print()

Will raise a popup window with an Entry to modify the actual print command,
a print button, a default button (to restore the default print command),
and a cancel button.

=head2 doPrint()

Print the label and the content of the text window. The print is invoked
by dumping the text content into a piped command.

You may want to set up a new command to print correctly on your machine.
You may do it by using the setPrintCmd method or by invoking the 
'print' method.

=head2 setPrintCmd('print command')

Will set the $printCmd class variable to the passed string. You may use this
method to set the appropriate print command on your machine. Note that 
using this method will affect all other Tk::Multi::Canvas object since the
modified variable is not an instance variable but a class variable.

=head2 clear()

Is just a delete('1.0','end') .

=head1 Delegated methods

By default all widget method are delegated to the Text widget. Excepted :

=head2 command(-label => 'some text', -command => sub {...} )

Delegated to the menu entry managed by a Tk::Multi::Manager. 
Calling this method will add a new command to the aforementionned menu.

=head1 TO DO

I'm not really satisfied with print management. May be one day, I'll write a 
print management composite widget which will look like Netscape's print 
window. But that's quite low on my priority list. Any volunteer ?

=head1 AUTHOR

Dominique Dumont, Dominique_Dumont@grenoble.hp.com

Copyright (c) 1998 Dominique Dumont. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

perl(1), Tk(3), Tk::Multi(3), Tk::Multi::Manager(3)

=cut
