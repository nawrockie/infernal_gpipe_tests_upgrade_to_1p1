#!/usr/bin/env perl
# EPN, Fri Mar 20 12:21:38 2015
# step7-compare-gff-i1p0-i1p1.pl
# 
# Compare two gff files. Create 4 output files:
# 1. <key>.id:     identical hits found by same model in both GFF files, same coordinates and strand
# 2. <key>.ol:     overlapping hits found by same model in both GFF files, same strand
# 3. <key>.unq1p0: hits found in gff file 1, for which no hit by same model in file 2 overlaps 
# 4. <key>.unq1p1: hits found in gff file 2, for which no hit by same model, in file 1 overlaps
#
# Note that the naming of 3 and 4 assumes we are comparing Infernal 1.0 and 1.1,
# the original purpose of this script, but should be changed if that changes.
# 
# Also, this script assumes that the 9th token is in the following format:
# gb_key=<Rfam-name>;rfam_acc=<Rfam-accn>;evalue=<evalue>. 'Model' above refers
# to the same Rfam accession <Rfam-accn>.
# 
use strict;
use warnings;

my $usage = "perl step7-compare-gff-i1p0-i1p1.pl\n\t<gff file 1 (from Infernal 1.0)>\n\t<gff file 2 (from Infernal 1.1)>\n\t<key for naming output files>\n";
if(scalar(@ARGV) != 3) { die $usage; }
my ($gff1p0, $gff1p1, $key) = (@ARGV);

if(! -e $gff1p0) { die "ERROR no file $gff1p0 exists"; }
if(! -e $gff1p1) { die "ERROR no file $gff1p1 exists"; }

my %hits1p0_HHA = (); # hash of hashes of arrays for gff file 1, first key: "Rfam-accession:Rfam-name", second key: target sequence name, value: array of "<start>.<end>.<strand>.<score>.<evalue>"
my %hits1p1_HHA = (); # hash of hashes of arrays for gff file 2, first key: "Rfam-accession:Rfam-name", second key: target sequence name, value: array of "<start>.<end>.<strand>.<score>.<evalue>"
my %nhits1p0_H = (); # value: string: "Rfam-accession:Rfam-name", value: total number of Inf 1.0 hits for this Rfam family
my %nhits1p1_H = (); # value: string: "Rfam-accession:Rfam-name", value: total number of Inf 1.1 hits for this Rfam family

parse_gff($gff1p0, \%nhits1p0_H, \%hits1p0_HHA);
parse_gff($gff1p1, \%nhits1p1_H, \%hits1p1_HHA);

printf("# Key: $key\n");
printf("# Infernal 1.0   GFF file: $gff1p0\n");
printf("# Infernal 1.1.1 GFF file: $gff1p1\n");
printf("#\n");

# open output file handles and print column headers
my ($id_FH, $ol_FH, $unq1p0_FH, $unq1p1_FH);
my $id_file     = $key . ".id";
my $ol_file     = $key . ".ol";
my $unq1p0_file = $key . ".unq1p0";
my $unq1p1_file = $key . ".unq1p1";
open($id_FH,     ">" . $id_file)     || die "ERROR unable to open $id_file for writing"; 
open($ol_FH,     ">" . $ol_file)     || die "ERROR unable to open $ol_file for writing"; 
open($unq1p0_FH, ">" . $unq1p0_file) || die "ERROR unable to open $unq1p0_file for writing"; 
open($unq1p1_FH, ">" . $unq1p1_file) || die "ERROR unable to open $unq1p1_file for writing"; 

print $id_FH     ("# Key: $key\n");
print $ol_FH     ("# Key: $key\n");
print $unq1p0_FH ("# Key: $key\n");
print $unq1p1_FH ("# Key: $key\n");

print $id_FH     ("# GFF file 1 (infernal 1.0): $gff1p0\n");
print $ol_FH     ("# GFF file 1 (infernal 1.0): $gff1p0\n");
print $unq1p0_FH ("# GFF file 1 (infernal 1.0): $gff1p0\n");
print $unq1p1_FH ("# GFF file 1 (infernal 1.0): $gff1p0\n");

print $id_FH     ("# GFF file 2 (infernal 1.1): $gff1p1\n");
print $ol_FH     ("# GFF file 2 (infernal 1.1): $gff1p1\n");
print $unq1p0_FH ("# GFF file 2 (infernal 1.1): $gff1p1\n");
print $unq1p1_FH ("# GFF file 2 (infernal 1.1): $gff1p1\n");

