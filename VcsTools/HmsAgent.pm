package VcsTools::HmsAgent ;

use strict;
use vars qw($VERSION);
use String::ShellQuote ;
use AutoLoader qw/AUTOLOAD/ ;

$VERSION = sprintf "%d.%03d", q$Revision: 1.1 $ =~ /(\d+)\.(\d+)/;

# must pass the info data structure when creating it
# 1 instance per file object.
sub new
  {
    my $type = shift ;
    my %args = @_ ;

    my $self = {};

    # mandatory parameter
    foreach (qw/name/)
      {
        die "No $_ passed to $type\n" unless defined $args{$_};
        $self->{$_} = delete $args{$_} ;
      }

    #optionnal, we may rely on the .fmrc
    foreach (qw/hmsHost hmsBase hmsDir trace/)
      {
        $self->{$_} = delete $args{$_} ;
      }

    # optionnal
    $self->{processClass} = defined $args{processClass} ? $args{processClass} :
      'VcsTools::Process';

    $self->{hostOption} = defined $self->{hmsHost} ? 
      '-h'.$self->{hmsHost} :'';

    die "Must define both or none hmsBase hmsDir parameter for ",
    "$type $self->{name}\n" 
      if defined  $self->{hmsBase} xor defined $self->{hmsDir} ;

    $self->{fullName} = $self->{name} ;

    if (defined $self->{hmsBase})
      {
         $self->{fullName} = "/$self->{hmsBase}/$self->{hmsDir}/".
           $self->{fullName};
         $self->{fullName}  =~ s!//!/!g ;
      }

    bless $self,$type ;
  }


1;

__END__

=head1 NAME

VcsTools::HmsAgent - Perl class to manage HMS serve.

=head1 SYNOPSIS

 my $h = new VcsTools::HmsAgent (
                                processClass => 'dummyP',
                                hmsHost => 'hptnofs',
                                hmsDir =>'adir',
                                hmsBase => 'abase',
                                hmsHost => 'hptnofs',
                                name => 'dummy.txt',
                                trace => $trace,
                                workDir => $ENV{'PWD'}
                               );

 $h -> getLog(callback => \&cb) ;

 $h -> checkOut(callback => \&cb, revision => '1.51.1.1', lock => 1) ;

 $h -> getContent(callback => \&cb, revision => '1.52') ;

 $h -> checkLock(callback => \&lockCb) ;

 $h -> changeLock(callback => \&cb, lock => 1,revision => '1.51.1.1' ) ;

 $h -> archiveHistory(callback => \&cb, str => "new dummy\nhistory\n",
                     state => 'Dummy', revision => '1.52') ;

 $h -> showDiff(callback => \&cb, rev1 => '1.41') ;

 $h -> showDiff(callback => \&cb, rev1 => '1.41', rev2 => '1.43') ;

 $h -> checkIn(callback => \&cb, revision => '1.52', 
              'log' => "dummy log\Nof a file\n") ;


=head1 DESCRIPTION

This class is used to manage a HMS file. All functions are written in
asynchronous mode. So if the process handler is able to handle processes in
an asynchronous way, this class will be able to perform HMS operation in
non-blocking mode.

If you want to use other VCS system than HMS, you should copy or inherit this
file to implement your own new class.

=cut

#'

=head1 Contructor

=head2 new('name'=> '...', [hmsHost => '...'], [trace => 1|0], ...)

Creates a new HMS agent class. Note that one HmsAgent must be created for 
each HMS file.

Optional parameters are :

=over 4

=item hmsHost

Specify the HMS server name.

=item hmsBase

Specify the HMS base name.

=item hmsDir

Specify the directory relative to the HMS base where the file is archived.

=item trace

If set to 1, debug information are printed.

=item processClass

Specifies the class name used to handle the sub-processes. Defaults to 
VcsTools::Process(3).

=back

=head1 Methods

=head2 checkOut(revision => 'x.y', lock => 1|0, 'callback' => sub_ref)

Checks out revision x.y and eventually lock it.

Callback will be called with (1,$array_ref) 
if the check out was done and with 
(0, error_string) in case of problems. The passed array will contain the
STDOUT of the check out command

=head2 getContent(revision => 'x.y', 'callback' => sub_ref)

Get the content of revision x.y and pass it to the callback function.

