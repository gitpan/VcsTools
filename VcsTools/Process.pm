package VcsTools::Process ;

use strict;

use vars qw($VERSION);
use IPC::Open3;

use AutoLoader qw/AUTOLOAD/ ;

$VERSION = sprintf "%d.%03d", q$Revision: 1.1 $ =~ /(\d+)\.(\d+)/;

# completely asynchronous process interface
# could be replaced later by a remote process interface.

sub new
  {
    my $type = shift ;
    my %args = @_ ;
    my $self= {} ;

    # mandatory parameter
    foreach (qw/command/)
      {
        die "No $_ passed to $type\n" unless defined $args{$_};
        $self->{$_} = delete $args{$_} ;
      }

    if (defined $args{workDir})
      {
        $self->{workDir} = $args{workDir} ;
        $self->{workDir} .= '/' unless $self->{workDir} =~ m!/$! ;

        die "directory $self->{workDir} does not exist\n" 
          unless -d $self->{workDir};
      }
 
    $self->{trace} = defined $args{trace} ? $args{trace} : 0 ; 

    $self->{expect}= defined $args{expect}?  $args{expect} : { '0' => 1 };
    
    bless $self,$type ;
  }


1;

__END__

=head1 NAME

VcsTools::Process - Perl class to handle child process (blocking mode)

=head1 SYNOPSIS

 my $p = VcsTools::Process -> new (
                                   command => 'll',
                                   workDir => $ENV{'PWD'}
                                  ) ;

 $p->pipe (callback=> \&treatStdout) ;

 my $s = VcsTools::Process -> new (command => 'bc') ;

 $s->pipeIn (input => "3+4+2\nquit\n", callback=> \&treatStdout)}) ;

=head1 DESCRIPTION

This class is used to launch child process pipes. When the process is over,
the callback function is called with the content of the STDOUT of the child
process.

=head1 Constructor

=head2 new(command => shell_command, [ workDir => a_dir ],[ expect => int ])

Since the pipe and pipeIn function are based on opening a pipe, the 
invoked shell command must use the STDOUT.

Use 'expect' parameter if the shell command does not return '0' on normal 
cases.

You can set a 'trace' parameter to help debugging.

=head1 Methods

=head2 pipe('callback' => sub {})

Will run the command passed to the constructor. 

=head2 pipeIn('callback' => sub {}, 'input' => a_string )

Will run the command passed to the constructor and will feed the 'input'
string to the STDIN of the subprocess.


=head1 CALLBACK

Callbacks will get 2 parameters :

=over 4

=item *

A boolean result, 1 in case of success, 0 in case of failure.

=item *

A array ref of all lines retrieved from the STDOUT.

=head1 AUTHOR

Dominique Dumont, Dominique_Dumont@grenoble.hp.com

Copyright (c) 1998 Dominique Dumont. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

perl(1), Tk(3), Puppet::Any(3), VcsTools::DataSpec::HpTnd(3), VcsTools::Version(3)

=cut


# do not use, as the asynchronous version will need to use fork. In this
# case the parent process will get a SIGCHLD which may trash Tk or perl
sub run 
  {
    my $self = shift ;
    my %args = @_ ;

    my $dir = $ENV{'PWD'} ;
    if (defined $self->{workDir} and not chdir ($self->{workDir}))
      {
        &{$args{callback}}(0,"Can't cd to $self->{workDir}:$!");
        return ;
      } 

    print "running $self->{command}\n" if $self->{trace};

    my $ret = system($self->{command}) ;
    my $res = $self->{expect}{$ret} ;

    if (defined $res and $res)
      {
        chdir ($dir) if defined $self->{workDir} ;
        &{$args{callback}}(1);
      } 
    else
      {
        chdir ($dir) if defined $self->{workDir} ;
        &{$args{callback}}(0,"$args{command} failed:$!");
      } 
  }

sub pipe
  {
    my $self = shift;
    my %args = @_ ;

    my $dir = $ENV{'PWD'} ;

    if (defined $self->{workDir} and not chdir ($self->{workDir}))
      {
        &{$args{callback}}(0,"Can't cd to $self->{workDir}:$!");
        return ;
      } 

    print "running $self->{command} | \n" if $self->{trace};

    open(RDR,$self->{command}.' |') 
      or die "can't open pipe $self->{command}\n";
    my @output = <RDR> ;
    chomp @output ;
    close(RDR) ;

    chdir ($dir)  if defined $self->{workDir};

    my $res = $self->{expect}{$?} ;
    my $result =  (defined $res and $res) ;

    &{$args{callback}}($result, \@output);
  }

sub pipeIn
  {
    my $self = shift;
    my %args = @_ ;

    my $dir = $ENV{'PWD'} ;

    if (defined $self->{workDir} and not chdir ($self->{workDir}))
      {
        &{$args{callback}}(0,"Can't cd to $self->{workDir}:$!");
        return ;
      } 
    
    die "No input for pipeIn\n" unless defined $args{'input'};
    
    print "Pipe in $self->{command} \nInput: \n",$args{'input'} 
    if $self->{trace};

    my $pid = open3(\*WTR,\*RDR,'',"$self->{command}") 
      or die "can't do open3 on $self->{command}\n";
    print WTR $args{input} ;

    my @output = <RDR> ;
    chomp @output ;

    chdir ($dir)  if defined $self->{workDir};

    my $res = $self->{expect}{$?} ;
    my $result =  (defined $res and $res) ;

    &{$args{callback}}($result, \@output);
  }

