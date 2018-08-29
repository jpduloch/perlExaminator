use v5.28;
use strict;
use diagnostics;

my $masterfilepath = $ARGV[0];

sub create_hashstructure_fromfile{
  my $datMastaFile = $_[0];
  my %datHash;

  $datMastaFile = 'AssignmentDataFiles\MasterFiles\short_exam_master_file.txt';

  open(my $yourhandle, '<', $datMastaFile) # always use a variable here containing filename
      or die "Unable to open file, $!";

  say "createdHash from file $datMastaFile";

  while (<$yourhandle>) { # Read the file line per line (or otherwise, it's configurable).
  my $thisline = $_;
  if ($thisline){
       print "$thisline";
  }

 }

  return %datHash;
}



create_hashstructure_fromfile($masterfilepath);
