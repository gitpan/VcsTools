package VcsTools::DataSpec::HpTnd ;

use strict;

use vars qw($VERSION $logDataFormat) ;
use AutoLoader qw/AUTOLOAD/ ;

$VERSION = sprintf "%d.%03d", q$Revision: 1.1 $ =~ /(\d+)\.(\d+)/;

# $logDataFormat is a array ref which specifies all information that can
# edited or displayed on the history editor.


{
  my $bChangeData = ['none', 'cosmetic', 'minor','major'] ;
  my $changeData = ['none', 'cosmetic', 'major'] ;
  my @state = qw(Dead Exp Team Lab Special Product) ;

  # each entry is a hash made of 
  # - name : name of the field stored in log
  # - var : variable name used in internal hash (default = name), and through
  #         the VcsTools objects
  # - type : is line, enum or array or text
  # - values : possible values of enum type
  # - mode : specifies if the value can be modified (r|w) (default 'w')
  # - pile : define how to pile the data when building a log resume.
  # - help : help string
  
  $logDataFormat = 
    [
     { 
      'name'   => 'state', 
      'type'   => 'enum',  
      'values' => \@state
     },
     { 
      'name' => 'date', 
      'type' => 'line', 
      'mode' => 'r' 
     },
     { 
      'name' => 'merged from', 
      'type' => 'line',
      'var'  => 'mergedFrom' 
     },
     { 
      'name' => 'comes from', 
      'type' => 'line',
      'var'  => 'previous', 
      'help' => 'enter a version if it cannot be figured out by the tool' 
     },
     { 
      'name' => 'writer',
      'type' => 'line', 
      'mode' => 'r' 
     },
     { 
      'name' => 'keywords', 
      'type' => 'array', 
      'pile' => 'push',
      'help' => 
      {
       'class' => 'VcsTools::DataSpec::HpTnd', 
       'section' => 'keywords'
      }
     },
     { 
      'name' => 'fix',
      'type' => 'array',
      'pile' => 'push',
      'help' => 'enter number a la GREhp01243' 
     },
     { 
      'name'   => 'behavior change' , 
      'type'   => 'enum',
      'var'    => 'behaviorChange',
      'values' => $bChangeData ,
      'help' => 
      {
       'class' => 'VcsTools::DataSpec::HpTnd', 
       'section' => 'CHANGE MODEL'
      }
     },
     { 
      'name'   => 'interface change' , 
      'type'   => 'enum',
      'var'    => 'interfaceChange',
      'values' => $changeData ,
      'help' => 
      {
       'class' => 'VcsTools::DataSpec::HpTnd', 
       'section' => 'CHANGE MODEL'
      }

     },
     { 
      'name'   => 'inter-peer change' , 
      'type'   => 'enum',
      'var'    => 'interPeerChange',
      'values' => $changeData ,
      'help' => 
      {
       'class' => 'VcsTools::DataSpec::HpTnd', 
       'section' => 'CHANGE MODEL'
      }
     },
     { 
      'name' => 'misc' , 
      'var'  => 'log', 
      'type' => 'text', 
      'pile' => 'concat',
      'help' => 'Edit all relevant history information. This editor uses most'
      .'emacs key bindings'
     }
    ];
}

# we could add a special field for info like
#bug fixed:

#toto
#titi



# must pass the info data structure when creating it
sub new
  {
    my $type = shift ;

    my $self = {} ;

    bless $self,$type ;
  }

1;

__END__


=head1 NAME

VcsTools::DataSpec::HpTnd - Perl class to translate Hp Tnd HMS log to info hash

=head1 SYNOPSIS

 my $ds = new VcsTools::DataSpec::HpTnd ;

 my @log = <DATA>;
 my $info = $ds->analyseLog(\@log) ;

 my $piledInfo = $ds->pileLog('pile test',
                              [
                               [ '3.10', $info->{'3.10'}],
                               ['3.11', $info->{'3.11'}],
                               ['3.12', $info->{'3.12'}],
                               ['3.13', $info->{'3.13'}],
                              ]
                             ) ;
 print $ds->buildLogString ($piledInfo);

=head1 DESCRIPTION

This class is used to translate the log of an HMS file into 
a hash containing all relevant informations and vice-versa.

The $logDataFormat hash ref also defines the informations that
are contained in the log of each version of the HMS file.

It can also concatenate several logs into one according to the rules defined
in the $logDataFormat hash.

Needless to say this file is tailored for HP Tnd needs and HMS keywords.
Nevertheless, it can be used as a template for other VCS systems and other
needs.

=head1 Contructor

=head2 new()

No parameters.

=head1 Methods

=head2 analyseLog(array_ref)

Analyse the history of a file and returns a hash ref containing all relevant
informations. The keys of the hash are made from the revision numbers found 
in the history log.

Each element of the passed array must contain one chomped line of the history.
 
=head2 getDataFormat()

