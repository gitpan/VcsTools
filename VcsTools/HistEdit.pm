package VcsTools::HistEdit ;

use strict;
require Tk::Derived;

use vars qw(@ISA $VERSION %histInfo) ;
# %histInfo is used as a pool of historic logs used for recalls


$VERSION = sprintf "%d.%03d", q$Revision: 1.1 $ =~ /(\d+)\.(\d+)/;

@ISA = qw(Tk::Derived Tk::Toplevel);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

Tk::Widget->Construct('HistoryEditor');

# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

sub Populate
  {
    my ($cw,$args) = @_ ;
    
    # mandatory parameters
    # format : logDataFormat ref
    # manager : History or File object
    # info : hash to edit and/or fill
    foreach (qw/name format callback revision/)
      {
        $cw->BackTrace("$cw: No $_ defined\n") unless defined $args->{$_};
        $cw->{$_} = delete $args->{$_} ;
      }
    
    $cw->{'info'} = delete $args->{'info'} || {} ;

    my $version = $cw->{revision} ;

    $cw -> Label(text => "Edit history of $cw->{name}, version $version") 
      -> pack ;
    
    foreach my $item (@{$cw->{'format'}})
      {
        $cw->BackTrace("$cw: No type defined in format for $item->{name}")
          unless defined $item->{type} ;

        my $sf = $cw -> Frame (relief => 'sunken', bd => 2)
          -> pack(qw/fill x/) ;
        my $varName = defined $item->{var} ? $item->{var} : $item->{name} ;

        my $buttonFrame = $sf ;
        if ($item->{'type'} eq 'text')
          {
            $buttonFrame = $sf -> Frame -> pack(qw/side top/) ;
          }

        my $hstate = defined $item->{help} ? 'normal' : 'disabled' ;
        $buttonFrame -> Button (qw/text help state/, $hstate,
                                command => sub {$cw->showHelp($item->{help}) ;}
                               )-> pack(qw/side right/);

        my $itemLabel = $buttonFrame -> Label ( text => $item->{name}.' :', 
                                       qw/width 20/)
          -> pack(qw/side left/) ;

        if ( $item->{'type'} eq 'enum')
          {
            $cw->BackTrace("$cw: enum $item->{name} has no values in format")
              unless defined $item->{'values'} ;
            
            foreach my $value (@{$item->{'values'}})
              {
                $sf->Radiobutton
                  (
                   text     => $value ,
                   variable => \$cw->{localInfo}{$varName},
                   relief   => 'flat',
                   value    => $value,
                  ) -> pack(-side => 'left', -pady => '2');
              }
          }
        elsif ($item->{type} eq 'array')
          {
            my $entry = $sf->Scrolled
              (qw/Entry -scrollbars s -relief sunken -width 40/,
               textvariable => \$cw->{localInfo}{$varName} ) 
                -> pack(qw/side left fill x/) ;
            $buttonFrame -> Button (text => 'recall' , command =>
                           sub {
                             my $tmp = pop @{$histInfo{$varName}} ;
                             return unless defined $tmp;
                             $cw->{localInfo}{$varName} = $tmp;
                             unshift @{$histInfo{$varName}}, $tmp ; 
                           }
                          ) -> pack(-side => 'right') ;
          }
        elsif ( $item->{type} eq 'text')
          {
            my $w_t = $sf->Scrolled
              (qw/Text -scrollbars oe -relief sunken bd 2 -setgrid true
               -height 10/)-> pack(qw/side bottom/);


            $buttonFrame -> Button 
              (
               text => 'recall' , 
               command =>
               sub 
               {
                 my $tmp = pop @{$histInfo{$varName}} ;
                 $w_t -> delete ('0.0','end');
                 $w_t->insert('0.0',$tmp);
                 unshift @{$histInfo{$varName}}, $tmp ; 
               }
              ) -> pack(-side => 'right') ;

            $cw->{textWidget}{$varName} = $w_t ;
          }
        else
          {
            if (defined $item->{mode} and $item->{mode} eq 'r') 
              {
                $sf -> Label(textvariable => \$cw->{localInfo}{$varName})
                  ->pack(qw/-side left fill x/) ;
              }
            else
              {
                $sf -> Scrolled (qw/Entry -scrollbars s width 40/,
                                 textvariable => \$cw->{localInfo}{$varName}
                                ) -> pack(qw/-side left fill x/) ;
              }

            $buttonFrame -> Button 
              (
               text => 'recall' , command =>
               sub 
               {
                 my $tmp = pop @{$histInfo{$varName}} ;
                 $cw->{localInfo}{$varName} = $tmp ;
                 unshift @{$histInfo{$varName}}, $tmp ; 
               }
              ) -> pack(-side => 'right') ;
          } 
      }

    # get info and put them in data struct refered to by the widgets
    $cw->resetInfo ();

    my $cf = $cw -> Frame -> pack ;
    $cf -> Button (text => 'cancel', command => sub {$cw->destroy ;})
      -> pack (side => 'left' ) ;

    $cf -> Button (text => 'reset', command => sub {$cw->resetInfo();})  
      -> pack (side => 'left' ) ;

    $cf -> Button (text => 'archive', command => 
                   sub {
                     $cw->storeHistInfoFromEdit() ;
                     $cw->destroy ;
                   }) 
      -> pack (side => 'left' ) ;
    
    $cw->ConfigSpecs('DEFAULT' => [$cw]) ;
    $cw->Delegates(DEFAULT => $cw) ;

  }

