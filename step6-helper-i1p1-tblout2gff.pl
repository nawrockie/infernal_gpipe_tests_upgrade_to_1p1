#!/usr/bin/env perl
# EPN, Thu Mar 19 13:57:43 2015
# step6-helper-i1p1-tblout2gff.pl: 
# 
# Convert Infernal 1.1* cmsearch --tblout output to gff format.
use strict;
use warnings;

while(my $line = <>) { 
  if($line !~ m/^\#/) { 
    #gi|661674870|gb|JOAO01000073.1| -         RNaseP_bact_a        RF00010    cm        1      367     1451     1853      +    no    1 0.70  37.6  293.0   1.2e-94 !   Streptomyces flaveus strain NRRL ISP-5371 contig56.1, whole genome shotgun sequence
    my @elA = split(/\s+/, $line);
    my ($tname, $qname, $qaccn, $tstart, $tend, $strand, $score, $evalue) = ($elA[0], $elA[2], $elA[3], $elA[7], $elA[8], $elA[9], $elA[14], $elA[15]);
    if($strand eq "-") {  # negative strand so swap tstart and tend
      my $tmp = $tstart; 
      $tstart = $tend; 
      $tend = $tmp;
    }
    printf("%s\t%s\t%s\t%d\t%d\t%s\t%s\t.\t%s\n", 
           $tname, 
           "cmsearch-1.1.1", 
           "rna",
           $tstart,
           $tend,
           $score,
           $strand,
           "gb_key=$qname;rfam_acc=$qaccn;evalue=$evalue");
  }
}
