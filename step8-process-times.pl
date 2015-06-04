#!/usr/bin/env perl
# EPN, Wed Apr  1 16:07:36 2015
# step8-process-times.pl
# 
# Given >= 1 concatenated outputs from /usr/bin/time
# like this:
#
# 3901.41user 1.89system 1:05:12elapsed 99%CPU (0avgtext+0avgdata 507952maxresident)k
# 2488inputs+328outputs (2major+187242minor)pagefaults 0swaps
#
# Sum up the total time for all the outputs and display it.
# 
use strict;
use warnings;

my $usage = "perl step8-process-time.pl\n\t<concatenated /usr/bin/time output to sum>\n";

my $tot_secs = 0;
while(my $line = <>) { 

  # 3901.41user 1.89system 1:05:12elapsed 99%CPU (0avgtext+0avgdata 507952maxresident)k
  # we'll use the 'elapsed' figure
  chomp $line;
  my $elapsed = $line;
  $elapsed =~ s/^.+system\s+//;
  $elapsed =~ s/elapsed.+$//;
  if($elapsed =~ /(\d+)\:(\d+)\:(\d+\.?\d*)/) { 
    my ($hours, $minutes, $secs) = ($1, $2, $3);
    $secs += 3600. * $hours + 60. * $minutes;
    $tot_secs += $secs;
  }
  elsif($elapsed =~ /(\d+)\:(\d+\.?\d*)/) { 
    my ($minutes, $secs) = ($1, $2);
    $secs += 60. * $minutes;
    $tot_secs += $secs;
  }
  else { 
    die "ERROR unable to parse $line\n";
  }
  # remove unparsed second line, like this: 
  # 2488inputs+328outputs (2major+187242minor)pagefaults 0swaps
  my $trash = <>;
}

printf("%12.4f hours   (total elapsed)\n", $tot_secs / 3600.);
#printf("%12.4f minutes (total elapsed)\n", $tot_secs / 60.);
#printf("%12.4f seconds (total elapsed)\n", $tot_secs);

