package VcsTools::File ;

use strict;
use Async::Group ;
use Puppet::Any ;

use vars qw($VERSION @ISA);

@ISA=qw/Puppet::Any/;

use AutoLoader qw/AUTOLOAD/ ;

$VERSION = sprintf "%d.%03d", q$Revision: 1.1 $ =~ /(\d+)\.(\d+)/;


## Generic part

sub new
  {
    my $type = shift ;
    my %args = @_ ;

    my $self = new Puppet::Any(@_) ;

    # mandatory name
    die "No name passed to VcsTools::File object\n" unless
      defined $self->{name} ;

    # mandatory parameter
    foreach (qw/dataScanner vcsClass workDir processClass/)
      {
        die "No $_ passed to $type::$self->{name}\n" unless 
          defined $args{$_};
        $self->{$_} = delete $args{$_} ;
      }

    
    # optionnal
    foreach (qw/fileAgentClass fileAgent/)
      {
        $self->{$_} = delete $args{$_} ;
      }

    die "No fileAgentClass or fileAgent passed to $self->{name}\n" unless 
          defined $self->{fileAgentClass} or $self->{fileAgent};

    $self->{workDir} .= '/' unless $self->{workDir} =~ m!/$! ;

    $self->{constructorArgs} = \%args ;

    bless $self,$type ;

    # if created the history object should either get the DB hash
    # or reload the log from the manager object
#    unless (defined $self->{myDbHash})
#      {
#        $self->{manager}->getLog('callback' => sub{$self->storeLog(@_);}) ;
#      }

    return $self ;
  }


     
1;

__END__

=head1 NAME

VcsTools::File - Perl class to manage a VCS file.

=head1 SYNOPSIS

 my %dbhash;
 tie %dbhash,  'MLDBM',    $file , O_CREAT|O_RDWR, 0640 or die $! ;

 require VcsTools::DataSpec::HpTnd ;
 my $ds = new VcsTools::DataSpec::HpTnd ;
 my $fileO = new VcsTools::File (dbHash => \%dbhash,
                                 keyRoot => 'root',
                                 vcsClass => 'VcsTools::HmsAgent',
                                 hmsHost => 'hptnofs',
                                 hmsDir =>'adir',
                                 hmsBase => 'abase',
                                 hmsHost => 'hptnofs',
                                 name => 'dummy.txt',
                                 workDir => $ENV{'PWD'},
                                 dataScanner => $ds ,
                                 fileAgentClass => 'VcsTools::FileAgent',
                                 processClass => 'dummyP'
                                );


=head1 DESCRIPTION

This class represents a VCS file. It holds all the 
interfaces to the "real" world and the history object 
(See L<VcsTools::History>)).

History object contains 2 buttons to check and/or modify the some features
of the file (writable or locked)

Furthermore File object adds some bindings and
menu to History's GraphWidget to offer more functionnalities from the GUI.

=cut

#'

=head1 CAVEATS

The file B<must> contain the C<$ Revision $> VCS keyword.

=head1 WIDGET USAGE

The File widget contains a sub-window featuring:

=over 4

=item *

A revision label to indicate the revision of the current file.

=item *

A 'writable' check button, which indicated the status of the file and is able
to change its mode.

=item *

A 'locked'check button, which indicated the lock status of the file and is able
to change its lock.

=back

By default, all these widget are disabled until the user performs a 
File->check through the menu.

The File menu contains several commands :

=over 4

=item *

open history: Will open the history menu.

=item *

check: to get the revision, mode, and lock status of the current file.

=item *

archive: to archive the file (Enabled only if the file is writable).

=item *

edit:  to edit the file (Enabled only if the file is writable).

=back

The File object will add some functionnalities to the History object while
opening it :

=over 4

=item *

A 'merge' global menu: To perform a merge on 2 selected revision.

=item *

A 'show diff' global menu: To show a diff between 2 selected revision.

=item *

Button 2 is bound to arrows to show the diff between the 2 revisions next
to the arrow.

=item *

A 'show diff' command is also added to the arrow popup menu.
=item *

