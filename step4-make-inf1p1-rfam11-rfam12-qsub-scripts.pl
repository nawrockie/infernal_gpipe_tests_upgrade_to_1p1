#!/usr/bin/env perl
# EPN, Thu Mar 19 10:07:36 2015
# step4-make-inf1p1-rfam11-rfam12-qsub-scripts.pl: 
# 
# Given a list of 100 fasta files, create a qsub script that will
# submit four Infernal 1.1 cmsearch commands for each genome. The
# first two will use Rfam 11 models and cutoffs and the second two
# will use Rfam 12 models and cutoffs.
# 
# The first search for Rfam 11 will use the 5S_rRNA model and and the
# second will use 29 other models that GPIPE uses.  Similarly, the
# first search for Rfam 12 will use the 5S_rRNA model and and the
# second will use 29 other models that GPIPE uses.
# 
# The CM files for Rfam 11 are in:
# /panfs/pan1.be-md.ncbi.nlm.nih.gov/gpipe/ThirdParty/ExternalData/Rfam/11.0/";
# 
# The CM files for Rfam 12 are in:
# /home/nawrocke/db/rfam/rfam_12.0/
#
# This script is part of a multi-step procedure for benchmarking
# Infernal 1.0 and Rfam 11.0 versus Infernal 1.1 and Rfam 12.0.
# 
# Input: multiple lines of two tab-delimited fields:
#  <genome-key> <genome-fasta-file>
#
# Input is generated as output of related script: step2-get-100-random-genomes.pl.
# 
use strict;
use warnings;

my $usage = "perl step4-make-inf1p1-rfam11-rfam12-qsub-script.pl\n";
$usage .= "\t<step1 output>\n";
$usage .= "\t<Rfam 11 output dir (will be created, must not already exist)>\n";
$usage .= "\t<Rfam 12 output dir (will be created, must not already exist)>\n";
if(scalar(@ARGV) != 3) { 
  die $usage;
}
my ($infile, $out11dir, $out12dir) = (@ARGV);

# hard-coded paths
my $idir    = "/usr/local/infernal/1.1.1/bin";

my $cm11dir   = "./";
my $cm12dir   = "./";
my @cm11fileA = ($cm11dir . "RF00001.rfam11.i1p1.cm", $cm11dir . "GPIPE.29.rfam11.i1p1.cm");
my @cm12fileA = ($cm12dir . "RF00001.rfam12.i1p1.cm", $cm12dir . "GPIPE.29.rfam12.i1p1.cm");

my @cmkeyA         = ("5S", "29");
my $cm_common_opts = "--rfam --cpu 0 --nohmmonly";
# --rfam:      use filters used by Rfam, speeds up searches
# --cpu 0:     do not use multiple threads (for fair comparison with infernal 1.0)
# --nohmmonly: always use CM, even for zero basepair models (for fair comparison with infernal 1.0)
my @cmoptsA = ($cm_common_opts . " -T 40", $cm_common_opts . " --cut_ga");

# ensure our CM files exist
foreach my $cmfile (@cm11fileA, @cm12fileA) { 
  if(! -s $cmfile) { die "ERROR $cmfile does not exist"; }
}

if(-d $out11dir) { die "ERROR directory named $out11dir already exists. Remove it and try again, or pick a different output dir name"; }
if(-e $out11dir) { die "ERROR file named $out11dir already exists. Remove it and try again, or pick a different output dir name"; }
if(-d $out12dir) { die "ERROR directory named $out12dir already exists. Remove it and try again, or pick a different output dir name"; }
if(-e $out12dir) { die "ERROR file named $out12dir already exists. Remove it and try again, or pick a different output dir name"; }

open(IN, $infile) || die "ERROR unable to open file $infile for reading"; 

RunCommand("mkdir $out11dir");
RunCommand("mkdir $out12dir");

while(my $line = <IN>) { 
  chomp $line;
  my ($fakey, $fafile) = split(/\t/, $line);
  if(! -e $fafile) { die "ERROR fasta file $fafile for key $fakey does not exist"; }

  for(my $c = 0; $c < scalar(@cmkeyA); $c++) { 
    my $cmkey      = $cmkeyA[$c];
    my $cmopts     = $cmoptsA[$c];

    my $cm11file   = $cm11fileA[$c];
    my $job11name  = "J11." . $fakey . "." . $cmkey;
    my $root11     = $out11dir . "/" . $fakey . "." . $cmkey;
    my $tblout11file = $root11 . ".tbl";
    my $err11file    = $root11 . ".err";
    my $time11file   = $root11 . ".time";

    # Rfam 11 job:
    # use /usr/bin/time to time the execution time
    # don't save stdout
    printf("qsub -N $job11name -b y -v SGE_FACILITIES -P unified -S /bin/bash -cwd -V -j n -o /dev/null -e $err11file -l h_rt=28800,mem_free=8G,h_vmem=16G -m n \"/usr/bin/time $idir/cmsearch $cmopts --tblout $tblout11file $cm11file $fafile > /dev/null 2> $time11file\"\n");

    my $cm12file   = $cm12fileA[$c];
    my $job12name  = "J12." . $fakey . "." . $cmkey;
    my $root12     = $out12dir . "/" . $fakey . "." . $cmkey;
    my $tblout12file = $root12 . ".tbl";
    my $err12file    = $root12 . ".err";
    my $time12file   = $root12 . ".time";

    # Rfam 12 job:
    # use /usr/bin/time to time the execution time
    # don't save stdout
    printf("qsub -N $job12name -b y -v SGE_FACILITIES -P unified -S /bin/bash -cwd -V -j n -o /dev/null -e $err12file -l h_rt=28800,mem_free=8G,h_vmem=16G -m n \"/usr/bin/time $idir/cmsearch $cmopts --tblout $tblout12file $cm12file $fafile > /dev/null 2> $time12file\"\n");
  }
}
exit 0;

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
