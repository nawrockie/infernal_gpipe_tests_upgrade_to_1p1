#!/usr/bin/env perl
# EPN, Fri Mar 20 11:12:53 2015
# step5-convert-i1p0-to-gff.pl
# 
# Given a list of Infernal 1.0 cmsearch --tabfile output files,
# convert each of them to gff files.
# 
# Each of the tabfile files must end with .tbl.
# 
# Takes two command line arguments:
# <name to accn file> <file with list of cmsearch v1.0 tabfiles>
# 
# <name to accn file> should contain multiple lines of the format
# Rfam-name Rfam-accn
#
# <file with list of cmsearch v1.0 tabfiles>
# should have N lines, each with the name of a single tab file
#
# <name to accn file> is necessary because Infernal 1.0 does not 
# include the accession in the output, and Rfam family names can
# change (one of the GPIPE Rfam families QUAD RF00113 changed it's
# name to SIB_RNA in Rfam 12.0, so to compare it we need to use
# the accession).
use strict;
use warnings;

# hard-coded paths
my $script_dir = "./";
my $gff_script = $script_dir . "step5-helper-i1p0-tabfile2gff.pl";
if(! -s $gff_script) { die "ERROR required script $gff_script does not exist"; }

my $usage = "perl step5-convert-i1p0-to-gff.pl <name to accn file> <file with list of Infernal 1.0 tabfiles>";
if(scalar(@ARGV) != 2) { die $usage; }

my ($name2accn_file, $listfile) = (@ARGV);
if(! -s $name2accn_file) { die "ERROR required file $name2accn_file does not exist"; }

open(IN, $listfile) || die "ERROR unable to open $listfile for reading";

my $nfiles = 0;
my $gff_file;
while(my $line = <IN>) { 
  my $tbl_file = $line;
  chomp $tbl_file;
  #1p0/crenarchaeote_SCGC_AAA261-L22.5S.tbl
  if($tbl_file =~ /(^.+).tbl/) { 
    $gff_file = $1 . ".gff";
  }
  else { 
    die "ERROR $tbl_file does not end in .tbl"; 
  }
  RunCommand("perl $gff_script $name2accn_file $tbl_file > $gff_file");
  $nfiles++;
}
close(IN);

printf("GFF files created for $nfiles Infernal 1.0 tab files\n");
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