Button 2 is bound to nodes to show the content of this revision.

=back

=head1 Constructor

=head2 new('name'=> '...', ...)

Will create a new File object.

Parameters are those of Puppet::Any(3) plus :

=over 4

=item *

dataScanner : VcsTools::DataSpec::HpTnd (or equivalent) object reference.

=item *

vcsClass : class name of the VCS interface.

=item *

processClass : class name of the VCS interface.

=item *

workDir : Absolute directory where the file is.

=back

One of the following 2 parameters must be passed to the constructor:

=over 4

=item *

fileAgentClass: class name of the file interface.

=item *

fileAgentClass: object reference of the file interface.

=back


=head1 Generic methods

=head2  display()

Will launch a widget for this object.

=head2 createProcess( ... )

Will create a new process interface class. All arguments are forwarded to the
process constructor. This function will also specify a 'workDir' argument
to the constructor.

=head2 check(callback => ...)

check r/w permission,  revision and lock state of the file

The file must contain the $ Revision $ keyword.

=head2 archiveFile(info_hash_ref, [revision])

Will archive the file using the optional info hash ref as a template for
the history editor. By default the revision to archive is a revision 
below the revision of the physical file.

=head1 History handling methods

=head2 createHistory()

Will create a VcsTools::History object for this file.

=head2 openHistory()

Will create a VcsTools::History object for this file and open its display.

=head2 guessNewRev(revision)

Will return a "next" revision number from the input parameter taking into
account all revisions that already exist.

For instance :

=over 4

=item * 

guessNewRev(1.2) returns 1.3 if 1.3 doesn't exist

=item * 

guessNewRev(1.2) returns 1.2.1.1 if 1.3 already exists

=item * 

guessNewRev(1.2) returns 1.2.2.1 if 1.3 and branch 1.2.1 already exist

=back

=cut

#'

=head1 Handling the real file

=head2 createFileAgent()

Create the file Agent class.

=head2 edit()

Will launch a window editor.

=head2 getRevision(callback => sub ... )

Will read the revision of the current file.

Callback will be called with (1, revision) in case of success or
(0, error_string) in case of problems.

=head2 checkWritable(callback => sub ... ) 

Will check whether the file is writable or not.

Callback will be called with (1,1) if the file is writable, (1,0) if the file
is read only and (0, error_string) in case of problems.

=head2 chmodFile([writable => 1|0],callback => sub ... )

Will change  the file mode to writable or not.

Callback will be called with (1) if chmod was done and with 
(0, error_string) in case of problems.

=head2 wrFileRev(name => 'foo', revision => 'x.y' , callback => sub ... )

Write the content of revision x.y into file foo.

Callback will be called with (1) if the file was written and with 
(0, error_string) in case of problems.

=head1 Handling the VCS part

=head2 createVcsAgent()

Create the VCS interface class.

=head2 checkLock(callback => sub ... )

See L<VcsTools::HmsAgent/"Methods">

=head2 changeLock([lock => 1|0], callback => sub ... )

See L<VcsTools::HmsAgent/"Methods">

=head2 checkOut(lock => 1|0, callback => sub ... )

See L<VcsTools::HmsAgent/"Methods">

=head2 getContent(revision => 'x.y', 'callback' => sub_ref)

See L<VcsTools::HmsAgent/"Methods">

head2 archiveHistory(...)

See L<VcsTools::HmsAgent/"Methods">

=head2 getLog(callback => sub ref)

See L<VcsTools::HmsAgent/"Methods">

=head2 showDiff('rev1' => 'x.y', [rev2 => 'y.z'], callback => sub ref)

See L<VcsTools::HmsAgent/"Methods">

=head2 checkIn(...)

See L<VcsTools::HmsAgent/"Methods">

=head2 merge(revision1, revision2)

Will open a GUI to merge the 2 revisions. Will use xemacs ediff merge 
to perform the actual merge.


=head1 AUTHOR

Dominique Dumont, Dominique_Dumont@grenoble.hp.com

Copyright (c) 1998 Dominique Dumont. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