Return the hash ref defining the data format.

=head2 buildLogString($info_hash_ref)

Returns a log string from the info hash. The log string may be archived as is
in the HMS base.

=head2 pileLog(file_name,  [ [ rev, info_ref], ... ])

Returns an info hash made of all informations about revision passed in the
array ref.

=over 4

=item *

file_name is the name of the concerned Vcs file. This field is necessary to
build a readable cumulated log.

=item *

The second parameter is an array ref made where each element is an array 
ref made of the version number and the info hash ref of this revision.
(See example below)

=back

=head1 DATA FORMAT

See VcsTools::HistEdit(3).

Each data item may also have a 'pile' element which specify how the 
information are cumulated. 

For array data type, it can be 'push'. In this case, the array elements
are pushed, then sorted and redundant infos are discarded.

For text data type, is can be 'concat'. In this case, the text strings are
concatenated together and with each file name and revision number.

=head1 HP TND DATA

=head2 state

 Taken from 'state' HMS field. It can be either Dead Exp Team Lab 
Special or Product according to the level of confidence. 

=head2 date

Date of the archive. Set by HMS. read-only value.

=head2 merged from

Specifies if this version is a merge between the parent revision
and another revision.

=head2 comes from

Explicitely specifies the parent revision. Use this field when
the parent cannot be infered. For instance, when the revision number jump
from 1.19 to 2.1, set the 'comes from' field of the revision '2.1' to '1.19'.

=head2 writer

The original writer of this version. Since HMS changes the author field
whenever you edit the history of a version, this field keeps track of the
guy who actually archived this version.

=head2 keywords

Keyword which refers to the functionnality added in this version.
(could be 'ANSI', 'cosmetic', 'doc_update' ...).

=head2 fix

Official names of the bugs fixed in this version (a la 'GREhp01234').

=head2 misc

Miscellaneous comments about this version.

=head1 CHANGE MODEL

The 3 following keywords try to provide a model for changes introduced with
each revision of a file.

=head2 behavior change

Specify whether this code can smoothly replace the previous revision.
Can be 'none', 'cosmetic', 'minor','major'

Still need a clear definition of what it means.

=head2 interface change 

Specify the amount of change seen from the compiler's point of view. For 
a header file, for instance, 'cosmetic' might mean 're-compilation needed',
'major' might mean 'code change needed in user code'.

Can be 'none', 'cosmetic', 'major'

=head2 inter-peer change

Specify whether this code can inter-work with the previous revision.

Can be 'none', 'cosmetic', 'major'

=head1 EXAMPLE

Here's an example of a cumulated log :

 From pile test v3.12:
   - coupled with tcapIncludes
   - does not compile in ANSI

 From pile test v3.11:
 bugs fixed :

 - GREhp10971   :  TC_P_ABORT address format doesn't respect addr option.



=head1 AUTHOR

Dominique Dumont, Dominique_Dumont@grenoble.hp.com

Copyright (c) 1998 Dominique Dumont. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

perl(1), Tk(3), Tk::Multi::Manager(3), VcsTools::GraphWidget(3)

=cut



