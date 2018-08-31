# start this with: perl .\loaddatshittyfiles.pl AssignmentDataFiles\MasterFiles\FHNW_entrance_exam_master_file_2017.txt AssignmentDataFiles\SampleResponses\*

use v5.28;
use strict;
use diagnostics;
use Data::Dumper qw(Dumper);
use File::Find::Rule;
use POSIX qw(strftime);
use File::Spec;
use List::Util qw(sum all any);
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

  # Iterate through the master file and look for the question in the student's exam file
  foreach my $q (nsort keys %$masterExam) {
    my $point = "-";
    my $studentQuestion;

    # identify question in student exams
    if (exists $studentExam->{$q}){
      $studentQuestion = $q;
    } else {
      $examFailureMessage .= "\n\t" ."Missing question: ".$q;
      my $lowestdist = 10;
      foreach my $question(keys %{$studentExam}){
        if (compare_twounevenstrrings($q, $question) < $lowestdist){
          $studentQuestion = $question;
        }
      }
      if (defined($studentQuestion)) {
        $examFailureMessage .= "\n\t" ."using this instead: ".$studentQuestion;
      }
    }

    # identified a question so go thru the answers
    if (defined($studentQuestion)) {
      my @masterSolutions;
      my @studentSolutions;

      foreach my $ans (keys %{$masterExam->{$q}}){
        my $studentAns;
        push @masterSolutions, $masterExam->{$q}{$ans};

        if (exists $studentExam->{$q}{$ans}){
          $studentAns = $ans;
        } else {
          $examFailureMessage .= "\n\t" ."Missing Answer: " .$ans ."\t in $q";

          my $lowestdist = 10;
          foreach my $nearestStudentAns (keys %{$studentExam->{$q}}){
            if (compare_twounevenstrrings($ans, $nearestStudentAns) < $lowestdist){
              $studentAns = $nearestStudentAns;
            }
          }
          if (defined($studentAns)) {
            $examFailureMessage .= "\n\t" ."using this instead: ".$studentAns;
          }
        }

        if (defined($studentAns)) {
          push @studentSolutions, $studentExam->{$studentQuestion}{$studentAns};
        } else{
          push @studentSolutions, "-";
        }
      }

      # Auswerten
      if (all { $_ ne 1 } @studentSolutions) {
        $point = "-";
      } else {
        my @bla;
        foreach my $i (0 .. $#masterSolutions){
          if (($masterSolutions[$i] eq $studentSolutions[$i])
                || ($masterSolutions[$i] eq 0 && $studentSolutions[$i] ne 1)
                || ($masterSolutions[$i] eq 1 && $studentSolutions[$i] eq "-")){
            push @bla, 1;
          } else {
            push @bla, 0;
          }
        }
        $point = (all { $_ eq 1 } @bla) ? 1:0;
      }

    }

    push @studentExamMarks, $point;
  }

  # Output message only if a question or answer is missing
  if ($examFailureMessage =~ tr/\n//) {
    say $examFailureMessage. "\n";
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

  foreach my $answer (@{$AllExamMarks{$key}}){
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


