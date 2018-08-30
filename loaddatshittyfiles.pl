# start this with: perl .\loaddatshittyfiles.pl AssignmentDataFiles\MasterFiles\short_exam_master_file.txt AssignmentDataFiles\SampleResponses\*

use v5.28;
use strict;
use diagnostics;
use Data::Dumper qw(Dumper);
use File::Find::Rule;
use POSIX qw(strftime);
use File::Spec;

require '.\common_functions.pl';

# Read MasterFiles
  my ($masterfilepath, @responseFilesInput) = @ARGV;
  $masterfilepath = 'AssignmentDataFiles\MasterFiles\short_exam_master_file.txt';
#  my ($mastaHeader, $mastaHash) = create_hashstructure_fromfile($masterfilepath);

  my @responseFiles;

  for my $responseFileInput (@responseFilesInput){
      my ($volume,$directories,$fileName) =  File::Spec->splitpath($responseFileInput);
      say "$fileName";
      say "$directories";
      push @responseFiles, File::Find::Rule->file()
                                  ->name("$fileName")
                                  ->in($directories);
  }

for my $responseFilePath (@responseFiles){
  my ($studentHeader, $studentHash) = create_hashstructure_fromfile($responseFilePath);

#####COMPARE HERE######



  print Dumper \%$studentHash;
}