# returns a hash ref containing all extracted infos
sub analyseLog
  {
    my $self = shift ;
    my $log = shift ;

    my %info = ();

    my ($revision,$line) ;
    

  MAINLOOP: while()
    {
      $line = shift @$log ;
      last unless defined $line ;

      chomp($line) ;

      if ($line =~ /^revision\s*([\d.]+)$/) 
        {
          $revision = $1 ; 
          next ;
        }

      if (defined $revision)
        {
          # official HMS fields
          if ($line =~ /date:\s*(.*?);\s*author:\s*(\w+);\s*state:\s*(\w+)/) 
            {
              $info{$revision}{date} = $1;
              $info{$revision}{state} = $3;
            }
          elsif ($line =~ /^branches:\s*(.*)$/)
            {
              my @branches = split (/\s*;\s*/,$1) ;
              $info{$revision}{branches} = \@branches ;
            }
          elsif ($line =~ /^Author:\s*(.*)$/)
            {
              $info{$revision}{author} = $1 ;
            }
          # user defined convention
          elsif ($self->scanLogLine(\%info,$revision,$line))
            {
              next ;
            }
#           # STS bugs storage
#           elsif ($line =~ /^bugs fixed :\s*(.*)$/)
#             {
#               my $blankLines = 0 ;
#               my $bugLine ;
#               while ($bugLine = shift @$log)
#                 {
#                   if ($bugLine =~ /^\s*$/)
#                     {
#                       $blankLines++ ;
#                       next MAINLOOP if $blankLines == 2;
#                     }
#                   elsif ($bugLine =~ /^\s+-\s+(GREhp\d+)\s*:\s*(.*)$/)
#                     {
#                       $info{$revision}{stsBugs}{$1} = $2 ;
#                     }
#                   else
#                     {
#                       # none case
#                       next MAINLOOP;
#                     }
#                 } 
#             }

          # try to get something out of it 
          elsif ($line !~ /^[-=]+$/ )
            {
              if ($line =~ /(GREhp\d+)/ and 
                  not defined $info{$revision}{fix})
                {
                  $info{$revision}{guessedFix}{$1} = 1 ;
                }
              if ($line =~ /\b([A-Z\d]{2,})\b/ and 
                  not defined $info{$revision}{keywords})
                {
                  $info{$revision}{guessedKeywords}{$1}= 1 ;
                }
              $info{$revision}{'log'} .= $line."\n";
            }
        }
#       else
#         {
#           if ($line =~ /^rev:/)
#             {
#               my ($rev,$locker) = 
#                 ( $line =~ /rev:\s*(.*?);\s*locked by:\s*(.*?);/);
#               $info{'lock'}{$rev} = $locker ;
#             }
#         }
    }
    
    
    foreach my $rev (keys %info)
      {
        # set writer as author by default of previous version
        if (defined $info{$rev}{author} and not defined $info{$rev}{writer})
          {
            $info{$rev}{writer} = $info{$rev}{author};
          }
        if (defined $info{$rev}{guessedKeywords} and 
            not defined $info{$rev}{keywords})
          {
            $info{$rev}{keywords} = 
              [sort keys %{$info{$rev}{guessedKeywords}}];
          }
        if (defined $info{$rev}{stsBugs} and 
            not defined $info{$rev}{fix})
          {
            $info{$rev}{fix} = [sort keys %{$info{$rev} {stsBugs}}];
          }
        if (defined $info{$rev}{guessedFix} and not defined $info{$rev}{fix})
          {
            $info{$rev}{fix} = [sort keys %{$info{$rev} {guessedFix}}];
          }

        # cleanup (but don't delete stsBugs
        delete $info{$rev} {guessedKeywords};
        delete $info{$rev} {guessedFix};
      }

    $self->{info} = \%info ;
    return \%info ;
  }

sub getDataFormat
  {
    return $logDataFormat ;
  }

sub scanLogLine
  {
    my $self = shift ;
    my $infoRef = shift ;
    my $rev = shift ;
    my $line = shift ;

    foreach my $item (@$logDataFormat)
      {
        next if $item->{name} eq 'state' ;
        my $var = defined $item->{var} ? $item->{var} : $item->{name} ;
        if ($line =~ /^$item->{name}:\s*(.+)$/)
          {
            if ($item->{type} eq 'array')
              {
                my @array = split(/[\s,]+/,$1) ;
                $infoRef->{$rev}{$var} = \@array ;
              }
            else
              {
                $infoRef->{$rev}{$var} = $1
              }
            return 1 ;
          }
      }
    return 0 ;
  }

sub buildLogString
  {
    my $self = shift ;
    my $info = shift ; # hash ref containing all infos (without revision)

    my $logStr ;
    foreach my $item (@$logDataFormat)
      {
        my $varName = defined $item->{var} ? $item->{var} : $item->{name} ;

        # skip special cases handled by hms
        next if ($item->{name} eq 'state' or $item->{name} eq 'date');

        # skip blank entries
        next unless defined $info->{$varName} ;

        if ($item->{type} eq 'array')
          {
            $logStr .= $item->{name}.": ".join(', ',@{$info->{$varName}})."\n";
          }
        elsif ($item->{type} eq 'text' and $varName eq 'log')
          {
            $logStr .= $info->{$varName} ;
          }
        else
          {
            $logStr .= $item->{name}.": ". $info->{$varName}. "\n" ;
          }
      }

    return $logStr ;
  }

sub pileLog
  {
    my $self = shift ;
    my $name = shift ; # file name
    my $infoSet = shift ; # [ [ rev, info_ref], ... ,[ancestor, info_ref] ]

    # pile logs and other infos from bottom to top
    my %result ;

    foreach my $elt (@$infoSet)
      {
        my ($tmpRev,$info) = @$elt ;

        foreach my $item (@$logDataFormat)
          {
            next unless defined $item->{'pile'} ;

            my $varName = defined $item->{var} ? $item->{var} : $item->{name} ;

            next unless defined $info->{$varName} ;

            if ($item->{pile} eq 'push' )
              {
                my @array = defined $result{$varName} ?
                  @{$result{$varName}}:();
                my %hash ;
                map( $hash{$_} = 1, @array, @{$info->{$varName}});
                @{$result{$varName}} = sort keys %hash ;
              } 
            elsif ($item->{pile} eq 'concat')
              {
                next if not defined $info->{$varName} or 
                  $info->{$varName} =~ /^[\s\n]*$/ ;
                my $str = defined $result{$varName} ? $result{$varName} : '' ;
                $result{$varName} = 
                  "From $name v$tmpRev:\n". 
                    $info->{$varName}."\n".
                      $str;
              } 
          }
      }
    
    return \%result ;
  }