print $id_FH     ("# Hits found by both Infernal 1.0 and Infernal 1.1 with identical coordinates and strand\n");
print $ol_FH     ("# Hits found by both Infernal 1.0 and Infernal 1.1 that are on same strand and overlap but which are not identical coordinates\n");
print $unq1p0_FH ("# Hits found by Infernal 1.0 for which Infernal 1.1 finds zero overlapping hits on the same strand\n");
print $unq1p1_FH ("# Hits found by Infernal 1.1 for which Infernal 1.0 finds zero overlapping hits on the same strand\n");

my $header_line = sprintf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
                          "#Rfam-accession:name", "sequence-name", "number-nt-overlap", 
                          "1p0-start", "1p0-end", "1p0-strand", "1p0-score", "1p0-evalue", 
                          "1p1-start", "1p1-end", "1p1-strand", "1p1-score", "1p1-evalue");
print $id_FH $header_line;
print $ol_FH $header_line;

printf $unq1p0_FH ("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
                   "#Rfam-accession:name", "sequence-name", "number-nt-overlap", 
                   "1p0-start", "1p0-end", "1p0-strand", "1p0-score", "1p0-evalue");
                   
printf $unq1p1_FH ("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
                   "#Rfam-accession:name", "sequence-name", "number-nt-overlap", 
                   "1p1-start", "1p1-end", "1p1-strand", "1p1-score", "1p1-evalue");
                   
# Do the comparison and create the output.
# We do this with a subroutine which we call twice, one with gff1p0 hits first and gff1p1
# hits second, and once again with them switched. The subroutine will do:
# For each hit in first set of hits:
#     Compare with all hits in second set of hits.
# 
# In the first call, all identical, overlapping and 1p0-unique hits will be output.
# In the second call, only the 1p1-unique hits will be output, because we don't
# want to double-output the identical and overlapping hits.
#
# In the case of multiple overlaps (1 hit in gff1p0 is overlapped by >1 hit in gff1p1)
# we count this as 1 overlap, and output information on the 'best overlap', the longest
# overlapping region, to the overlap file $key.ol.
# 
my %nid_H      = (); # value: string: "Rfam-accession:Rfam-name", value: number of identical hits for this Rfam family
my %nol_H      = (); # value: string: "Rfam-accession:Rfam-name", value: number of overlapping hits for this Rfam family
my %nunq1p0_H  = (); # value: string: "Rfam-accession:Rfam-name", value: number of Inf 1.0 hits that 0 Inf 1.1 hits overlap for this family
my %nunq1p1_H  = (); # value: string: "Rfam-accession:Rfam-name", value: number of Inf 1.1 hits that 0 Inf 1.0 hits overlap for this family

do_and_print_comparisons(\%hits1p0_HHA, \%hits1p1_HHA, 
                         \%nid_H, \%nol_H, \%nunq1p0_H,
                         $id_FH, $ol_FH, $unq1p0_FH);
do_and_print_comparisons(\%hits1p1_HHA, \%hits1p0_HHA,
                         undef, undef, \%nunq1p1_H,
                         undef,  undef,  $unq1p1_FH); 

#my ($nid, $nol, $nunq1p0)   = do_and_print_comparisons(\%hits1p0_HHA, \%hits1p1_HHA, 
#                                                       $id_FH, $ol_FH, $unq1p0_FH); 
#my (undef, undef, $nunq1p1) = do_and_print_comparisons(\%hits1p1_HHA, \%hits1p0_HHA,
#                                                       undef,  undef,  $unq1p1_FH); 
# two undefs in second call are so we don't print identical hits and overlapping hits again,
# we already did that in the first call to print_comparisons

close($id_FH);
close($ol_FH);
close($unq1p0_FH);
close($unq1p1_FH);

# output tabular summary of comparison
# first get a list of all $accn_name:
my %accn_name_H = ();
foreach my $accn_name (keys %hits1p0_HHA) { if(! exists $accn_name_H{$accn_name}) { $accn_name_H{$accn_name} = 1; } }
foreach my $accn_name (keys %hits1p1_HHA) { if(! exists $accn_name_H{$accn_name}) { $accn_name_H{$accn_name} = 1; } }
my @sorted_accn_name_A = sort keys %accn_name_H;

my $tot_nhits1p0;
my $tot_nhits1p1;
my $tot_nid;
my $tot_nol;
my $tot_nunq1p0;
my $tot_nunq1p1;
printf("#%-24s  %12s  %12s  %12s  %12s  %12s  %12s\n", 
       "Rfam-accession:name",
       "Inf1p0-#hits",
       "Inf1p1-#hits",
       "#identical",
       "#overlap",
       "I1p0-#unique",
       "I1p1-#unique");
