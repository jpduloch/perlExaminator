# start this with: perl .\loaddatshittyfiles.pl AssignmentDataFiles\MasterFiles\FHNW_entrance_exam_master_file_2017.txt AssignmentDataFiles\SampleResponses\*

use v5.28;
use strict;
use diagnostics;
use Data::Dumper qw(Dumper);
use File::Find::Rule;
use POSIX qw(strftime);
use File::Spec;
use List::Util qw(sum);
use Sort::Naturally qw(nsort);

require '.\common_functions.pl';

# Read MasterFiles
  my ($masterfilepath, @responseFilesInput) = @ARGV;
  my ($mastaHeader, $masterExam) = create_hashstructure_fromfile($masterfilepath);

  my @responseFiles;

  for my $responseFileInput (@responseFilesInput){
      my ($volume,$directories,$fileName) =  File::Spec->splitpath($responseFileInput);
      push @responseFiles, File::Find::Rule->file()
                                  ->name("$fileName")
                                  ->in($directories);
  }

# Marking the exams

my %AllExamMarks;

foreach my $studentExamFilePath (@responseFiles){
  my $examFailureMessage = $studentExamFilePath;
  my ($studentHeader, $studentExam) = create_hashstructure_fromfile($studentExamFilePath);
  my @studentExamMarks;

  # Interate through the master file and look for the question in the student's exam file
  foreach my $q (nsort keys %$masterExam){
    my $point = "-";

  	if(exists $studentExam->{$q}){

        # Check if question is answered
        if ((sum values  %{$studentExam->{$q}}) > 0) {

          # Check if checked answer is correct answer
          $point = 1;
    			foreach my $ans (keys %{$masterExam->{$q}}){
            if (exists $studentExam->{$q}{$ans}){
      				if($studentExam->{$q}{$ans} ne $masterExam->{$q}{$ans}){
      					$point = 0;
      				}
            } else {
              $examFailureMessage .= "\n\t" ."Missing Answer: " .$ans ."\t in $q";
            }
    			}
        }

      } else{
        $examFailureMessage .= "\n\t" ."Missing question: ".$q;
      }
      push @studentExamMarks, $point;
  	}

    # Output message only if a question or answer is missing
    if ($examFailureMessage =~ tr/\n//) {
      say $examFailureMessage;
    }

    $AllExamMarks{$studentExamFilePath} = [@studentExamMarks];
  }

  print Dumper \%AllExamMarks;
