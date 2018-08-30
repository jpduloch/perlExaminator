# start this with: perl .\randomizeQuestions.pl AssignmentDataFiles\MasterFiles\short_exam_master_file.txt

use v5.28;
use strict;
use diagnostics;
use Data::Dumper qw(Dumper);
use POSIX qw(strftime);
use File::Spec;

require '.\common_functions.pl';

# Read MasterFiles
  my $masterfilepath = $ARGV[0];
#  $masterfilepath = 'AssignmentDataFiles\MasterFiles\short_exam_master_file.txt';
  my ($mastaHeader, $mastaHash) = create_hashstructure_fromfile($masterfilepath);
  my ($volume,$directories,$mastaFileName) =  File::Spec->splitpath( $masterfilepath );

  #print $mastaHeader;
  #print Dumper \%$mastaHash;

# Write new testfile
# 20170904-132602-IntroPerlEntryExam.txt
  my $datestring = strftime "%Y%m%d-%H%M%S-", localtime;
  my $ramdomizedFileName = $datestring.$mastaFileName;

  open(my $randomizedFileHandle, '>>', $ramdomizedFileName) # always use a variable here containing filename
        or die "Unable to open file, $!";

  # write header
  print $randomizedFileHandle $mastaHeader;

  # write QnA
  for my $qwstion (sort keys %$mastaHash){
    print $randomizedFileHandle "\n ".$qwstion."\n\n";

    for my $answer (keys %{%$mastaHash{$qwstion}}){
      print $randomizedFileHandle "  [ ] ".$answer."\n";
    }
    print $randomizedFileHandle "\n________________________________________________________________________________\n";
  }

  # close file and message
  close $randomizedFileHandle;
  say "created file ". $ramdomizedFileName;