perl(1), Tk(3), Puppet::Any(3), VcsTools::DataSpec::HpTnd(3), 
VcsTools::Version(3), VcsTools::File(3)

=cut


sub display
  {
    my $self = shift ;
    return unless $self->SUPER::display();

    # must add a open history command
    
    # must add menu button related to the graph funcionnality
    # i.e draw, merge, show diff
    # these function will ask for currently selected nodes
    $self->{tk}{menu}{'File'}->command(-label => 'check', 
                                       command => sub {$self->check ;}) ;

    $self->{tk}{menu}{'File'}->command(-label => 'open history', 
                                       command => sub {$self->openHistory;}) ;

    $self->{tk}{archiveButton} = 
      $self->{tk}{menu}{'File'}->command
        (
         -label => 'archive',
         -state => 'disabled',
         command => sub {$self->archiveFile;}
        ) ;

    $self->{tk}{editButton} = 
      $self->{tk}{menu}{'File'}->command
        (
         -label => 'edit',
         -state => 'disabled',
         command => sub {$self->edit;}
        ) ;

    my $f = $self->{tk}{toplevel} -> Frame -> 
      pack(qw/fill x before/, $self->{tk}{multiMgr} ) ;

    require Tk::Checkbutton;
    $f -> Label (text => 'revision: ') ->  pack(qw/side left/) ;   
    $f -> Label (textvariable => \$self->{'revision'}) 
      ->  pack(qw/side left/) ;   
    

    $self->{tk}{writeButton} = 
      $f -> Checkbutton(text => 'writable', variable => \$self->{writable},
                        state => 'disabled',
                        command => sub{$self->chmodFile();})
        -> pack(qw/side left/) ;      

    $self->{tk}{lockButton} = 
      $f -> Checkbutton(text => 'locked', variable => \$self->{locked},
                        state => 'disabled',
                        command => sub{$self->changeLock();})
        -> pack(qw/side left/) ;      

    $self->{textObj} =
      $self->{tk}{multiMgr}->newSlave
        (
         'type' => 'MultiText', 
         'title' => 'informations',
         'hidden' => 0 
        );

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

    $self->printEvent("Creating $class\n");
    return $class->new(workDir => $self->{workDir},%args);
  }

# check permission of file and its revision and lock state
sub check
  {
    my $self = shift ;
    my %args = @_ ;

    $self->createFileAgent unless defined $self->{fileAgent} ;

    my $callMgr = Async::Group->new(name => 'File check');
    
    # get file stats
    my @array = 
      (
       sub {$self->checkWritable(callback => sub{$callMgr->callDone(@_)});},
       sub {$self->getRevision(callback => sub{$callMgr->callDone(@_)});},
       sub {$self->checkLock    (callback => sub{$callMgr->callDone(@_)});}
       );

    my $cb = sub {$self->genericCb($args{callback},@_);} ;
    $callMgr->run(set => \@array, callback => $cb );
  }

#internal
sub genericCb
  {
    my $self=shift ;
    my $cb = shift ;
    my $res = shift ;
    
    die shift unless $res ;

    #$self->printEvent(shift) unless ($res) ;
    &$cb($res) if defined $cb ;
  }

#internal
sub lockIs
  {
    my $self = shift ;
    my $rev = shift ;
    my $locker = shift ;

    $self->{tk}{lockButton}->configure(state => 'normal') 
      if defined $self->{tk};

    $self->printEvent ("Revision $rev is locked by $locker\n") if defined $rev;

    if (defined $rev and defined $self->{revision} 
        and $self->{revision} eq $rev)
      {
        #$self->{locked} = $locker ;
        $self->{locked} = 1;
      }
    else
      {
        #$self->{locked} = 'no';
        $self->{locked} = 0 ;
      }
  }
  