printf("#%24s  %12s  %12s  %12s  %12s  %12s  %12s\n", 
       "------------------------",
       "------------",
       "------------",
       "------------",
       "------------",
       "------------",
       "------------");

foreach my $accn_name (@sorted_accn_name_A) { 
  my $nhits1p0  = (exists ($nhits1p0_H{$accn_name}) ? $nhits1p0_H{$accn_name} : 0);
  my $nhits1p1  = (exists ($nhits1p1_H{$accn_name}) ? $nhits1p1_H{$accn_name} : 0);
  my $nid       = (exists ($nid_H{$accn_name})      ? $nid_H{$accn_name}      : 0);
  my $nol       = (exists ($nol_H{$accn_name})      ? $nol_H{$accn_name}      : 0);
  my $nunq1p0   = (exists ($nunq1p0_H{$accn_name})  ? $nunq1p0_H{$accn_name}  : 0);
  my $nunq1p1   = (exists ($nunq1p1_H{$accn_name})  ? $nunq1p1_H{$accn_name}  : 0);
  printf("%-25s  %12d  %12d  %12d  %12d  %12d  %12d\n", $accn_name, $nhits1p0, $nhits1p1, $nid, $nol, $nunq1p0, $nunq1p1);
  $tot_nhits1p0  += $nhits1p0;
  $tot_nhits1p1  += $nhits1p1;
  $tot_nid     += $nid;
  $tot_nol     += $nol;
  $tot_nunq1p0 += $nunq1p0;
  $tot_nunq1p1 += $nunq1p1;
}
printf("#%24s  %12s  %12s  %12s  %12s  %12s  %12s\n", 
       "------------------------",
       "------------",
       "------------",
       "------------",
       "------------",
       "------------",
       "------------");
printf("%-25s  %12d  %12d  %12d  %12d  %12d  %12d\n", "total", $tot_nhits1p0, $tot_nhits1p1, $tot_nid, $tot_nol, $tot_nunq1p0, $tot_nunq1p1);

printf("#\n");
printf("# Output file with list of identical hits:             %-30s\n", $id_file);
printf("# Output file with list of overlapping hits:           %-30s\n", $ol_file);
printf("# Output file with list of Infernal 1.0   unique hits: %-30s\n", $unq1p0_file);
printf("# Output file with list of Infernal 1.1.1 unique hits: %-30s\n", $unq1p1_file);
exit 0;

#############
# SUBROUTINES
#############

# Subroutine: parse_gff()
# Args:       $gff_file:  GFF file to parse
#             $nhits_HR:  ref to hash; key: "accession:name", value: number of hits
#             $hits_HHAR: ref to 2d hash of arrays we will fill with hit info from gff
#
# Returns:    number of hits read from the file
# Dies:       if GFF file is in unexpected format

sub parse_gff {
  if(scalar(@_) != 3) { die "ERROR parse_gff() entered with wrong number of input args"; }

  my ($gff_file, $nhits_HR, $hits_HHAR) = @_; # info for a hit from hits1p0_HHAR

  my ($name, $accn, $evalue, $accn_name);

  open(GFF, $gff_file) || die "ERROR unable to open $gff_file for reading";
  while(my $line = <GFF>) { 
    if($line !~ m/^\#/) { 
      chomp $line;
      #gi|687371309|dbj|BBLU01000025.1|	cmsearch-1.0	rna	22	138	91.30	-	.	gb_key=5S_rRNA;rfam_acc=RF00001;evalue=6.65e-20
      my @elA = split(/\s+/, $line);
      if(scalar(@elA) != 9) { die "ERROR unable to parse GFF file $gff_file line $line"; }
      my ($seq, $start, $end, $score, $strand, $extra) = ($elA[0], $elA[3], $elA[4], $elA[5], $elA[6], $elA[8]);
      if($extra =~ /gb\_key\=(\S+)\;rfam\_acc\=(RF\d+)\;evalue\=(\S+)/) { 
        ($name, $accn, $evalue) = ($1, $2, $3);
        $accn_name = "$accn:$name";
        $nhits_HR->{$accn_name}++;
      }
      else { 
        die ("ERROR unable to parse (2) GFF file $gff_file line $line");
      }
      if(! exists ($hits_HHAR->{$accn_name})) { 
        %{$hits_HHAR->{$accn_name}} = ();
      }
      if(! exists ($hits_HHAR->{$accn_name}{$seq})) { 
        @{$hits_HHAR->{$accn_name}{$seq}} = ();
      }
      my $value = $start . ":" . $end . ":" . $strand . ":" . $score . ":" . $evalue;
      push(@{$hits_HHAR->{$accn_name}{$seq}}, $value);
    }
  }
  close(GFF);
  
  return;
}

