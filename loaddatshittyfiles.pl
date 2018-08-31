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


# Create and print statistics
my @valAnswered;
my @valCorrect;
my ($minAns, $minCor, $maxAns, $maxCor, $sumAns, $sumCor, %freqAns, %freqCor);

foreach my $key (nsort keys %AllExamMarks){
  my $correctAnswers = 0;
  my $answered = 0;

  foreach my $answer (@{%AllExamMarks{$key}}){
    if ($answer eq 1) {
      $correctAnswers++;
      $answered++;
    } elsif ($answer eq 0) {
      $answered++;
    }
  }
  
  # Store values
  push @valAnswered, $answered;
  push @valCorrect, $correctAnswers;
  
  # Is it max or min amount of questions answered?
  $minAns = $answered if !defined $minAns || $answered < $minAns;
  $maxAns = $answered if $answered > $maxAns;
  
  # Is it max or min amount of correct answers?
  $minCor = $correctAnswers if !defined $minCor || $correctAnswers < $minCor;
  $maxCor = $correctAnswers if $correctAnswers > $maxCor;
  
  # Get sum of values to get average later
  $sumAns += $answered;
  $sumCor += $correctAnswers;
  
  # Track frequency of values
  $freqAns{$answered}++;
  $freqCor{$correctAnswers}++;

  say "$key \t $correctAnswers/$answered";
}

# Get Averages
my $avgAns = sprintf("%.2f", $sumAns/@valAnswered);
my $avgCor = sprintf("%.2f", $sumCor/@valCorrect);

# Output Results
say "Average number of questions answered.....  $avgAns";
say "		Minimum:	 	$minAns \t( $freqAns{$minAns} ". ($freqAns{$minAns} == 1 ? "student" : "students"). ")";
say "		Maximum:	 	$maxAns \t( $freqAns{$maxAns} ". ($freqAns{$maxAns} == 1 ? "student" : "students"). ")";

say "Average number of correct answers........  $avgCor";
say "		Minimum:	 	$minCor \t( $freqCor{$minCor} ". ($freqCor{$minCor} == 1 ? "student" : "students"). ")";
say "		Maximum:	 	$maxCor	( $freqCor{$minCor} ". ($freqCor{$minCor} == 1 ? "student" : "students"). ")";

#Below Expectations
say "Results below expectation:	";


