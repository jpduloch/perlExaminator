use v5.28;
use strict;
use diagnostics;

# Build Stopwordlist-array
  my @stopWordList;

  open (my $fh, '<', "stopwords.txt");
  chomp(@stopWordList = <$fh>);
  close $fh;

sub compare_twounevenstrrings{
  my ($originalString, $comparisonString) = @_;

  # Lowercase
  $originalString = lc $originalString;
  $comparisonString = lc $comparisonString;

  # removing any “stop words” from the text
  # Source: https://stackoverflow.com/questions/26820340/perl-remove-stopwords-from-string
  my ($rx) = map qr/(?:$_)/, join "|", map qr/\b\Q$_\E\b/, @stopWordList;

  $originalString =~ s/$rx//g;
  $comparisonString =~ s/$rx//g;

  #removing any sequence of whitespace characters at the start and/or the end of the text
  $originalString =~ s/^\s+|\s+$//g;
  $comparisonString =~ s/^\s+|\s+$//g;

  #replacing any remaining sequence of whitespace characters within the text with a single space character.
  $originalString =~ s/\s+/ /g;
  $comparisonString =~ s/\s+/ /g;

  return (100/length $originalString) * levenshtein($originalString, $comparisonString);

}

use List::Util qw(min);

sub levenshtein {
  # Source: https://en.wikibooks.org/wiki/Algorithm_Implementation/Strings/Levenshtein_distance#Perl
    my ($str1, $str2) = @_;
    my @ar1 = split //, $str1;
    my @ar2 = split //, $str2;

    my @dist;
    $dist[$_][0] = $_ foreach (0 .. @ar1);
    $dist[0][$_] = $_ foreach (0 .. @ar2);

    foreach my $i (1 .. @ar1){
        foreach my $j (1 .. @ar2){
            my $cost = $ar1[$i - 1] eq $ar2[$j - 1] ? 0 : 1;
            $dist[$i][$j] = min(
                        $dist[$i - 1][$j] + 1,
                        $dist[$i][$j - 1] + 1,
                        $dist[$i - 1][$j - 1] + $cost );
        }
    }

    return $dist[@ar1][@ar2];
}

sub create_hashstructure_fromfile {
  # Subroutine reads the questions and answers from a file.
  # Returns header as string and a hash with
  #            {1. question => {uncheckedAnswer => 0, checkedAnswer => 1, ... }
  #            2. question => {...}...
  #            }

  my $datFile = $_[0];
  my %datHash;

  open(my $yourhandle, '<', $datFile) # always use a variable here containing filename
      or die "Unable to open file, $!";
  my $actualquestion;
  my $header;

  while (my $row = <$yourhandle>) {
    chomp($row);

    $row =~ s/^\s+//;

    #saves $header
    if (!defined($actualquestion)) {
      $header .= $row."\n";
    }
    #detect line
    if ($row =~ m/^_[_]+_$/){
         $actualquestion = 0;
    }
    #detect qwestion
    if ($row =~ m/^\d{1,2}\.\s/ && defined($actualquestion)){
      $actualquestion = $row;
    } elsif ($row =~ m/^\[[ ]*\]/ && defined($actualquestion)){
      my @actualkey = split(m/\]\s+/, $row);
      $datHash{$actualquestion}{$actualkey[1]} = 0;
    } elsif ($row =~ m/^\[.+\]/ && defined($actualquestion)){
      my @actualkey = split(m/\]\s+/, $row);
      $datHash{$actualquestion}{$actualkey[1]} = 1;
    }
  }

  return ($header, \%datHash);
}

1;