# open correct window
sub archiveFile 
  {
    my $self = shift ;
    my $infoRef = shift ;
    my $version = shift || $self->{revision} ;

    die "No version passed to archive of $self->{name}\n"
      unless defined $version ;

    $self->printEvent("Archiving history for revision $version\n");

    die "File $self->{name}: Can't archive non writable file\n" unless
      $self->{writable} ;

    $self->createHistory() unless defined $self->{history} ;

    $self->display ;

    my $f = $self->{tk}{toplevel} -> 
      Frame (relief => 'sunken', 'borderwidth' => 2 ) 
        ->pack(qw/fill x/);

    $f -> Label (text => "Archiving $self->{name} from version $version") 
      -> pack;

    my $bf = $f -> Frame -> pack(qw/fill x/) ;

    my $newRev = $self->guessNewRev($self->{revision}) ;

    $bf -> Entry (textvariable => \$newRev, width=> 6) 
      -> pack (qw/side right fill x expand 1/) ;

    $bf -> Label (text => "in version: ") -> pack (side => 'right');
    
    $bf -> Button 
      (
       'text' => 'do archive',
       'command' => sub 
       {
         $self->{history}->archive
           (
            revision=> $newRev, 
            'info' => $infoRef 
           ) ;
       }
      ) -> pack (side => 'left' ) ;

    $bf -> Button 
      (
       'text' => 'show diff',
       'command' => 
       sub { $self-> showDiff( rev1 => $version,
                             callback => sub {$self->showResult(@_)}) ;}
      ) -> pack (side => 'left' ) ;

    $bf -> Button 
      (
       'text' => 'done',
       'command' => sub { $f-> destroy ; }
      ) -> pack (side => 'right' ) ;

  }

# internal
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

# end Generic part

## Handling the history part

sub createHistory 
  {
    my $self = shift ;
    
    require VcsTools::History ;

    $self->{history}= new VcsTools::History 
      (
       dbHash => $self->{dbHash},
       keyRoot => $self->{myDbKey},
       'topTk' => $self->{topTk},
       name => 'history',
       dataScanner => $self->{dataScanner} ,
       manager => $self 
      );
  }

sub openHistory
  {
    my $self = shift ;

    $self->createHistory() unless defined $self->{history} ;
    $self->{history}->display ;

    
    my $gmgr = $self->{history}->getGraphMgr ;

    $gmgr -> command
      (
       -label => 'merge', 
       command => sub 
       {
         my @revs = $gmgr->getSelectedNodes();
         if (defined @revs and scalar(@revs) == 2) {$self->merge (@revs);}
         else {print scalar(@revs)," nodes selected\n";}
       }
      );

    $gmgr -> command
      (
       -label => 'show diff', 
       command => sub 
       {
         my @revs = $gmgr->getSelectedNodes();
         if (defined @revs and scalar(@revs) == 2)
           {
             $self->showDiff
               ( 
                rev1 => $revs[0],
                rev2 => $revs[1],
                callback => sub {$self->{history}->showResult(@_) ;}
               );
           }
         else
           {
             print scalar(@revs)," nodes selected\n";
           }
       }
      );


    my $showDiff = sub 
      {
        $self->showDiff
          ( 
           rev1 => shift ,
           rev2 => shift ,
           callback => sub {$self->{history}->showResult(@_) ;}
          );
      } ;

    $gmgr->arrowBind('<2>','yellow',$showDiff);
    $gmgr->arrowCommand('show diff',$showDiff) ;


    # bind button <2> on nodes to show content
    $gmgr->nodeCommand
      (
       'show content',
       sub 
       {
         my $rev = shift ;
         $self->getContent(revision => $rev,
                           callback => sub{$self->{history}->showResult(@_);})
       }
      ) ;

  }

sub guessNewRev
  {
    my $self = shift ;
    my $rev = shift ;

    $self->createHistory() unless defined $self->{history} ;

    my $newRev = $rev ;
    $newRev =~ s/(\d+)$/$1+1/e ;
    
    if ($self->{history}->hasVersion($rev))
      {
        # simple increment does not work, must branch
        $newRev = $rev . '.1.1' ;
        while ($self->{history}->hasVersion($newRev))
          {
            $newRev =~ s/(\d)+(\.\d+)$/($1+1).$2/e ;
          }
      }
    return $newRev ;
  }

