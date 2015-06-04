# EPN, Mon Mar 30 13:31:51 2015
# 
# step1-get-cmfiles.sh
#
# teps taken to allow the comparison of Infernal 1.0 and
# Infernal 1.1 and Rfam 11.0 and Rfam 12.0 in the GPIPE pipeline for
# 100 random bacterial genomes.
#
# Step 1: obtain CM files needed for the tests.
# Step 2: obtain a mapping from Rfam11 to Rfam12 model names.
#
# CM files are copied/created in the current working directory
# and used by the remainder of the scripts in this directory
# to carry out the tests.
#
#############################
#############################
# Step 1: obtain CM files needed for the tests.
#
# The Infernal 1.0 Rfam 11.0 CM files currently used by GPIPE are here:
# 
# 5S_rRNA (RF00001) Rfam model only:
# /panfs/pan1.be-md.ncbi.nlm.nih.gov/gpipe/ThirdParty/ExternalData/Rfam/11.0/RF0001.cm
#
# 29 other models, selected by Azat and Tatiana 
# as most frequent and lacking high FP rate
# (ref: JIRA GP-10960, 12/30/14 9:19AM comment by Azat Badretdin):
# /panfs/pan1.be-md.ncbi.nlm.nih.gov/gpipe/ThirdParty/ExternalData/Rfam/11.0/Rfam.selected1.cm
#
# To do this comparison we need these 30 models from both Rfam 11.0 in both Infernal 1.0 
# and Infernal 1.1 format.
#
# So we need 4 sets of models:
# M1. Rfam 11.0 models in Infernal 1.0 format 
# M2. Rfam 11.0 models in Infernal 1.1 format 
# M3. Rfam 12.0 models in Infernal 1.1 format 
# M4. Rfam 12.0 models in Infernal 1.0 format
#
# Instructions with commands for creating these files are below.  For
# M1, M2, and M3, the commands will actually create the CM files.  For
# M4, it is necessary to run cmcalibrate for each of the 30 CMs.
# Since this is slow (takes about 110 CPU hours), To save time, we
# just copy the calibrated CM files to this directory.
# 
# The instructions for reproducing the cmcalibrate steps are listed in
# the 'M4' instruction section below, command lines are prefixed with
# '##'.
# 
# After executing the commands below the 8 CM files we'll use for
# testing will be in the current working directory and will be named:
#
# M1: RF00001.rfam11.i1p0.cm
#     GPIPE.29.rfam11.i1p0.cm
#
# M2: RF00001.rfam11.i1p1.cm
#     GPIPE.29.rfam11.i1p1.cm
#
# M3: RF00001.rfam12.1p1.cm
#     GPIPE.29.rfam12.1p1.cm
#
# M4: RF00001.rfam12.i1p0.cm
#     GPIPE.29.rfam12.i1p0.cm
#
#####################################################
# M1. Rfam 11.0 models in Infernal 1.0 format 
#     We already have these in /panfs/pan1.be-md.ncbi.nlm.nih.gov/gpipe/ThirdParty/ExternalData/Rfam/11.0/,
#     just copy them here:
cp /panfs/pan1.be-md.ncbi.nlm.nih.gov/gpipe/ThirdParty/ExternalData/Rfam/11.0/RF0001.cm ./RF00001.rfam11.i1p0.cm
cp /panfs/pan1.be-md.ncbi.nlm.nih.gov/gpipe/ThirdParty/ExternalData/Rfam/11.0/Rfam.selected1.cm ./GPIPE.29.rfam11.i1p0.cm 
# 
#####################################################
# M2. Rfam 11.0 models in Infernal 1.1 format 
#     Use cmconvert from Infernal 1.1.1 to convert the M1 models to 1.1 format, with the commands:
#
/usr/local/infernal/1.1.1/bin/cmconvert /panfs/pan1.be-md.ncbi.nlm.nih.gov/gpipe/ThirdParty/ExternalData/Rfam/11.0/RF0001.cm > ./RF00001.rfam11.i1p1.cm
/usr/local/infernal/1.1.1/bin/cmconvert /panfs/pan1.be-md.ncbi.nlm.nih.gov/gpipe/ThirdParty/ExternalData/Rfam/11.0/Rfam.selected1.cm > ./GPIPE.29.rfam11.i1p1.cm
#
#####################################################
# M3. Rfam 12.0 models in Infernal 1.1 format: 
#     Download the file Rfam.cm.gz from Rfam 12.0 and gunzip it:
#      
wget ftp://ftp.ebi.ac.uk/pub/databases/Rfam/12.0/Rfam.cm.gz
gunzip Rfam.cm.gz
#
#     Use cmfetch to fetch the required models:
#     It's important to do this using the accessions, not the model names, because one model 
#     (RF00113) changed names from QUAD to SIB_RNA between Rfam 11.0 and Rfam 12.0.
#      
#     Getting the accessions:
/usr/local/infernal/1.1.1/bin/cmstat /home/nawrocke/db/rfam/rfam_11.0/GPIPE.29.rfam11.i1p1.cm | grep -v ^\# | awk '{ print $3 }' > 29.list
/usr/local/infernal/1.1.1/bin/cmfetch -f Rfam.cm 29.list > GPIPE.29.rfam12.i1p1.cm 
#     
#     And get 5S_rRNA:
/usr/local/infernal/1.1.1/bin/cmfetch Rfam.cm RF00001 > RF00001.rfam12.i1p1.cm
#
#     Clean up from this step:
rm 29.list
rm Rfam.cm
#####################################################
# M4. Rfam 12.0 models in Infernal 1.0 format
#     To save time, just copy these CM files from my home directory:
cp /home/nawrocke/db/rfam/rfam_12.0/RF00001.rfam12.i1p0.cm ./
cp /home/nawrocke/db/rfam/rfam_12.0/GPIPE.29.rfam12.i1p0.cm ./
#
#     This saves time because those files required an expensive
#     'cmcalibrate' command using Infernal 1.0. 
#
#     To reproduce that calibration, execute the commands below
#     prefixed with '##'     
#
#     Use cmconvert from Infernal 1.1.1 to convert the M3 models to 1.0 format, with the commands
#
##/usr/local/infernal/1.1.1/bin/cmconvert -1 ./GPIPE.29.rfam12.i1p1.cm > ./GPIPE.29.rfam12.i1p0.cm
##/usr/local/infernal/1.1.1/bin/cmconvert -1 ./RF00001.rfam12.i1p1.cm > ./RF00001.rfam12.i1p0.cm
#  
#     Then it is necessary to 'calibrate' these models before we can use cmsearch
#     We do this using the cmcalibrate program from Infernal 1.0.
#     It takes about 110 CPU hours total. To save time it's best to separate 
#     the GPIPE.29.rfam12.i1p0.cm file into 29 separate CM files:
##mkdir indi-cm-files
##cd indi-cm-files
##perl /home/nawrocke/src/infernal-1.0/scripts/src/infernal-1.0/cm_multi2indi.pl ../GPIPE.29.rfam12.i1p0.cm 
##cp ../RF00001.rfam12.i1p0.cm ./
##sh ../step1-helper-qsub-calibrate.sh
#
#     Wait until all jobs are finished.
#     Copy 5S_rRNA up one dir:
##mv RF00001.rfam12.i1p0.cm ../
#
#     Then concatenate the 29 calibrated CM files back together:
##sh ../step1-helper-concatenate-cms.sh
#      
#     This creates the file ./GPIPE.29.rfam12.i1p0.cm
#
# End of Step 1
#############################
#############################
# 
# Step 2: obtain a mapping from Rfam names to accessions for both Rfam11 and Rfam12.
# 
# cmsearch v1.0 tabfile output does not include Rfam accessions, but we need them to 
# compare the 1.0 and 1.1 results, so we create a file that gives the accession for
# each Rfam family. The reason we can't compare Rfam 11.0 and 12.0 results using
# Rfam family names is because one of them changed between 11.0 and 12.0: 
# QUAD changed to SIB_RNA (RF00113).
#
cat RF00001.rfam11.i1p1.cm GPIPE.29.rfam11.i1p1.cm | /usr/local/infernal/1.1.1/bin/cmstat - | grep -v ^\# | awk '{ printf("%s %s\n", $2, $3)}' > rfam11.name2accn
cat RF00001.rfam12.i1p1.cm GPIPE.29.rfam12.i1p1.cm | /usr/local/infernal/1.1.1/bin/cmstat - | grep -v ^\# | awk '{ printf("%s %s\n", $2, $3)}' > rfam12.name2accn