sub showHelp 
  {
    my $cw = shift ;
    my $help = shift ;

    if (ref($help) eq 'HASH')
      {
        require Tk::Pod ;
        my $podSpec = $help->{class};
        $podSpec .= '/"'.$help->{section}.'"' if defined $help->{section} ;
        my ($pod)  = grep (ref($_) eq 'Tk::Pod',$cw->MainWindow->children) ;
        $pod = $cw->MainWindow->Pod() unless defined $pod ;
        $pod->Subwidget('pod')->Link('reuse',undef, $podSpec)
      }
    else
      {
        $cw ->Dialog('title'=> "$help help", text =>$help) -> Show();
      }
  }

sub resetInfo
  {
    my $cw = shift ;

    # Store informations in localInfo in a format suitable for 
    # the widget
    foreach my $item (@{$cw->{'format'}})
      {
        my $varName = defined $item->{var} ? $item->{var} : $item->{name} ;

        if ($item->{type} eq 'array')
          {
            $cw->{localInfo}{$varName} = defined $cw->{info}{$varName} ?
                  join(' ',@{$cw->{info}{$varName}}) : undef;
          }
        elsif ($item->{type} eq 'text')
          {
            $cw->{textWidget}{$varName} -> delete ('0.0','end');
            $cw->{textWidget}{$varName} -> insert('0.0',$cw->{info}{$varName})
              if defined $cw->{info}{$varName} ;
          }
        else
          {
            $cw->{localInfo}{$varName} = $cw->{info}{$varName};
          }
      }

  }

sub storeHistInfoFromEdit()
  {
    my $cw = shift ;
    my $href ;

    # must store array items and text items
    foreach my $item (@{$cw->{'format'}})
      {
        my $varName = defined $item->{var} ? $item->{var} : $item->{name} ;

        if ($item->{type} eq 'array')
          {
            next unless defined $cw->{localInfo}{$varName} ;
            my @array = split (/[, \t]+/, $cw->{localInfo}{$varName} ) ;
            $href->{$varName} = \@array ;
            push @{$histInfo{$varName}},$cw->{localInfo}{$varName} ; 
          }
        elsif ($item->{type} eq 'text')
          {
            my $str = $cw->{textWidget}{$varName} -> get('0.0','end');
            $href->{$varName} = $str ;
            push @{$histInfo{$varName}},$str ; 
          }
        else
          {
            next unless defined $cw->{localInfo}{$varName} ;
            $href->{$varName} = $cw->{localInfo}{$varName};
          }
      }

    &{$cw->{callback}}($href) ;
}

1;

__END__

=head1 NAME

VcsTools::HistEdit - Tk composite widget to edit a Vcs History

=head1 SYNOPSIS

    $widget->HistoryEditor( name => 'dummy', 
                            revision=> '1.1', 
                            'format' => $logDataFormat,
                            callback => sub{$self->setInfo(@_)}, 
                            'info' => $self->{info} ) ;

No more synopsis given. This widget must be used by VcsTools::Version.

=head1 DESCRIPTION

This composite Tk Widget is used to edit the log information of a Vcs
file. 

The fields of the editor are set according to the 'format' parameter 
passed during the widget creation.

Each field feature a 'recall' button which will recall the last archived
value of the field. You may click several times on the 'recall' button to
get older values.

=head1 Constructor

=head2 HistoryEditor('name'=> '...', ...)

Parameters are :

=over 4

=item *

name: optional name

=item *

revision : revision number of the edited version

=item *

callback: sub to be called when the user clicks the "archive" button. 

The user's routine will get the info hash ref as first parameter.

=item *

info : info hash ref that will be edited (optionnal)

=item *

format : data format array reference.

=back

=cut

#'

=head1 DATA FORMAT

Each element of the array is a hash ref. This hash ref contains :

=over 4

=item * 

name : name of the field as seen by the yser.

=item * 

var : variable name used in internal hash (default = name), and through
the VcsTools objects. 

=item * 

type : is either line, enum or array or text (see below)

=item * 

values : array ref containing the possible values of enum type 
(ignored for other types)

=item * 

mode : specifies if the value can be modified (r|w) (default 'w')

=item * 

help : The help information can either be a string that will be displayed 
with a Tk::Dialog or a pointer to a Pod file that will be displayed with a
Tk::pod window.

In case of pod information, the help hash must be like :
 {
   'class' => 'Your::Class',
   'section' => 'DECRIPTION' # optionnal
 }

=back

=head1 DATA TYPES

=over 4

=item *

line: The editor uses an Entry widget to edit this type.

=item *

enum:  The editor uses a RadioButton widget to edit this type. The possible 
values of the Buttons are set by the 'values' parameter of the data format.

=item *

array: The editor uses an Entry widget to edit this type. Array element will
be separated by a comma or a white space.

=item * 

text: The  editor uses an Text widget to edit this type.

=head1 AUTHOR

Dominique Dumont, Dominique_Dumont@grenoble.hp.com

Copyright (c) 1998 Dominique Dumont. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

perl(1), Tk(3), Puppet::Any(3), VcsTools::DataSpec::HpTnd(3), VcsTools::Version(3)

=cut


