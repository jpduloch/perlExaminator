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
#  $masterfilepath = 'AssignmentDataFiles\MasterFiles\FHNW_entrance_exam_master_file_2017.txt';
  my ($mastaHeader, $masterExam) = create_hashstructure_fromfile($masterfilepath);

  my @responseFiles;

  for my $responseFileInput (@responseFilesInput){
      my ($volume,$directories,$fileName) =  File::Spec->splitpath($responseFileInput);
#      say "$fileName";
#      say "$directories";
      push @responseFiles, File::Find::Rule->file()
                                  ->name("$fileName")
                                  ->in($directories);
  }

for my $responseFilePath (@responseFiles){
  my $examFailureMessage = $responseFilePath;
  my ($studentHeader, $studentExam) = create_hashstructure_fromfile($responseFilePath);

  #print Dumper \%$masterExam;
  #print Dumper \%$studentExam;

  # Sum of points a students gets
  # 1 point per correct answer
  my $points = 0;

  # Interate through the master file and look for the question in the student's exam file
  foreach my $q (nsort keys %$masterExam){
#    say "\n\n";
#    say $q;
  	if(exists $studentExam->{$q}){

#      say "master:\n";
#      say for sort(keys %{$masterExam->{$q}});
#      say "student:\n";
#      say for sort(keys %{$studentExam->{$q}});
#say values %{$studentExam->{$q}};
#say values %{$masterExam->{$q}};



      #my $thesum = sum values $studentExam->{$q};
      #say $thesum;
  		# Check if checked answer is correct answer
      my $counter = 1;
  			foreach my $ans (keys %{$masterExam->{$q}}){

          if (exists $studentExam->{$q}{$ans}){
    				if($studentExam->{$q}{$ans} ne $masterExam->{$q}{$ans}){
    					$counter = 0;
    				}
          } else {

            $examFailureMessage .= "\n\t" ."Missing Answer: " .$ans ."\t in $q";
          }
  			}
      $points += $counter;
    } else{
            $examFailureMessage .= "\n\t" ."Missing question: ".$q;
    }
  	}

    if ($examFailureMessage =~ tr/\n//) {
      say $examFailureMessage;
    }


    say $points;
  }