# end history part

## Handling the real file part

sub createFileAgent
  {
    my $self = shift ;
    my $class = $self->{fileAgentClass};

    my $file = $class ;
    $file .= '.pm' if $file =~ s!::!/!g ;

    require $file ;

    $self->printEvent("Creating $class\n");
    $self->{fileAgent} = $class-> new ( name => $self->{name},
                                        processClass => $self->{processClass},
                                        workDir => $self->{workDir});
  }

sub edit
  {
    my $self = shift ;
    $self->createFileAgent unless defined $self->{fileAgent} ;
    
    $self->{fileAgent}->edit(callback => sub{$self->genericCb(@_)});
  }

sub getRevision
  {
    my $self = shift ;
    my %args = @_ ;

    $self->printDebug("Reading file\n");
    $self->{fileAgent}->
      getRevision(callback => sub {$self->getRevCb($args{callback}, @_);}) ;
  }

sub getRevCb
  {
    my $self = shift ;
    my $cb = shift ;
    my $res = shift ;
    my $param = shift ;

    if ($res)
      {
        $self->printEvent("Found revision $param\n");
        $self->{revision} = $param ;
      }
    else
      {
        $self->printEvent($param) ;
      }
    &$cb($res,$param)  if defined $cb;
  }

sub checkWritable
  {
    my $self = shift ;
    my %args = @_ ;

    $self->printDebug("Calling stat\n");
    $self->{fileAgent}->
      stat(callback => 
           sub {$self->ckWritableCb($args{callback}, @_);}) ;
  }

#internal
sub ckWritableCb
  {
    my $self = shift ;
    my $cb = shift ;
    my $res = shift ;
    my $p = shift ;

    if ($res)
      {
        $self->{tk}{writeButton}->configure(state => 'normal')
          if defined $self->{tk};

        $self->printDebug("Stat result is ".join(' ',@$p)."\n");
        
        $self->{mode} = $p->[2] ;
        $self->{writable} = $p->[2] & 0200 ? 1 : 0; # octal ;
        $self->printDebug("File writable: $self->{mode}, $self->{writable}\n");
        
        foreach (qw/archiveButton editButton/)
          {
            my $state = $self->{writable} ? 'normal' : 'disabled' ;
            $self->{tk}{$_}->configure(state =>$state ) 
              if defined $self->{tk} ;
          }
        &$cb($res,$self->{writable}) if defined $cb ;
      }
    else
      {
        $self->printEvent($p) ;
        &$cb($res,$p) if defined $cb ;
      }
  }

sub chmodFile
  {
    my $self = shift ;
    my %args = @_ ;

    unless (defined $self->{mode})
      {
        # perform a check and re-call myself
        $self->check(
                     callback => sub 
                     {
                       $self->chmodFile(%args) if shift ;
                     }
                    );
      }

    my $writable = $args{writable} || $self->{writable} ;

    die "Undefined writable mode when calling chmod on $self->{name}\n"
      unless defined $writable ;

    my $str = $writable ? '' : 'not ';
    $self->printEvent("chmoding $self->{name} to ".$str."writable\n");
    
    $self->{mode} = $writable ? $self->{mode} | 0200 : $self->{mode} & 07577 ;

    $self->createFileAgent unless defined $self->{fileAgent} ;
    
    # get file stats
    $self->{fileAgent}->
      chmod(mode => $self->{mode},
            callback => sub {$self->chmFileCb($args{callback},@_);} ) ;
  }

#internal
sub chmFileCb
  {
    my $self=shift ;
    my $cb = shift ;
    my $res = shift ;

    unless ($res)
      {
        $self->printEvent(shift) ;
        return ;
      }
    
    $self->printDebug("Chmod OK\n");

    foreach (qw/archiveButton editButton/)
      {
        my $state = $self->{writable} ? 'normal' : 'disabled' ;
        $self->{tk}{$_}->configure(state =>$state ) 
          if defined $self->{tk} ;
      }

     &$cb($res) if defined $cb ;
  }

