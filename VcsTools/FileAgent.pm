package VcsTools::FileAgent ;

use strict;

use vars qw($VERSION);
use AutoLoader qw/AUTOLOAD/ ;

$VERSION = sprintf "%d.%03d", q$Revision: 1.2 $ =~ /(\d+)\.(\d+)/;

# completely asynchronous file interface
sub new
  {
    my $type = shift ;
    my %args = @_ ;
    my $self= {} ;

    # mandatory parameter
    foreach (qw/name workDir/)
      {
        die "No $_ passed to $type $self->{name}\n" unless defined $args{$_};
        $self->{$_} = delete $args{$_} ;
      }

    $self->{processClass} = defined $args{processClass} ? $args{processClass} :
      'VcsTools::Process';

    $self->{workDir} .= '/' unless $self->{workDir} =~ m!/$! ;

    die "directory $self->{workDir} does not exist\n" 
      unless -d $self->{workDir};
    
    my $fullName = "/$self->{workDir}/$self->{name}" ;
    $fullName =~ s!//!/!g ;
    $self->{fullName}=$fullName ;

    bless $self,$type ;
  }


1;

__END__


=head1 NAME

VcsTools::FileAgent - Perl class to handle a file

=head1 SYNOPSIS

 my $agent = "VcsTools::FileAgent" ;

 my $fa = new $agent(name => 'test.txt',
                     workDir => $ENV{'PWD'}.'/'.$dtest);


 $fa->writeFile(content => "dummy content\n", callback => \&got) ;

 $fa->readFile(callback => \&got, name => 'test.txt') ;

 $fa->stat(callback => \&statcb, name => 'test.txt') ;

=head1 DESCRIPTION

This class is used to launch child process pipes. When the process is over,
the callback function is called with the content of the STDOUT of the child
process.

=head1 Constructor

=head2 new (name => a_name, workDir => a_dir, [processClass => 'A class name'])

Will create a FileAgent for file 'a_name' in directory 'a_dir'.

When a sub process is necessary to perform a task (for edit() and merge()),
FileAgent will create a process handler to handle the sub-process.

By default, the process handler class is VcsTools::Process. If you choose to 
provide another class, be sure to have the same API as VcsTools::Process.

=head1 Methods

=head2 edit ('callback' => sub {})

Will run a blocking gnuclient session to edit the file.

=head2 merge ('callback' => sub {}, 'input' => a_string )

Will connect to xemacs (with gnudoit) and will run a blocking ediff 
session. See the ediff documentation.

merge() parameters are :

=over 4

=item *

ancestor: the file name which contains the ancestor of the 2 files to merge

=item *

below:  the file name which contains one of the revision to merge.

=item *

other: the file name which contains the other revision to merge.

=item *

callback: the sub to call back when the merge is over.

=back

=head2 writeFile (content => string | ref_to_string_array, callback => sub_ref)

Will write content (or a  content joined with "\n") into the file.

=head2 readFile ( callback => sub_ref)

Will read the content of the file.

=head2 getRevision ( callback => sub_ref)

Will read the content of the file and extract the revision number..

=head2 stat ( callback => sub_ref)

Will perform a stat (see perlfunc(3)) on the file and pass the stat array to the
callback.

=head2 chmod ( mode => 0xxx, callback => sub_ref)

Will perform a chmod (see perlfunc(3)) on the file.

=head2 remove ( callback => sub_ref)

Will unlink (see perlfunc(3))  the file .


=head1 CALLBACK

Callbacks will get 2 parameters :

=over 4

=item *

A boolean result, 1 in case of success, 0 in case of failure.

=item *

A string or an array ref of all lines retrieved from the STDOUT.

=head1 AUTHOR

Dominique Dumont, Dominique_Dumont@grenoble.hp.com

Copyright (c) 1998 Dominique Dumont. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

perl(1), Tk(3), Puppet::Any(3), VcsTools::DataSpec::HpTnd(3), VcsTools::Version(3)

