use v5.28;
use strict;
use diagnostics;

require '.\common_functions.pl';

use Data::Dumper qw(Dumper);


my $masterfilepath = $ARGV[0];
$masterfilepath = 'AssignmentDataFiles\MasterFiles\short_exam_master_file.txt';
my ($mastaHeader, $mastaHash) = create_hashstructure_fromfile($masterfilepath);

print $mastaHeader;
print Dumper \%$mastaHash;
