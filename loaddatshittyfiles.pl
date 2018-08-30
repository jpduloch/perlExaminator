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
  $masterfilepath = 'AssignmentDataFiles\MasterFiles\FHNW_entrance_exam_master_file_2017.txt';
  my ($mastaHeader, $masterExam) = create_hashstructure_fromfile($masterfilepath);

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
  say $responseFilePath;
  my ($studentHeader, $studentExam) = create_hashstructure_fromfile($responseFilePath);

  # Sum of points a students gets
  # 1 point per correct answer
  my $points = 0;

  # Interate through the master file and look for the question in the student's exam file
  foreach my $q (keys %$masterExam){
  	if(exists $studentExam->{$q}){
  		# Check if checked answer is correct answer
      my $counter = 1;
  			foreach my $ans (keys %{$masterExam->{$q}}){
  				if($studentExam->{$q}{$ans} ne $masterExam->{$q}{$ans}){
  					$counter = 0;
  				}
  			}
      $points += $counter;
  		}
  	}
    say $points;
  }
