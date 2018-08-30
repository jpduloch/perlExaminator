use v5.28;
use strict;
use diagnostics;
use Data::Dumper qw(Dumper);
use List::Util qw(shuffle);


# Sum of points a students gets 
# 1 point per correct answer
my $points = 0;

# Interate through the master file and look for the question in the student's exam file
foreach my $q (keys %$masterExam){
	if(%$studentExam{$q} eq %$masterExam{$q}){
		
		# Variable used to check if question was answered correctly
		my $counter = 0;
		
		# Count the values of student's exam - helps determine if and how answered
		foreach my $ans (keys %{%$studentExam{$q}}){
			$counter += %{%$studentExam{%$q{$ans}}};
		}
		
		# Case that question wasn't answered
		if($counter < 1){
		
			print "Incorrect: Student did not answer question.";
			
		# Case more than one answer ticked
		} elsif($counter > 1){
		
			print "Incorrect: Too many answers.";
			
		} else{
		# Check if checked answer is correct answer
		
			foreach my $ans (keys %{%$masterExam{$q}}){
			
				if(%{%$studentExam{$q{$ans}} ne %{%$masterExam{%$q{$ans}}}){
					$counter = 0;
				}
			}
			
			#Check if result of correction
			if($counter){
				# Add points 
				$points++;
				print "Correct."
				
			}else{
			
				print "Incorrect: Wrong answer."
				
			}
		}
	}
}





