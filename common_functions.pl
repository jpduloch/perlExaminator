use v5.28;
use strict;
use diagnostics;


sub create_hashstructure_fromfile {
  # Subroutine reads the questions and answers from a file.
  # Returns header as string and a hash with
  #            {1. question => {uncheckedAnswer => 0, checkedAnswer => 1, ... }
  #            2. question => {...}...
  #            }

  my $datFile = $_[0];
  my %datHash;

  open(my $yourhandle, '<', $datFile) # always use a variable here containing filename
      or die "Unable to open file, $!";
  my $actualquestion;
  my $header;

  while (my $row = <$yourhandle>) {
    chomp($row);
    #saves $header
    if (!defined($actualquestion)) {
      $header .= $row."\n";
    }
    #detect line
    if ($row =~ m/^_[_]+_$/){
         $actualquestion = 0;
    }
    #detect qwestion
    if ($row =~ m/\s*\d./ && defined($actualquestion)){
      $actualquestion = $row;
    }
    #detect false answer
    if ($row =~ m/\[[\s]\]/ && defined($actualquestion)){
      my @actualkey = split(m/\[[\s+]\]\s+/, $row);
      $datHash{$actualquestion}{$actualkey[1]} = 0;
    }
    #detect right answer
    if ($row =~ m/\[[\S]\]/ && defined($actualquestion)){
      my @actualkey = split(m/\[[\S+]\]\s+/, $row);
      $datHash{$actualquestion}{$actualkey[1]} = 1;
    }
  }

  return ($header, \%datHash);
}

1;
