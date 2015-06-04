#!/usr/bin/env perl
# EPN, Thu Mar 19 14:11:19 2015
# step5-helper-i1p0-tabfile2gff.pl: 
# 
# Convert Infernal 1.0* cmsearch --tabfile output to gff format.
# 
# Takes two command line arguments:
# <name to accn file> <cmsearch v1.0 tabfile>
# 
# <name to accn file> should contain multiple lines of the format
# Rfam-name Rfam-accn
#
# <name to accn file> is necessary because Infernal 1.0 does not 
# include the accession in the output, and Rfam family names can
# change (one of the GPIPE Rfam families QUAD RF00113 changed it's
# name to SIB_RNA in Rfam 12.0, so to compare it we need to use
# the accession).
use strict;
use warnings;

my $usage = "perl step5-helper-i1p0-tabfile2gff.pl <name to accn file> <cmsearch v1.0 tabfile>";
if(scalar(@ARGV) != 2) { die $usage; }

my ($name2accn_file, $tabfile) = (@ARGV);

my $qname;
my $qaccn;

open(N2A, $name2accn_file) || die "ERROR unable to open $name2accn_file";
my %name2accnH = (); # key: Rfam family name; value: corresponding Rfam accession
while(my $line = <N2A>) { 
  chomp $line;
# example line
# 5S_rRNA	RF00001
  ($qname, $qaccn) = split(/\s/, $line);
  $name2accnH{$qname} = $qaccn;
}
close(N2A);

open(IN, $tabfile) || die "ERROR unable to open $tabfile";
while(my $line = <IN>) { 
  if($line =~ s/^\# CM\:\s+//) { 
## CM: 5S_rRNA
    chomp $line;
    $qname = $line; 
    if(! exists $name2accnH{$qname}) { die "ERROR no entry in $name2accn_file for CM named $qname"; }
    $qaccn = $name2accnH{$qname};
  }
  elsif($line !~ m/^\#/) { 
#      gi|757437468|gb|CP010525.1|      904301      904416      1    119     98.06  1.49e-21   63
    $line =~ s/^\s+//; # remove leading whitespace
    my @elA = split(/\s+/, $line);
    my ($tname, $tstart, $tend, $score, $evalue) = ($elA[0], $elA[1], $elA[2], $elA[5], $elA[6]);
    my $strand = "+"; # we change this below if nec
    if($tend < $tstart) { # negative strand so swap tstart and tend
      my $tmp = $tstart; 
      $tstart = $tend; 
      $tend   = $tmp;
      $strand = "-";
    }
    printf("%s\t%s\t%s\t%d\t%d\t%s\t%s\t.\t%s\n", 
           $tname, 
           "cmsearch-1.0", 
           "rna",
           $tstart,
           $tend,
           $score,
           $strand,
           "gb_key=$qname;rfam_acc=$qaccn;evalue=$evalue");
  }
}