=cut


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

    return $class->new(workDir => $self->{workDir},%args);
  }

sub edit 
  {
    my $self = shift ;
    my %args = @_ ;

    $args{command} =  "gnuclient $self->{name}";
    $self->createProcess(%args)->pipe(callback => $args{callback}) ;
  }

sub merge
  {
    my $self = shift ;
    my %args = @_ ;

    my @files = ($args{below}, $args{other}, $args{ancestor}) ;
    map($_ = $self->{workDir}.$_,@files);
    my $lisp = '(ediff-merge-files-with-ancestor "'. join('" "',@files) . '")';
    $args{command} = "gnudoit '$lisp'" ;

    $self->createProcess(%args)->pipe(callback => $args{callback}) ;

    # run xemacs `ediff-merge-files-with-ancestor',
    # arguments: (file-A file-B file-ancestor &optional startup-hooks)
  }

sub makeFullName
  {
    my $self = shift ;
    my %args = @_ ;

    my $f ;
    if (defined $args{fullName}) {$f = $args{fullName} ;} 
    elsif (defined $args{name}) {$f = $self->{workDir}.$args{name} ;} 
    else {$f = $self->{fullName}};

    return $f ;
  }

sub writeFile
  {
    my $self = shift ;
    my %args = @_ ;

    my $f = $self->makeFullName(@_);

    unless (defined $args{content} )
      {
        &{$args{callback}}(0,"No content specified to write file $f");
        return ;
      }
          
    unless (open(FOUT,">$f") )
      {
        &{$args{callback}}(0,"open >$f failed:$!");
        return ;
      }

    if (ref($args{content} eq 'ARRAY'))
      {
        print FOUT @{$args{content}} ;
      }
    else
      {
        print FOUT $args{content} ;        
      }

    close(FOUT) ;
    &{$args{callback}}(1) ;
  }

sub readFile
  {
    my $self = shift ;
    my %args = @_ ;

    my $f = $self->makeFullName(@_);

    unless (open(FIN,"$f") )
      {
        &{$args{callback}}(0,"open $f failed:$!");
        return ;
      }

    my @str = <FIN> ;

    close(FIN) ;
    &{$args{callback}}(1,\@str) ;
  }

sub getRevision
  {
    my $self = shift ;
    my %args = @_ ;

    $self-> readFile
      (callback => sub {$self->getRevCb($args{callback}, @_);}) ;
  }

#internal
sub getRevCb
  {
    my $self = shift ;
    my $cb = shift ;
    my $res = shift ;

    if ($res)
      {
        my $ref = shift ;
        my $localRev ;
        foreach  (@$ref)
          {
            last if (($localRev)= /\$Revision: ([\d\.]+)/) ;
          }
        &$cb($res,$localRev);
      }
    else
      {
        &$cb($res,shift) ;
      }
  }
 
sub stat
  {
    my $self = shift ;
    my %args = @_ ;

    my $f = $self->makeFullName(@_);
    my @res = CORE::stat($f) ;
    if (scalar @res)
      {
        &{$args{callback}}(1, \@res) ;
      }
    else
      {
        &{$args{callback}}(0,"$f stat failed: $!") ;
      }
  }

sub chmod
  {
    my $self = shift ;
    my %args = @_ ;

    my $f = $self->makeFullName(@_);

    unless (defined $args{mode} )
      {
        &{$args{callback}}(0,"No mode specified to chmod file $f");
        return ;
      }
          
    my $mode = $args{mode} ;

    my $res = CORE::chmod $mode, $f ;
    if ($res)
      {
        &{$args{callback}}(1) ;
      }
    else
      {
        &{$args{callback}}(0,"$f chmod failed: $!") ;
      }
  }

sub remove
  {
    my $self = shift ;
    my %args = @_ ;

    my $f = $self->makeFullName(@_);

    unless (unlink($f) )
      {
        &{$args{callback}}(0,"remove $f failed:$!");
        return ;
      }

    &{$args{callback}}(1) ;
  }
