use v5.28;
use strict;
use diagnostics;
use Data::Dumper qw(Dumper);
use List::Util qw(shuffle);

my %answermaster = (
	"Introduction to Perl for Programmers" => 1,
	"Introduction to Perl for Programmers and Other Crazy People" => 0,
	"Introduction to Programming for Pearlers" => 0,
	"Introduction to Aussies for Europeans" => 0,
	"Introduction to Python for Slytherins" => 0,
);

my %answerstudent = (
	"Introduction to Perl for Programmers" => 0,
	"Introduction to Perl for Programmers and Other Crazy People" => 0,
	"Introduction to Programming for Pearlers" => 1,
	"Introduction to Aussies for Europeans" => 0,
	"Introduction to Python for Slytherins" => 0,

);

my $counter = 0;

foreach my $ans (keys %answerstudent){
	$counter += $answerstudent{$ans};
}

if($counter < 1){
	print "Incorrect: Student did not answer question.";
} elsif($counter > 1){
	print "Incorrect: Too many answers.";
} else{
	foreach my $ans (keys %answerstudent){
		if($answerstudent{$ans} ne $answermaster{$ans}){
			$counter = 0;
		}
	}
	if($counter){
		print "Correct."
	}else{
		print "Incorrect: Wrong answer."
	}
}


#print Dumper \%questions;

