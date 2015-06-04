# do-searches.sh
#
# The first of two scripts for running tests of Infernal 1.0 versus
# Infernal 1.1.1 and Rfam 11.0 versus Rfam 12.0.
# The second script is 'do-comparison.sh, 
# so to run the searches and compare the results, do:
# > sh do-searches.sh
#
# This will submit 800 jobs to the cluster. Wait
# for them all to finish. The slowest should take
# about 4 hours. When they are all finised, do:
# > sh do-comparison.sh
# 
# Step 1: Copy/create the necessary CM files
sh step1-get-cmfiles.sh

# Step 2: Get a list of 100 random genomes:
# For reproducibility we don't redo this step but instead
# just use a precalculated list. This list was created
# using the following command on [EPN, Wed Apr  1 14:47:17 2015]
#
## perl step2-get-100-random-genomes.pl > r100.genome.list

# Step 3: Make qsub script for Infernal 1.0 Rfam 11.0 and Rfam 12.0 searches
#         and perform the searches
perl step3-make-inf1p0-rfam11-rfam12-qsub-scripts.pl r100.genome.list rfam11-i1p0 rfam12-i1p0 > i1p0.qsub.txt
# submit jobs
sh i1p0.qsub.txt

# Step 4: Make qsub script for Infernal 1.1 Rfam 11.0 and Rfam 12.0 searches
#         and perform the searches
perl step4-make-inf1p1-rfam11-rfam12-qsub-scripts.pl r100.genome.list rfam11-i1p1 rfam12-i1p1 > i1p1.qsub.txt
# submit jobs
sh i1p1.qsub.txt 
