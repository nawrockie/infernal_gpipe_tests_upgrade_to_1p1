#!/usr/bin/env perl
# EPN, Thu Apr  2 08:33:13 2015
# step9-compare-timings.pl
# 
# Compare Rfam11 timings for Infernal 1.0 versus Infernal 1.1.
# and compare Rfam12 timings for Infernal 1.0 versus Infernal 1.1.

use strict;
use warnings;

my $usage = "perl step9-compare-timings.pl";
   $usage .= "\n\t<Rfam11 Infernal 1.0 time>";
   $usage .= "\n\t<Rfam11 Infernal 1.1 time>";
   $usage .= "\n\t<Rfam12 Infernal 1.0 time>";
   $usage .= "\n\t<Rfam12 Infernal 1.1 time>";
   $usage .= "\n\n*** All input files should have been output from step8-process-times.pl";

if(scalar(@ARGV) != 4) { die $usage; }
my @file_A = (@ARGV);
my @hours_A  = ();
my $n = 4;

# parse all 4 files
for(my $i = 0; $i < $n; $i++){ 
  my $file = $file_A[$i];
  open(IN, $file) || die "ERROR unable to open $file";
  my $hours = <IN>;
  chomp $hours;
  if($hours !~ /^\s*\d+\.\d+\shours\s+/) { die "ERROR unable to parse $hours from file $file"; }
  $hours =~ s/^\s+//; # remove leading whitespace
  $hours =~ s/\s+hours.+//; 
  push(@hours_A, $hours);
}

# make the table:
printf("#%6s  %9s  %9s  %9s\n", "rfam", "Inf-1.0", "Inf-1.1.1", "1.0/1.1.1");
printf("#%6s  %9s  %9s  %9s\n", "------", "---------", "---------", "---------"); 
printf(" %6s  %8.4fh  %8.4fh  %9.1f\n", "rfam11", $hours_A[0], $hours_A[1], $hours_A[0]/$hours_A[1]);
printf(" %6s  %8.4fh  %8.4fh  %9.1f\n", "rfam12", $hours_A[2], $hours_A[3], $hours_A[2]/$hours_A[3]);

exit 0;
