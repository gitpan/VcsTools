use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile
  (
   'NAME'	   => 'VcsTools',
   'VERSION' => '0.01',
   'EXE_FILES' => ['hmsWork'],
   'dist' => {COMPRESS=>'gzip -9f', SUFFIX => 'gz'},
   ($] >= 5.005 ?
    (ABSTRACT   => 'VCS management tools',
     AUTHOR     => 'Dominique Dumont (domi@barrayar.grenoble.hp.com)') : ()),
   'PREREQ_PM' =>
   {
    'Tk' => 0,
    'Tk::Pod' => 0,
    'Tk::Multi::Manager' => '2.001',
    'Tk::Multi::Text' => '2.001',
    'Data::Dumper'=> 0,
    'Puppet::Any' => '0.04',
    'Puppet::Log' => '0.4',
    'Async::Group' => '0.2',
    'Getopt::Long' => 0,
    'MLDBM' => 0,
    'DB_File' =>0,
    'String::ShellQuote' => 0
   }
  );