Callback will be called with (1,$array_ref) 
if the check out was done and with 
(0, error_string) in case of problems. The passed array will contain the
content of the file.

=head2 checkLock('callback' => sub_ref)

Check if the file is locked and pass the result to callback.

Callback is called with ($result,$rev,$locker) or with 
(0, error_string) in case of problems.

=head2 changeLock(revision => 'x.y', lock => 1|0,'callback' => sub_ref)

Change the lock of the file.

Callback will be called with (1,$array_ref) 
if the lock was changed was done and with 
(0, error_string) in case of problems. The passed array will contain the
STDOUT of the command..

=head2 archiveHistory(...)

Will modify the log (not the file) of a specified revision of the file. 

Parameters are :

=over 4

=item revision

=item log

log to store in the history of revision

=item state

state to store

=item callback

Callback will be called with (1,$array_ref) 
if the history log was changed was done and with 
(0, error_string) in case of problems. The passed array will contain the
STDOUT of the command..

=back

=head2 getLog(callback => sub ref)

Gets the complete history of file.

Callback will be called with (1,$array_ref) 
if the log was extracted from the HMS base and with 
(0, error_string) in case of problems. The passed array will contain the
full history log of the file.

=head2 showDiff('rev1' => 'x.y', [rev2 => 'y.z'], callback => sub ref)

Gets the diff bewteen current file and revision rev1 or between rev1 and
rev2 if rev2 is specified.

Callback will be called with (1,$array_ref) 
if the diff was done and with 
(0, error_string) in case of problems. The passed array will contain the
diff command output.

=head2 checkIn(...)

Archive (check in) the current file. Parameters are :

=over 4

=item revision

=item log

log to store in the history of revision

=item callback

Callback will be called with (1,$array_ref) 
if the check in was done and with 
(0, error_string) in case of problems. The passed array will contain the
STDOUT of the fci command..

=back


=head1 AUTHOR

Dominique Dumont, Dominique_Dumont@grenoble.hp.com

Copyright (c) 1998 Dominique Dumont. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

perl(1), Async::Group(3), VcsTools::Process(3)

=cut



sub printDebug
  {
    my $self=shift ;
    
    print shift if $self->{trace} ;
  }

sub checkOut
  {
    my $self = shift ;
    my %args = @_ ;

    foreach (qw/revision lock/)
      {
        die "No $_ passed to $self->{name}::checkOut\n" unless 
          defined $args{$_};
      }

    my $opt = $args{lock} ? '-l' : '-u' ;
    my $run = "fco $opt  $self->{hostOption} -r$args{revision} ".
      $self->{fullName} ;

    # and then create a process (createProcess method)
    $self->createProcess(command => $run)
      -> pipe (callback => $args{callback} );
  }


sub getContent
  {
    my $self = shift ;
    my %args = @_ ;

    foreach (qw/revision callback/)
      {
        die "No $_ passed to $self->{name}::getContent\n" unless 
          defined $args{$_};
      }

    $self->printDebug("reading content of $self->{name} rev $args{revision}\n");
    
    my $run = "fco -p -r$args{revision}  $self->{hostOption} ".
      $self->{fullName} ;

    # and then create a process (createProcess method)
    $self->createProcess(name => "read v$args{revision}", 
                                command => $run)
      -> pipe (callback => $args{callback} ) ;
  }

sub checkLock
  {
    my $self = shift ;
    my %args = @_ ;

    $self->printDebug("checking lock of $self->{name}\n");
    
    foreach (qw/callback/)
      {
        die "No $_ passed to $self->{name}::getContent\n" unless 
          defined $args{$_};
      }

    my $cb = delete $args{callback} ;
    my $run = "fll  $self->{hostOption} ". $self->{fullName} ;

    # and then create a process (createProcess method)
    $self->createProcess(name => 'checkLock', command => $run)
      -> pipe (callback => sub {$self->chLockCb($cb,@_);} ) ;
  }

#internal
sub chLockCb
  {
    my $self = shift ;
    my $cb = shift ;
    my $result = shift ;
    my $ref = shift;

    my $rev ;
    my $locker ;

    if ($result)
      {
        my $line = shift @$ref ;
        ($locker)= ($line =~ /(\w+\@\w+)/) ;
        ($rev) = ($line =~ /\[([\d.]+)\]/) ;
      }
    else
      {
        $self->printDebug("checkLock failed :\n".join("\n",@$ref)."\n");
      }

    &$cb($result,$rev,$locker)  if defined $cb;
  }


