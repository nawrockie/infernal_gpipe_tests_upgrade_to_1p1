EPN, Thu Apr  2 12:58:33 2015

00README.txt

This directory contains files related to a test used to compare the
performance of Infernal 1.0 and Infernal 1.1.1 and Rfam 11.0 and Rfam
12.0 for annotating 100 genomes using 30 Rfam models.

Related JIRA ticket:
GP-10961: "update Rfam in third party data"

For more information, see:
/home/nawrocke/notebook/15_0306_inf_1p1_gpipe_expts/00LOG.txt

Sections of this file:
- Overview of the test
- The Genomes and CMs used in the test
- Summary of results
- Description of files in this directory
- Instructions for reproducing this test

=====================================
Overview of the test:

This test compares the 'cmsearch' program of Infernal v1.0 and
Infernal v1.1.1 using two sets of Rfam CM models: Rfam 11.0 and Rfam
12.0 by searching 100 randomly selected archaeal or bacterial genomes.

Two sets of results are presented:
- Infernal 1.0 vs Infernal 1.1.1 using Rfam 11.0 models and GA cutoffs
  (file: rfam11-hit-comparison.txt)
- Infernal 1.0 vs Infernal 1.1.1 using Rfam 12.0 models and GA cutoffs
  (file: rfam12-hit-comparison.txt)

It is necessary to do these comparisons separately because CMs can
change between different versions of Rfam, and the GA score cutoffs
(one per model) changed significantly between Rfam 11.0 and Rfam
12.0. The GA cutoff for a model is the score above which the Rfam
curators have observed 0 false positives (in their opinion). Rfam
curators believe all hits scoring above the GA cutoffs in a large
sequence database they search prior to each release of Rfam are 'real'
(homologous).

The reason the GA cutoffs changed significantly between 11.0 and 12.0
is that Rfam 12.0 was the first version to not use BLAST
pre-filters. Rfam 11.0 and earlier used BLAST to pre-filter the large
database prior to running Infernal. The removal of the BLAST filters
had a large impact on the results and so required a change to many of
the GA cutoffs.

=====================================
The Genomes and CMs used in the test:

The 100 genomes were randomly selected from 
/panfs/pan1.be-md.ncbi.nlm.nih.gov/gpipe/bacterial_pipeline/data19/

using the script 'step2-get-100-random-genomes.pl' located in this
directory.

The 30 Rfam models used were those currently used by the GPIPE
bacterial annotation pipeline. The CM files currently used by GPIPE 
are here:

/panfs/pan1.be-md.ncbi.nlm.nih.gov/gpipe/ThirdParty/ExternalData/Rfam/11.0/RF0001.cm
/panfs/pan1.be-md.ncbi.nlm.nih.gov/gpipe/ThirdParty/ExternalData/Rfam/11.0/Rfam.selected1.cm

The first file contains a single CM (RF0001.cm) and the second
contains 29 CMs selected by Azat and Tatiana.
All of these files are from Rfam 11.0.

Currently, GPIPE uses a bit score cutoff of 40 for 5S_rRNA and the
Rfam 'GA' cutoff for the other 29 models. The different cutoffs is
what necessitates we use two CM files and two calls of cmsearch, one
for 5S and one for the other 29.

It was necessary to convert these CMs to version 1.1 format, and also
to obtain Rfam 12.0 versions of these 30 CMs. 

