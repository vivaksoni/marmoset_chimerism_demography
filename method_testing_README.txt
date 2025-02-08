####CHIMERIC DEMOG SIMS####
#1. RUN sibs_monogamy.slim FOR CHIMERIC SIMULATIONS OF 4 DEMOG SCENARIOS. RUN EITHER wf.slim OR chimerism_msprime.ipynb TO RUN WF SIMULATIONS OF DEMOG SCENARIOS.

#2. GET 10 SAMPLES OF CHIMERAS, USING get_samples.py TO DO SO, THEN USE BCFTOOLS TO SUBSET VCF TO JUST TWIN-PAIRS.
demog=(expansion eq contraction bneck)
for d in "${demog[@]}"; do for i in $(seq 1 100); do python3 get_samples.py -pedigrees pedigreeIDs_rep"$i".txt -outFile rep"$i" -samples 10; done; done

for d in "${demog[@]}"; do for i in $(seq 1 100); do bcftools view -S rep"$i"_chimeric.txt --min-ac=1 rep"$i".vcf.gz | bgzip > rep"$i"_chimeric.vcf.gz; done; done


#3. PREPARE INPUT FILES FOR fastsimcoal2
demog=(expansion eq contraction bneck)

for d in "${demog[@]}"; do for i in $(seq 1 100); do python3 get_sfs_for_fsc.py -vcf_file rep"$i"_chimeric.vcf.gz \ 
-outFile ../fsc/ -region_length 1000000 -samples 20 -sample_type chimeric; done; done


#4. PREPARE INPUT FILES FOR dadi
for d in "${demog[@]}"; do for i in $(seq 1 100); do python3 get_sfs_for_dadi.py -vcf_file rep"$i"_chimeric.vcf.gz \ 
-outFile rep"$i"_chimeric.sfs -samples 20 -sample_type chimeric; done; done


#5. GENERATE SUMMARY STATISTICS
for d in "${demog[@]}"; do for i in $(seq 1 100); do python3 get_summary_statistics.py -inFile rep"$i"_chimeric.vcf.gz \
-outFile rep"$i"_chimeric.stats -samples 20 -win_size 10000 -step_size 5000 -regionLen 1000000; done; done
