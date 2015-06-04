#!/usr/bin/env perl
# EPN, Fri Mar 20 11:39:07 2015
# step6-convert-i1p1-to-gff.pl
# 
# Given a list of Infernal 1.1 cmsearch --tblout output files,
# convert each of them to gff files.
# 
# Each of the tblout files must end with .tbl.
#
# Takes one command line argument: 
# <file with list of cmsearch v1.0 tabfiles>
# 
# <file with list of cmsearch v1.0 tabfiles>
# should have N lines, each with the name of a single tab file
#
use strict;
use warnings;

# hard-coded paths
my $script_dir = "./";
my $gff_script = $script_dir . "step6-helper-i1p1-tblout2gff.pl";
if(! -s $gff_script) { die "ERROR required script $gff_script does not exist"; }

my $usage = "perl step6-convert-i1p1-to-gff.pl <file with list of Infernal 1.1 tblout files>";
if(scalar(@ARGV) != 1) { die $usage; }

my ($listfile) = (@ARGV);

my $nfiles = 0;
my $gff_file;

open(IN, $listfile) || die "ERROR unable to open $listfile for reading";
while(my $line = <IN>) { 
  my $tbl_file = $line;
  chomp $tbl_file;
  #1p1/crenarchaeote_SCGC_AAA261-L22.5S.tbl
  if($tbl_file =~ /(^.+).tbl/) { 
    $gff_file = $1 . ".gff";
  }
  else { 
    die "ERROR $tbl_file does not end in .tbl"; 
  }
  RunCommand("perl $gff_script $tbl_file > $gff_file");
  $nfiles++;
}
close(IN);

printf("GFF files created for $nfiles Infernal 1.1 tblout files\n");
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