The script 'step1-get-cm-files.sh' obtained the necessary CM files
(copied them to, or created them in, this directory. That file has
comments that explain what was done and why.

=====================================
Summary of results:

Rfam11 results (taken from rfam11-hit-comparison.txt):
#Rfam-accession:name       Inf1p0-#hits  Inf1p1-#hits    #identical      #overlap  #1p0-#unique  #1p1-#unique
#------------------------  ------------  ------------  ------------  ------------  ------------  ------------
total                              2189          2094          1858           192           139            71

Rfam12 results (taken from rfam12-hit-comparison.txt):
#Rfam-accession:name       Inf1p0-#hits  Inf1p1-#hits    #identical      #overlap  #1p0-#unique  #1p1-#unique
#------------------------  ------------  ------------  ------------  ------------  ------------  ------------
total                              1561          1730          1446           103            12           204

And running time comparison (time-comparison.txt file)
#  rfam    Inf-1.0  Inf-1.1.1  1.0/1.1.1
#------  ---------  ---------  ---------
 rfam11  131.7600h    0.6982h      188.7
 rfam12   73.8020h    0.7849h       94.0

For Rfam11, Infernal 1.1.1 loses 139 of 2189 hits that were found by
Infernal 1.0, but finds 71 new ones. Infernal 1.1.1 is about 190 times
faster than Infernal 1.0, requiring about 0.7 hours for 100 genomes,
about 25 seconds per genome. Infernal 1.0 required about 130 hours, or
about 75 minutes per genome.

For Rfam12, Infernal 1.1.1 loses only 12 hits found by Infernal 1.0,
while finding 204 new ones. Again it is much faster, requiring about
30 seconds per genome to about 45 minutes for Infernal 1.0.

Why such large differences between Rfam11 and Rfam12?

The difference is due to the shift in the GA cutoffs (described
briefly in the 'Overview of the test' section above) between Rfam11
and Rfam12. In general Rfam12 cutoffs are higher scores, meaning that
fewer sequences survive above them. Importantly, Rfam curators have
set the GA cutoff to separate possible false positives from believed
homologs. This means that many of the Rfam11 hits that fall below the
Rfam12 cutoffs may be false positives, and so I'd argue it's better
not to include them.

The reason the Rfam11 GA cutoffs were so much lower than the Rfam12 GA
cutoffs is because when those cutoffs were determined Rfam was still
using a BLAST prefilter that removed many false positives
outright. With the BLAST prefilter, only sequences that survived a
BLAST search of trusted family sequences against the database were
searched with Infernal. This removed many potential false positives
that Infernal would have scored highly.  Since GPIPE did not use such
a BLAST prefilter, using the Rfam11 GA cutoffs was a little dangerous
from the standpoint of avoiding false annotations.

I believe these results suggest it would be a good idea to upgrade to
using Infernal 1.1.1 and Rfam 12 in GPIPE.

=====================================
Description of files in this directory:

List of subsections:
- CM files
- Scripts (for reproducing)
- Scripts called by do-searches.sh and do-comparison.sh:
- Output files created by scripts called by 'do-searches.sh'
- Search output files
- Output files created by scripts called by 'do-comparison.sh'
- Miscellaneous files

-------------------------------------
CM files:
RF00001.rfam11.i1p0.cm:  
  5S_rRNA Rfam 11 CM file in Infernal 1.0 format

RF00001.rfam11.i1p1.cm:  
  5S_rRNA Rfam 11 CM file in Infernal 1.1 format

GPIPE.29.rfam11.i1p0.cm: 
  Rfam 11 CM file with 29 other GPIPE models in Infernal 1.0 format

GPIPE.29.rfam11.i1p1.cm: 
  Rfam 11 CM file with 29 other GPIPE models in Infernal 1.1 format

RF00001.rfam12.i1p0.cm:  
  5S_rRNA Rfam 12 CM file in Infernal 1.0 format

RF00001.rfam12.i1p1.cm:
  5S_rRNA Rfam 12 CM file in Infernal 1.1 format

GPIPE.29.rfam12.i1p0.cm:
  Rfam 12 CM file with 29 other GPIPE models in Infernal 1.0 format

GPIPE.29.rfam12.i1p1.cm: 
  Rfam 12 CM file with 29 other GPIPE models in Infernal 1.1 format

-------------------------------------
Scripts (for reproducing):
***Shell scripts should be run using bash shell***

Main scripts:
do-searches.sh:
  1st of 2 scripts for reproducing full test. A shell script that does
  steps 1-4, from getting CM files to submitting all cmsearch jobs to
  cluster.

do-comparison.sh:
 2nd of 2 scripts for reproducing full test. To be run only after all
 jobs submitted by do-searches.sh finish running on the cluster. This
 script does steps 5-9: converts cmsearch output to GFF, compares
 results and outputs summary statistics.

-------------------------------------
Scripts called by do-searches.sh and do-comparison.sh:

step1-get-cm-files.sh:
 shell script for copying/creating the CM files

step1-helper-concatenate-cms.sh: 
 shell script called by step1-get-cm-files.sh

step1-helper-qsub-calibrate.sh:  
  shell script that submits cmcalibrate jobs to the cluster, called by
  step1-get-cm-files.sh

step2-get-genomes.pl:
  Perl script that picks the 100 random genomes. ***Since the
  underlying directory these are pulled from seems to be changing,
  this is not guaranteed to be reproducible.***

step3-make-inf1p0-rfam11-rfam12-qsub-scripts.pl: 
  Perl script for making qsub scripts for submitting all Infernal 1.0
  search jobs to the cluster.

step4-make-inf1p1-rfam11-rfam12-qsub-scripts.pl: 
  Perl script for making qsub scripts for submitting all Infernal 1.1
  search jobs to the cluster.

step5-convert-i1p0-to-gff.pl: 
  Perl script for converting Infernal 1.0 --tabfile output to GFF
  format. 

step5-helper-i1p0-tabfile2gff.pl:
  Perl script called by step5-convert-i1p0-to-gff.pl.

step6-convert-i1p1-to-gff.pl: 
  Perl script for converting Infernal 1.1 --tblout output to GFF
  format. 

step6-helper-i1p1-tabfile2gff.pl:
  Perl script called by step6-convert-i1p1-to-gff.pl.

step7-compare-gff-i1p0-i1p1.pl:
  Perl script for comparing GFF output from Infernal 1.0 and Infernal
  1.1.

step8-process-times.pl:
  Perl script for processing time output.

step9-compare-timings.pl:
  Perl script for comparing Infernal 1.0 and Infernal 1.1 running
  times.

-------------------------------------
Output files created by scripts called by 'do-searches.sh':

2851.list: 
  output by step2-get-genomes.pl, a list of all genomes in
  /panfs/pan1.be-md.ncbi.nlm.nih.gov/gpipe/bacterial_pipeline/data19/
  (as of April 1, 2015 at 14:47:17).

r100.genome.list:
  the 100 randomly selected genomes and associated fasta files,
  selected from 2851.list from within step2-get-genomes.pl.

i1p0.qsub.txt: 
  shell script that submits 400 Infernal 1.0 cmsearch jobs
  to the cluster. 200 for Rfam11 (2 per genome), and 200 for Rfam12.
  Created by step3-make-inf1p0-rfam11-rfam12-qsub-scripts.pl

i1p1.qsub.txt: 
  shell script that submits 400 Infernal 1.1.1. cmsearch jobs
  to the cluster.
  Created by step4-make-inf1p1-rfam11-rfam12-qsub-scripts.pl.

rfam11.name2accn: 
  file that maps Rfam names to accessions for Rfam 11.
  Created by step1-get-cmfiles.sh.

rfam12.name2accn: 
  file that maps Rfam names to accessions for Rfam 12.
  Created by step1-get-cmfiles.sh.

-------------------------------------
Search output files:

Directories:
rfam{11,12}-{i1p0,i1p1}/
  directory with a .tbl, .gff, .err, and .time file for each of the
  200 searches of the {Rfam11,Rfam12} models using Infernal {1.0,1.1.1}

Files in those directories: 
 *.tbl:  cmsearch --tabfile output (Infernal 1.0) or cmsearch --tblout
         output (Infernal 1.1.1) for a search.
 *.gff:  GFF format, converted from *.tbl files (same data)
 *.err:  SGE error 
 *.time: /usr/bin/time output for a search         

-------------------------------------
Output files created by scripts called by 'do-comparison.sh'

{rfam11,rfam12}.{i1p0,i1p1}.list
  List of .tbl files for Infernal {1.0,1.1.1} searches with
  {Rfam11,Rfam12}. Created by do-comparison.sh.

{rfam11,rfam12}.{i1p0,i1p1}.gff
  Concatenated GFF files for Infernal {1.0,1.1.1} searches with
  {Rfam11,Rfam12}. Created by do-comparison.sh.

{rfam11,rfam12}.id:
  List of all identical hits between Infernal 1.0 and Infernal 1.1.1
  for {Rfam11,Rfam12}. Created by step7-compare-gff-i1p0-i1p1.pl.

{rfam11,rfam12}.ol:
  List of all non-identical but overlapping hits (by at least one nt)
  between Infernal 1.0 and Infernal 1.1.1 for {Rfam11,Rfam12}. In the
  case where more than one Infernal 1.1.1 hit overlaps with a single
  Infernal 1.0 hit, only the best one is output, where best is judged
  by largest number of overlapping nucleotides. 
  Created by step7-compare-gff-i1p0-i1p1.pl.

{rfam11,rfam12}.unq1p0:
  List of all Infernal 1.0 hits for {Rfam11,Rfam12} for which there
  were zero overlapping Infernal 1.1.1 hits.
  Created by step7-compare-gff-i1p0-i1p1.pl.

{rfam11,rfam12}.unq1p1:
  List of all Infernal 1.1.1 hits for {Rfam11,Rfam12} for which there
  were zero overlapping Infernal 1.0 hits.
  Created by step7-compare-gff-i1p0-i1p1.pl.

{rfam11,rfam12}-hit-comparison.txt:
  Summary of comparison of Infernal 1.0 and Infernal 1.1.1 for
  {Rfam11,Rfam12}. Per family and total statistics are given in
  tabular form. Created by step7-compare-gff-i1p0-i1p1.pl.

{rfam11,rfam12}-{i1p0,i1p1}.time: 
  Total time for all Infernal {1.0,1.1.1} searches with
  {Rfam11,Rfam12} models. Created by step8-process-time.pl.

time-comparison.txt: 
  Table comparing total running times. Created by
  step9-compare-timings.pl.

-------------------------------------
Miscellaneous files:

to-reproduce-inf1p0-inf1p1-rfam11-rfam12-gpipe-test-040215.tar.gz: 
  Gzipped tarball that when extracted will produce a directory
  called to-reproduce-inf1p0-inf1p1-rfam11-rfam12-gpipe-test-040215/
  in the current working directory. That directory will include all
  the files necessary for reproducing this test, as described below in
  'Instructions for reproducing this test'.

00README.txt: this file.

=====================================
Instructions for reproducing this test:
***Use the bash shell for this if you're not already***

1. Untar and gunzip the file
   'to-reproduce-inf1p0-inf1p1-rfam11-rfam12-gpipe-test-040215.tar.gz'

   > tar xfz to-reproduce-inf1p0-inf1p1-rfam11-rfam12-gpipe-test-040215.tar.gz

2. Move into the newly created dir:

   > cd to-reproduce-inf1p0-inf1p1-rfam11-rfam12-gpipe-test-040215

3. Execute 'do-searches.sh', this will submit searches to the cluster.
   See the comments in 'do-searches.sh' for more information.

   > sh do-searches.sh

4. Wait approximately 3.5 hours for all search jobs to finish.
   Then when they're all finished, execute 'do-comparison.sh'.
   See comments in 'do-comparison.sh' for more information

   > sh do-comparison.sh

   This will create the results files listed above (notably
   rfam11-hit-comparison.txt, rfam12-hit-comparison.txt and
   time-comparison.txt) and output some of them to the screen.

   After this your directory should include the same files as in 
   this directory, which are listed above in this file.