# Subroutine: do_and_print_comparisions()
# Args:       $hits1_HHAR: ref to 2d hash of arrays with hit info from a gff file
#             $hits2_HHAR: ref to 2d hash of arrays with hit info from a gff file
#             $nid_HR:     ADDED TO HERE (if !undef); ref to hash:
#                          key: "rfam-name:rfam-accn"
#                          value: number of identical hits between hits1_HHAR and hits2_HHAR for this family                    
#             $nol_HR:     ADDED TO HERE (if !undef); ref to hash:
#                          key: "rfam-name:rfam-accn"
#                          value: number of overlapping hits between hits1_HHAR and hits2_HHAR for this family                    
#             $nunq_HR:    ADDED TO HERE; ref to hash:
#                          key: "rfam-name:rfam-accn"
#                          value: number of unique hits in hits1_HHAR (0 overlapping hits in hits2_HHAR) for this family                    
#             $id_FH:      file handle for printing info on identical hits, can be undef
#                          to not print this info 
#             $ol_FH:      file handle for printing info on overlapping non-identical hits, 
#                          can be undef to not print this info (if this is second call of function)
#             $unq_FH:     file handle for printing info on unique hits in hits1_HHAR that 
#                          do not overlap with any hits in hits2_HHAR
# Returns:    void
# Dies:       if more than one hit in hits2_HHAR overlaps with the same hit in hits1_HHAR.

sub do_and_print_comparisons {
  if(scalar(@_) != 8) { die "ERROR do_and_print_comparison() entered with wrong number of input args"; }

  my ($hits1_HHAR, $hits2_HHAR, $nid_HR, $nol_HR, $nunq_HR, $id_FH, $ol_FH, $unq_FH) = @_;

  my ($start1, $end1, $strand1, $score1, $evalue1); # info for a hit from hits1_HHAR
  my ($start2, $end2, $strand2, $score2, $evalue2); # info for a hit from hits2_HHAR
  my ($nhits1, $nhits2); # number of hits for a specific model to a specific sequence
  my ($i, $j);           # counters
  my $nres_overlap;      # number of residues (nucleotides) of overlap
  my $max_nres_overlap;  # number of residues (nucleotides) of overlap for max overlapping hit
  my $found_id = 0;      # if '1': we've already found an identical hit to the current one
  my $found_ol = 0;      # if '1': we've already found a non-identical overlapping hit to the current one
  my $nid_tot = 0;       # number of hits that are identical
  my $nol_tot = 0;       # number of hits that overlap on same strand but are not identical
  my $nunq_tot = 0;      # number of hits that are unique to $hits1_HHAR (don't overlap on 
                         # same strand with any hits in $hits2_HHAR)
  my $ol_toprint = "";   # string to print to overlap file

  foreach my $accn_name (keys %{$hits1_HHAR}) { 
    foreach my $seq (keys %{$hits1_HHAR->{$accn_name}}) { 
      $nhits1 = scalar(@{$hits1_HHAR->{$accn_name}{$seq}});
      if(exists $hits2_HHAR->{$accn_name} && exists $hits2_HHAR->{$accn_name}{$seq}) { 
        $nhits2 = scalar(@{$hits2_HHAR->{$accn_name}{$seq}});
      }
      else { 
        $nhits2 = 0;
      }
      for($i = 0; $i < $nhits1; $i++) { 
        $found_id = 0; 
        $found_ol = 0; 
        $ol_toprint = "";
        $nres_overlap = 0;
        $max_nres_overlap = 0;
        ($start1, $end1, $strand1, $score1, $evalue1) = split(":", $hits1_HHAR->{$accn_name}{$seq}[$i]);
        if($start1 > $end1) { die "ERROR start1 > end1 $start1 > $end1\n"; }
        for($j = 0; $j < $nhits2; $j++) { 
          ($start2, $end2, $strand2, $score2, $evalue2) = split(":", $hits2_HHAR->{$accn_name}{$seq}[$j]);
          if($start2 > $end2) { die "ERROR start2 > end2 $start2 > $end2\n"; }
          if($strand1 eq $strand2) { 
            if($start1 == $start2 && $end1 == $end2) { # identical
              $nres_overlap = $end1 - $start1 + 1;
              $nid_tot++;
              if($found_id) { die "ERROR found two identical hits to $hits1_HHAR->{$accn_name}{$seq}[$i]"; }
              if(defined $id_FH) { 
                printf $id_FH ("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
                               $accn_name, $seq, $nres_overlap . "-FULL", 
                               $start1, $end1, $strand1, $score1, $evalue1, 
                               $start2, $end2, $strand2, $score2, $evalue2);
              }
              if(defined $nid_HR) { 
                $nid_HR->{$accn_name}++;
              }
              $found_id = 1;
            }
            else { # not identical
              $nres_overlap = get_nres_overlap($start1, $end1, $start2, $end2);
              if($nres_overlap > 0) { # overlap, but not identical
                if($found_id) { die "ERROR found an overlapping hit and an identical hit to $hits1_HHAR->{$accn_name}{$seq}[$i]"; }
                $found_ol = 1;
                # keep track of size and score of overlap
                if($nres_overlap > $max_nres_overlap) { 
                  # we found a 'better' (longer) overlap, rewrite $ol_toprint
                  $ol_toprint = sprintf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
                                        $accn_name, $seq, $nres_overlap, 
                                        $start1, $end1, $strand1, $score1, $evalue1, 
                                        $start2, $end2, $strand2, $score2, $evalue2);
                  $max_nres_overlap = $nres_overlap;
                }
              }
            }
          } # end of 'if($strand1 eq $strand2)'
        } # end of 'for($j = 0; $j < $nhits2; $j++)'

        if((! $found_id) && (! $found_ol)) { # hit is unique, there are no overlaps
          $nunq_tot++;
          printf $unq_FH  ("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
                           $accn_name, $seq, 0, 
                           $start1, $end1, $strand1, $score1, $evalue1);
          $nunq_HR->{$accn_name}++;
        }
        elsif($found_ol) { # found an overlap (and not an identity)
          if($found_id) { die "ERROR found an overlapping hit and an identical hit (case 2) to $hits1_HHAR->{$accn_name}{$seq}[$i]"; } 
          $nol_tot++;
          if(defined $ol_FH) {
            print $ol_FH $ol_toprint;
          }
          if(defined $nol_HR) { 
            $nol_HR->{$accn_name}++;
          }
        }
      } # end of 'for($i = 0; $i < $nhits; $i++)'
    } # end of 'foreach my $seq (keys %{$hits1_HHAR->{$accn_name}})'
  } # end of 'foreach my $accn_name (keys %{$hits1_HHAR})'
  return ($nid_tot, $nol_tot, $nunq_tot);
}