#internal
sub writeFile
  {
    my $self = shift ;
    my %args = @_ ;

    foreach (qw/name callback content/)
      {
        die "No $_ passed to $self->{name}::writeFile\n" unless 
          defined $args{$_};
      }

    $self->printEvent("writing content of $self->{name} to file $args{name}\n");
    
    $self->createFileAgent() unless defined $self->{fileAgent};

    $self->{fileAgent}->writeFile(%args) ;
  }

sub wrFileRev
  {
    my $self=shift ;
    my %args = @_ ;
    
    foreach (qw/name callback revision/)
      {
        die "No $_ passed to $self->{name}::writeFile\n" unless 
          defined $args{$_};
      }
    
    my $cb = $args{callback} ;
    
    $self->getContent
      (
       revision => $args{revision} ,
       callback => sub
       {
         my $result = shift ;
         if ($result)
           {
             $self->writeFile
               (
                name => $args{name},
                content => shift,
                callback => sub 
                {
                  $self->printEvent("write file failed:".shift()."\n") 
                    unless $_[0] ;
                  &$cb(@_);
                }
               ) ;
           }
         else
           {
             $self->printEvent("get Content failed:".shift()."\n");
           }
       }
      )
    }

# end real file part

## Handling the archive (VCS) part

sub createVcsAgent
  {
    my $self = shift ;
    my $class = $self->{vcsClass};

    my $file = $class ;
    $file .= '.pm' if $file =~ s!::!/!g ;

    require $file ;

    $self->printEvent("Creating $class\n");
    $self->{vcsAgent} = $class-> new ( name => $self->{name},
                                       processClass => $self->{processClass},
                                       mgr => $self,
                                       %{$self->{constructorArgs}});
  }

sub checkLock
  {
    my $self = shift ;
    my %args = @_ ;

    my $cb = delete $args{callback} ;
    $self->createVcsAgent() unless defined $self->{vcsAgent} ;
    $self->{vcsAgent}->
      checkLock(callback => sub {$self->ckLockCb($cb,@_);}, %args) ;
  }

#internal
sub ckLockCb
  {
    my $self = shift ;
    my $cb = shift ;
    my $result = shift ;
    my $rev =shift;
    my $locker = shift ;
    
    $self->lockIs($rev,$locker) if $result;

    &$cb($result,$rev,$locker)  if defined $cb;
  }

sub changeLock
  {
    my $self = shift ;
    my %args = @_ ;

    if (defined $args{lock}) { $self->{locked} = $args{lock} ;}
    else {$args{lock} = $self->{locked} ;}

    $args{revision} = $self->{revision} unless defined $args{revision};

    my $cb = delete $args{callback} ;

    die "Undefined locked mode when calling changeLock on $self->{name}\n"
      unless defined $self->{locked} ;

    $self->createVcsAgent() unless defined $self->{vcsAgent} ;
    $self->{vcsAgent}->changeLock
      (callback => sub {$self->chgLockCb($cb, $args{lock}, @_);} ,%args) ;
  }

# internal
sub chgLockCb
  {
    my $self = shift ;
    my $cb = shift ;
    my $lock = shift ; # lock value used when calling futil
    my $result = shift ;
    my $str = shift ;

    if ($result)
      {
        $self->printDebug("lock set to $lock OK\n");
      }
    else
      {
        $self->printEvent("changeLock failed :\n$str\n");
        # revert lock status
        $self->{mgr}->lockIs(1 - $lock, undef) ;
      }

    &$cb($result) if defined $cb;
  }

sub checkOut
  {
    my $self = shift ;
    my %args = @_ ;

    if ($args{lock} and $self->{writable})
      {
        die "Can't check out an already writable version\n";
      }

    my $cb = delete $args{callback} ;

    $self->printEvent("Checking out $self->{name}, revision $args{revision}\n");
    $self->createVcsAgent() unless defined $self->{vcsAgent} ;
    $self->{vcsAgent} -> checkOut
      (callback => sub {$self->ckOutCb($cb,$args{lock},%args);}, %args) ;
  }

