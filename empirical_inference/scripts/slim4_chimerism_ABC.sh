#!/bin/bash

# have job exit if any command returns with non-zero exit status (aka failure)
set -e

# replace env-name on the right hand side of this line with the name of your conda environment
ENVNAME=env5

# if you need the environment directory to be named something other than the environment name, change this line
ENVDIR=$ENVNAME

# these lines handle setting up the environment; you shouldn't have to modify them
export PATH
mkdir $ENVDIR
tar -xzf $ENVNAME.tar.gz -C $ENVDIR
. $ENVDIR/bin/activate

# modify environment variables
export PATH=$_CONDOR_SCRATCH_DIR/build:$PATH

tar -zxf scripts.tar.gz

slim -d "d_paramID='$1'" -d "d_repID='$6'" -d "d_folder='.'" -d d_Nanc=$2 -d d_Nbot=$3 -d d_Tbot=$4 -d d_Ncurr=$5 -d "d_mu_map='scripts/mu_maps4/$6.txt'" -d "d_rr_map='scripts/rr_maps2/$6.txt'" scripts/empirical_demog_ABC.slim

python3 scripts/get_samples.py -pedigrees pedigreeIDs_$1_rep$6.txt -outFile $1_rep$6 -samples 15

vcftools --vcf $1_rep$6.vcf --keep $1_rep$6_chimeric.txt --out $1_rep$6_chimeric --recode

rm $1_rep$6.vcf
mv $1_rep$6_chimeric.recode.vcf $1_rep$6_chimeric.vcf

python3 scripts/get_summary_stats.py -inFile $1_rep$6_chimeric.vcf -outFile $1_rep$6_chimeric.stats -regionLen 1000000 -win_size 10000 -step_size 5000

mkdir slim2_$7
cp *.txt slim2_$7
cp *.vcf slim2_$7
cp *.stats slim2_$7
tar -czf slim2_$7.tar.gz slim2_$7