# Subroutine: get_nres_overlap()
# Args:       $start1: start position of hit 1 (must be <= $end1)
#             $end1:   end   position of hit 1 (must be >= $end1)
#             $start2: start position of hit 2 (must be <= $end2)
#             $end2:   end   position of hit 2 (must be >= $end2)
#
# Returns:    Number of residues of overlap between hit1 and hit2,
#             0 if none
# Dies:       if $end1 < $start1 or $end2 < $start2.

sub get_nres_overlap {
  if(scalar(@_) != 4) { die "ERROR get_nres_overlap() entered with wrong number of input args"; }

  my ($start1, $end1, $start2, $end2) = @_; 

  if($start1 > $end1) { die "ERROR start1 > end1 ($start1 > $end1) in get_nres_overlap()"; }
  if($start2 > $end2) { die "ERROR start2 > end2 ($start2 > $end2) in get_nres_overlap()"; }

  # Given: $start1 <= $end1 and $start2 <= $end2.
  
  # Swap if nec so that $start1 <= $start2.
  if($start1 > $start2) { 
    my $tmp;
    $tmp   = $start1; $start1 = $start2; $start2 = $tmp;
    $tmp   =   $end1;   $end1 =   $end2;   $end2 = $tmp;
  }
  
  # 3 possible cases:
  # Case 1. $start1 <=   $end1 <  $start2 <=   $end2  Overlap is 0
  # Case 2. $start1 <= $start2 <=   $end1 <    $end2  
  # Case 3. $start1 <= $start2 <=   $end2 <=   $end1
  if($end1 < $start2) { return 0; }                      # case 1
  if($end1 <   $end2) { return ($end1 - $start2 + 1); }  # case 2
  if($end2 <=  $end1) { return ($end2 - $start2 + 1); }  # case 3
  die "Unforeseen case in get_nres_overlap $start1..$end1 and $start2..$end2";

  return; # NOT REACHED
}
