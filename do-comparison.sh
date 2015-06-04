# do-comparison.sh
#
# The second of two scripts for running tests of Infernal 1.0 versus
# Infernal 1.1.1 and Rfam 11.0 versus Rfam 12.0. The first script is
# 'do-searches.sh'. That script will submit 800 jobs to the cluster.
# Wait until they are all finished before running this script.
# 
# Step 5: Convert 1p0 --tabfile output to GFF format:
ls rfam11-i1p0/*.tbl > rfam11.i1p0.list
ls rfam12-i1p0/*.tbl > rfam12.i1p0.list
perl step5-convert-i1p0-to-gff.pl rfam11.name2accn rfam11.i1p0.list
perl step5-convert-i1p0-to-gff.pl rfam12.name2accn rfam12.i1p0.list

# Step 6: Convert 1p1 --tblout output to GFF format:
ls rfam11-i1p1/*.tbl > rfam11.i1p1.list
ls rfam12-i1p1/*.tbl > rfam12.i1p1.list
perl step6-convert-i1p1-to-gff.pl rfam11.i1p1.list 
perl step6-convert-i1p1-to-gff.pl rfam12.i1p1.list 

# Step 7: Concatenate and compare the results:
cat rfam11-i1p0/*gff > rfam11-i1p0.gff
cat rfam11-i1p1/*gff > rfam11-i1p1.gff
cat rfam12-i1p0/*gff > rfam12-i1p0.gff
cat rfam12-i1p1/*gff > rfam12-i1p1.gff
perl step7-compare-gff-i1p0-i1p1.pl rfam11-i1p0.gff rfam11-i1p1.gff rfam11 > rfam11-hit-comparison.txt
perl step7-compare-gff-i1p0-i1p1.pl rfam12-i1p0.gff rfam12-i1p1.gff rfam12 > rfam12-hit-comparison.txt

# Step 8: Process timings:
cat rfam11-i1p0/*.time | perl step8-process-times.pl > rfam11-i1p0.time
cat rfam11-i1p1/*.time | perl step8-process-times.pl > rfam11-i1p1.time
cat rfam12-i1p0/*.time | perl step8-process-times.pl > rfam12-i1p0.time
cat rfam12-i1p1/*.time | perl step8-process-times.pl > rfam12-i1p1.time

# Step 9: Compare timings:
perl step9-compare-timings.pl rfam11-i1p0.time rfam11-i1p1.time rfam12-i1p0.time rfam12-i1p1.time > time-comparison.txt

# Output results
echo "Outputting rfam11-hit-comparison.txt file:"
cat rfam11-hit-comparison.txt

echo "Outputting rfam12-hit-comparison.txt file:"
cat rfam12-hit-comparison.txt

echo "Outputting time-comparison.txt file:"
cat time-comparison.txt