sub changeLock
  {
    my $self = shift ;
    my %args = @_ ;

    foreach (qw/lock revision/)
      {
        die "No $_ passed to $self->{name}::changeLock\n" unless 
          defined $args{$_};
      }

    my $str = $args{lock} ? '' : 'not ';
    $self->printDebug("changing $self->{name} to ".$str."locked\n");
    
    my $opt = $args{lock} ? '-l' : '-u' ;
    my $run = "futil $opt  $self->{hostOption} -r$args{revision} ".
      $self->{fullName} ;

    # and then create a process (createProcess method)
    $self->createProcess(command => $run)
      -> pipe (callback => $args{callback});
  }

sub archiveHistory
  {
    my $self = shift ;
    my %args = @_ ;

    require Async::Group ;

    foreach (qw/revision log state callback/)
      {
        die "No $_ passed to $self->{name}::archiveHistory\n" unless 
          defined $args{$_};
      }

    $self->printDebug("Archiving history for revision $args{revision}:\n".
                    "state: $args{state}\n$args{'log'}\n");
    
    my $a = Async::Group->new(name => 'archiveHistory', 
                              test => $self->{trace}) ;

    my $run = "futil  $self->{hostOption} ".
      "-s$args{state}:$args{revision} $self->{fullName} 2>&1 " ;

    my $sub1 = sub
      {
        $self->createProcess(command => $run)
          -> pipe('callback' => sub{$a->callDone(@_)}) ;
      };
    
    my $run2 = "futil  $self->{hostOption} -m$args{revision}:" .
      shell_quote($args{'log'}) . " $self->{fullName} 2>&1 " ;

    my $sub2 = sub
      {
        $self->createProcess(command => $run2)
          -> pipe('callback' => sub{$a->callDone(@_)}) ;
      } ;

    $a->run(set => [ $sub1, $sub2 ],
            callback => $args{callback}
           ) ;
 
  }

sub getLog
  {
    my $self = shift ;
    my %args = @_;

    my $cmd =  "fhist  $self->{hostOption} $self->{fullName} 2>&1 ";

    $self->createProcess(command => $cmd)
      -> pipe(callback => $args{callback});
  }

sub showDiff
  {
    my $self = shift ;
    my %args = @_ ;

    foreach (qw/rev1 callback/)
      {
        die "No $_ passed to $self->{name}::archiveHistory\n" unless 
          defined $args{$_};
      }

    my $rev2 = $args{rev2} ; # may not be defined if diff with local file

    my $str = defined $rev2 ? $rev2 : 'local file' ;
    $self->printDebug("Diff for $args{rev1} and $str\n");

    my $revStr = "-r$args{rev1} " ;
    $revStr .= "-r$args{rev2} " if defined $args{rev2} ;

    my $cmd = "fdiff  $self->{hostOption} $revStr $self->{fullName} 2>&1 " ;

    $self->createProcess(command => $cmd, expect => {0 => 1, 256 => 1})
      -> pipe(callback => $args{callback});
  }


sub checkIn
  {
    my $self = shift ;
    my %args = @_ ;

    my $rev = $args{revision};

    foreach (qw/log revision callback/)
      {
        die "No $_ passed to $self->{name}::archiveHistory\n" unless 
          defined $args{$_};
      }

    $self->printDebug("Checking in $self->{name} revision $rev\n");
    $args{'log'} .= "\n.\n"; # to end the input ...

    my $run = "fci  $self->{hostOption} -u -r$rev $self->{fullName}" ;

    $self->createProcess(command => $run) 
      -> pipeIn (input => $args{'log'}, 
                 callback => $args{callback});
  }


sub createProcess
  {
    my $self = shift ;
    my %args = @_ ;
    my $class = $self->{processClass};

    unless ($class eq 'dummyP') # dummyP is for test case
      {
        my $file = $class ;
        $file .= '.pm' if $file =~ s!::!/!g ;
        require $file ;
      }

    $self->printDebug("Creating $class\n");
    return $class->new(workDir => $self->{workDir},
                       trace => $self->{trace},
                       %args);
  }