# internal
sub ckOutCb
  {
    my $self = shift ;
    my $cb = shift ;
    my $lock = shift ;
    my $result = shift ;
    my $str = shift ;

    if ($result)
      {
        $self->printDebug("checkOut OK\n");
        $self->lockIs($self->{revision},'yourself') if $lock ;
      }
    else
      {
        $self->printEvent("Check Out failed : $str\n");
      }

    &$cb($result) if defined $cb;
  }

sub getContent
  {
    my $self = shift ;
    $self->createVcsAgent() unless defined $self->{vcsAgent} ;
    $self->{vcsAgent} -> getContent(@_);
  }

sub archiveHistory
  {
    my $self = shift ;
    my $rev = shift ;
    my $str = shift ;
    my $state = shift ;

    $self->createVcsAgent() unless defined $self->{vcsAgent} ;
    $self->{vcsAgent} -> archiveHistory
      ( 
       callback => sub{$self->genericCb(undef, @_)} ,
       'log' => $str,
       state => $state,
       revision => $rev
      );
  }
    
sub getLog
  {
    my $self = shift ;
    $self->createVcsAgent() unless defined $self->{vcsAgent} ;
    $self->{vcsAgent} -> getLog(@_);
  }
    
sub showDiff
  {
    my $self = shift ;
    $self->createVcsAgent() unless defined $self->{vcsAgent} ;
    $self->{vcsAgent} -> showDiff(@_);
  }
    
sub checkIn
  {
    my $self = shift ;
    $self->createVcsAgent() unless defined $self->{vcsAgent} ;
    $self->{vcsAgent} -> checkIn(@_);
  }
    
# end VCS part


# should be asynchronous ...
sub merge
  {
    my $self = shift ;
    my $rev1 = shift ;
    my $rev2 = shift ;

    die "$self->{name}::merge rev1 or rev2 are not defined\n" unless 
      defined $rev1 and defined $rev2 ;

    $self->display() ;
    $self->createHistory() unless defined $self->{history} ;

    # get rev1 object
    my $obj1 = $self->{history}->getVersionObj($rev1) ;
    my $ancestor = $obj1->findAncestor($rev2);

    my $f = $self->{tk}{toplevel} ->
      Frame(relief => 'sunken', 'borderwidth' => 2 ) ->pack(fill => 'x') ;

    my $lf = $f -> Frame -> pack ;
    $lf -> Label
      (text => "Merging file $self->{name} $rev1 with $rev2 from $ancestor")
      -> pack (side => 'left') ;

    my ($below, $newRev, $other);
    my ($archiveB, $ediffB, $checkOutB,@belowWidgets)   ;

    my $belowf = $f -> Frame -> pack(fill => 'x') ;
    $belowf ->Label (text => "merge below :") -> pack (side => 'left');

    my $buttonf = $f -> Frame -> pack ;

    $archiveB = $buttonf -> Button
      (
       text => 'archive merge' ,
       state => 'disabled',
       command =>
       sub
       {
         $self->createHistory() unless defined $self->{history} ;
         my $info = $self->{history}->buildCumulatedInfo($other,$ancestor);
         $info->{mergedFrom} = $other ;
         $self->{history}->archive
           (
            revision => $newRev,
            info => $info,
            callback => sub
            {
              $f->destroy ;
              $self->mergeCleanup() ;
            }
           ) ;
       }
      )
      -> pack (side => 'right');

    $ediffB = $buttonf -> Button
      (
       text => 'ediff' ,
       state => 'disabled',
       command => sub 
       { 
         $self->createFileAgent unless defined $self->{fileAgent} ;
         $self->{fileAgent}->merge
           (
            %{$self->{mergeFiles}},
            callback => sub 
            {
              my $res = shift ;
              if ($res) {$archiveB->configure(state => 'normal') ;}
              else {die "Ediff failed : ",shift(),"\n";}
            }
           ) ;
       }
      ) -> pack (side => 'right');

    $checkOutB = $buttonf -> Button 
      (
       text => 'check-out' ,
       state => 'disabled',
       command => sub 
       { 
         # must get 1 or 3 files and lock the current file
         my $cb = sub 
           {
             if (shift)
               {
                 if ($rev2 eq $ancestor or $rev1 eq $ancestor)
                   {$archiveB -> configure(state => 'normal') ;}
                 else 
                   {$ediffB -> configure(state => 'normal') ;}
                 $checkOutB -> configure(state => 'disabled') ;
                 map($_->configure(state => 'disabled'),@belowWidgets);
               }
             else
               {
                 die "Couldn't get files for merge ",shift,"\n";
               }
           };

         $other = $rev1 eq $below ? $rev2 : $rev1 
           unless $rev2 eq $ancestor or $rev1 eq $ancestor  ;

         $self->setUpMerge(callback =>$cb,
                           below => $below,
                           ancestor => $ancestor,
                           other => $other);
       }
      ) -> pack (side => 'right');

    
    if ($rev2 ne $ancestor and $rev1 ne $ancestor)
      {
        foreach ($rev1,$rev2)
          {
            # skip stupid choices
            next if ( ($_ eq $rev1 and $rev2 eq $ancestor) or
                      ($_ eq $rev2 and $rev1 eq $ancestor) ) ;

            push @belowWidgets, $belowf -> Radiobutton
              (
               text => $_, 
               value => $_, 
               variable => \$below,
               command => sub 
               {
                 $newRev = $self->guessNewRev($below); 
                 $checkOutB -> configure(state => 'normal');
               }
              ) -> pack (side => 'left');
          }
      }
    else
      {
        $below = $rev1 eq $ancestor ? $rev2 : $rev1 ;
        $newRev = $self->guessNewRev($below); 
        $checkOutB -> configure(state => 'normal');
      }

    $belowf ->Label (text => "in revision : ") -> pack (side => 'left');
    my $e = $belowf -> Entry 
      (
       textvariable => \$newRev,
      ) -> pack (qw/side left expand 1 fill x/ ) ;
    push @belowWidgets, $e ;

    $e->bind('<Return>' => sub{$checkOutB -> configure(state => 'normal');});
  }

