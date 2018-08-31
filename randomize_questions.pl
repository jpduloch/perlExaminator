use v5.28;
use strict;
use diagnostics;
use POSIX qw(strftime);
use File::Spec;
use Sort::Naturally qw(nsort);

require '.\common_functions.pl';


# Read masterFiles
  my $masterfilepath = $ARGV[0];
  my ($mastaHeader, $mastaHash) = create_hashstructure_fromfile($masterfilepath);
  my ($volume,$directories,$mastaFileName) =  File::Spec->splitpath( $masterfilepath );


# Write new examfile
  my $datestring = strftime "%Y%m%d-%H%M%S-", localtime;
  my $ramdomizedFileName = $datestring.$mastaFileName;

  open(my $randomizedFileHandle, '>>', $ramdomizedFileName) # always use a variable here containing filename
        or die "Unable to open file, $!";

  # write header
  print $randomizedFileHandle $mastaHeader;

  # write QnA
  foreach my $qwstion (nsort keys %$mastaHash){
    print $randomizedFileHandle "\n ".$qwstion."\n\n";

    foreach my $answer (keys %{%$mastaHash{$qwstion}}){
      print $randomizedFileHandle "  [ ] ".$answer."\n";
    }
    print $randomizedFileHandle "\n________________________________________________________________________________\n";
  }

  # close file and message
  close $randomizedFileHandle;
  say "created file ". $ramdomizedFileName;
