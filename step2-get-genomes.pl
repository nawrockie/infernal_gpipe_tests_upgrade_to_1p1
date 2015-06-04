#!/usr/bin/env perl
# EPN, Thu Mar 19 08:46:06 2015
#
# step1-get-100-random-genomes.pl: make a list of 100 randomly selected 
# genomes from /panfs/pan1.be-md.ncbi.nlm.nih.gov/gpipe/bacterial_pipeline/data19/.
# 
# Part of a multi-step procedure for benchmarking Infernal 1.0 versus Infernal 1.1
# and Rfam 11.0 versus Rfam 12.0.
# 

use strict;
use warnings;

# hard-coded paths
my $datadir = "/panfs/pan1.be-md.ncbi.nlm.nih.gov/gpipe/bacterial_pipeline/data19/";
my $selectn = "/usr/local/infernal/1.1.1/bin/esl-selectn";

my $noutput = 0;

# list all the directories to a file which we'll randomly choose 100 from
RunCommand("ls $datadir > 2851.list");

# randomly select 110 genomes, we only need 100 but we choose 110 here because not all
# directories listed in 2851.list will have annotation (a few percent do not)
RunCommand("$selectn --seed 33 110 2851.list > r110.list");

# for each genome directory $gdir listed in r110.list, look for a *.nucleotide.fa file
# in the most recently modified directory in $datadir/$gdir/output/bacterial_annot/
open(IN, "r110.list") || die "ERROR unable to open r110.list";
while(my $key = <IN>) {
  chomp $key;
  my $dir = $datadir . $key;
  # example $dir: /panfs/pan1.be-md.ncbi.nlm.nih.gov/gpipe/bacterial_pipeline/data19/Actinobacillus_ureae_ATCC_25976/Actinobacillus_ureae_ATCC_25976  

  my @subdirA = split(/\n/, `ls -ltr $dir | grep ^d | awk '{ print \$9 }'`);
  # example of 'ls -ltr' output:
  # > ls -ltr /panfs/pan1.be-md.ncbi.nlm.nih.gov/gpipe/bacterial_pipeline/data19/Actinobacillus_ureae_ATCC_25976
  # total 128
  # drwxrwsr-x 3 gpipe contig 4096 Feb 27 15:54 244828-DENOVO-20150227-1402.1474874
  # drwxrwsr-x 6 gpipe contig 4096 Mar  1 16:33 244828-DENOVO-20150227-1622.1478424
  #
  # will give @subdirA = ("244828-DENOVO-20150227-1402.1474874", "244828-DENOVO-20150227-1622.1478424");
  
  # we are only interested in the most recent subdir, which will be $subdirA[(scalar(@subdirA)-1)]
  # determine if there's a *.annotation.nucleotide.fa file in the '/output/bacterial_annot' subdirectory in there.
  my $fafile_dir = $dir. "/" . $subdirA[(scalar(@subdirA)-1)] . "/output/bacterial_annot";
  my $fafile     = `ls $fafile_dir/*.annotation.nucleotide.fa`;
  # example $fafile:
  # /panfs/pan1.be-md.ncbi.nlm.nih.gov/gpipe/bacterial_pipeline/data19/Actinobacillus_ureae_ATCC_25976/244828-DENOVO-20150227-1622.1478424/output/bacterial_annot/AEVG01.annotation.nucleotide.fa

  if(defined $fafile && $fafile ne "") { 
    # there is a fasta file, make sure there's only 1
    if($fafile =~ m/\w+\n\w+/) { die "ERROR more than one *.annotation.nucleotide.fa file in $fafile_dir"; }

    # if we get here, there's only 1 fasta file, output it
    print $key . "\t" . $fafile;
    $noutput++;
    if($noutput == 100) { # success
      exit 0; 
    }
  }
} # end of while($line = <IN>)
# if we get here, then we ran out of lines, and didn't reach 100
die "ERROR, only output $noutput lines, didn't get to 100";

exit 1;


#############
# SUBROUTINES
#############
#
# Subroutine: RunCommand()
# Args:       $cmd:            command to run, with a "system" command;
#
# Returns:    void
# Dies:       if $cmd fails

sub RunCommand {
  if(scalar(@_) != 1) { die "ERROR RunCommand() entered with wrong number of input args"; }

  my ($cmd) = @_;

  system($cmd);
  if($? != 0) { die "ERROR command failed:\n$cmd\n"; }

  return;
}