# internal
sub setUpMerge
  {
    my $self = shift ;
    my %args = @_ ;

    # must check it out
    $self->checkOut
      (
       lock => 1, 
       revision => delete $args{below},
       callback => sub 
       {
         if (shift)
           {
             $self->{mergeFiles}{below} = $self->{name} ;
             $self->getFilesToMerge(%args);
           }
         else
           {
             die "Lock file failed ",shift,"\n";
           }
       }
      ) ;
  }

# internal
sub mergeCleanup
  {
    my $self = shift ;

    require Async::Group ;
    my $a = Async::Group->new(name => 'remove merge files') ;
    my @subs ;
    
    $self->createFileAgent unless defined $self->{fileAgent} ;

    foreach my $what (@{$self->{mergeFiles}}{'ancestor','other'})
      {
        push @subs, sub 
          {
            $self->{fileAgent}->remove
                (name => $what,
                 callback => sub {$a->callDone(@_) ;}) ;
          }
      }
    $a -> run( set => \@subs, callback => sub{$self->genericCb(undef,@_)}) ;
  }
          
# internal
sub getFilesToMerge
  {
    my $self = shift ;
    my %args = @_ ;
    my $cb = delete $args{callback} ;

    require Async::Group ;
    my $a = Async::Group->new(name => 'write rev files') ;
    my @subs ;
    
    foreach my $what (keys %args)
      {
        my $file = $self->{name} ;
        my $k = $what ;
        my $rev = $args{$k};
        $file =~ s/\./_$rev./;

        push @subs, sub 
          {
            my $key = $k ; # closure don't work well with nested subs ????
            $self->wrFileRev
              (
               callback => sub 
               { 
                 $self->{mergeFiles}{$key} = $file if $_[0] ;
                 $a->callDone(@_) ;
               },
               revision => $rev , 
               name => $file);
          };
      }
    
    $a -> run( set => \@subs, callback => $cb) ;
  }
