#!/bin/bash

# Process SEA array data (Perlegen): Data preparation and imputation
# Project detail: https://www.ncbi.nlm.nih.gov/projects/gap/cgi-bin/study.cgi?study_id=phs000349.v1.p1
# Modified by Rodrigo Guarischi Sousa on Fev 9, 2022
# version 0.1

### PREAMBLE ###################################################################################### 

# Settings for environment 

# Load required modules
module load plink bcftools picard tabix seqkit

### FUNCTIONS #####################################################################################

# Take a vcf file as input and creates a subfolder with '_chr_split' sufix and writes a VCFs file 
# for each chromosome
split_vcf_by_chr() {

  vcf_file="$1";
  vcf_file_bn=$(basename $(basename ${vcf_file} .gz) .vcf);
  vcf_file_path=$(dirname ${vcf_file});

  chr_list=$(zcat -f ${vcf_file} | grep -v "#" | cut -f 1 | sort | uniq);

  mkdir -p ${vcf_file_path}/${vcf_file_bn}_chr_split;

  for chr_n in ${chr_list}; do
    bcftools filter -r ${chr_n} ${vcf_file} | bgzip > ${vcf_file_path}/${vcf_file_bn}_chr_split/${vcf_file_bn}.${chr_n}.vcf.gz;
  done;
}

### DATA ANALYSIS #################################################################################

# Base dir for all files in the project
base_dir='/labs/tassimes/rodrigoguarischi/projects/sea';

## Locate and prepare input SEA files
sea_input_files_path="/labs/tassimes/elyas/SEA"; 
sea_input_files_local="${base_dir}/raw_files";

mkdir -p "${sea_input_files_local}";

# Create symbolic link to the folder under /labs/tassimes/elyas/SEA/ 
ln -s ${sea_input_files_path} ${sea_input_files_local}/

# And a direct link for the most raw/important ones for SEA (the oldest 7 inside /labs/tassimes/elyas/SEA/)
for file in $(\ls -atr ${sea_input_files_path} | head -n 7); do 
  ln -s ${sea_input_files_path}/${file} ${sea_input_files_local};
done

## Data prepation
sea_processed_files="${base_dir}/processed_files";

# Create output directory to store processed files
mkdir -p ${sea_processed_files};

# Convert ped/map files to VCF files (vcf-iid for using only individual id)
plink \
  --recode vcf-iid \
  --ped ${sea_input_files_local}/SEA_Phase2.ped \
  --map ${sea_input_files_local}/SEA_Phase2.map \
  --out ${sea_processed_files}/SEA_Phase2

## Liftover
# SEA chips are based on NCBI36/hg18, in order to run imputation VCF files need to be 
# overlifted to hg19 (Michigan Imputation Server) and hg38 (TOPMed Imputation Server) 
aux_files="${base_dir}/aux_files";

mkdir -p ${aux_files}

# Reference fasta file for target builds hg19 and hg38 used by Picard
wget "https://hgdownload.soe.ucsc.edu/goldenPath/hg19/bigZips/hg19.fa.gz" -P ${aux_files} 
wget "https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz" -P ${aux_files}

# Sort fasta in natural-order to keep a meaningful order on downstream files
seqkit sort -N -i -2 ${aux_files}/hg19.fa.gz | gzip > ${aux_files}/hg19.sorted.fa.gz;
seqkit sort -N -i -2 ${aux_files}/hg38.fa.gz | gzip > ${aux_files}/hg38.sorted.fa.gz;

# Files won't be used anymore, discard them
rm ${aux_files}/hg19.fa.gz ${aux_files}/hg38.fa.gz

# Chain files for hg19 and hg38 used by Picard
wget "http://hgdownload.soe.ucsc.edu/goldenPath/hg18/liftOver/hg18ToHg19.over.chain.gz" -P ${aux_files}
wget "http://hgdownload.soe.ucsc.edu/goldenPath/hg18/liftOver/hg18ToHg38.over.chain.gz" -P ${aux_files}

# Create a reference sequence dictionaries and sort dictionaries by chr names
picard CreateSequenceDictionary \
  R=${aux_files}/hg19.sorted.fa.gz 

picard CreateSequenceDictionary \
  R=${aux_files}/hg38.sorted.fa.gz 
  
# Liftover using picard LiftoverVcf (based on the UCSC tool)

# VCF has to be translated to UCSC chromosome nomenclature before conversion
# Fix header, at the same time, fix chromosome names on vcf by replacing 23 by X and 24 by Y
grep "^#" ${sea_processed_files}/SEA_Phase2.vcf | \
  perl -pe "s/contig=<ID=/contig=<ID=chr/" | \
  perl -pe "s/contig=<ID=chr23/contig=<ID=chrX/" | \
  perl -pe "s/contig=<ID=chr24/contig=<ID=chrY/" > ${sea_processed_files}/SEA_Phase2.ucsc_chr.vcf

# Fix the body and append it to the file
grep -v "^#" ${sea_processed_files}/SEA_Phase2.vcf | \
  perl -pe "s/^/chr/" | \
  perl -pe "s/^chr23/chrX/" | \
  perl -pe "s/^chr24/chrY/" >> ${sea_processed_files}/SEA_Phase2.ucsc_chr.vcf

# Perform liftover to hg19
picard LiftoverVcf \
  CHAIN=${aux_files}/hg18ToHg19.over.chain.gz \
  I=${sea_processed_files}/SEA_Phase2.ucsc_chr.vcf \
  O=${sea_processed_files}/SEA_Phase2.ucsc_chr.liftover_hg19.vcf.gz \
  R=${aux_files}/hg19.sorted.fa.gz \
  REJECT=${sea_processed_files}/SEA_Phase2.ucsc_chr.liftover_hg19_rejected.vcf.gz

# Perform liftover to hg38
picard LiftoverVcf \
  CHAIN=${aux_files}/hg18ToHg38.over.chain.gz \
  I=${sea_processed_files}/SEA_Phase2.ucsc_chr.vcf \
  O=${sea_processed_files}/SEA_Phase2.ucsc_chr.liftover_hg38.vcf.gz \
  R=${aux_files}/hg38.sorted.fa.gz \
  REJECT=${sea_processed_files}/SEA_Phase2.ucsc_chr.liftover_hg38_rejected.vcf.gz

# Split both VCF files by chromosome (necessary for imputation)
split_vcf_by_chr ${sea_processed_files}/SEA_Phase2.ucsc_chr.liftover_hg19.vcf.gz
split_vcf_by_chr ${sea_processed_files}/SEA_Phase2.ucsc_chr.liftover_hg38.vcf.gz


## Download imputed results from topmed imputation server
imputation_results_topmed="${base_dir}/imputed_genotypes/topmed";

# Create output dir and enters it
mkdir -p "${imputation_results_topmed}"

cd ${imputation_results_topmed};

# QC Report
curl -sL https://imputation.biodatacatalyst.nhlbi.nih.gov/get/492247/1474900a0a45cccb1b532538d415e11314ad8e702be879bb943f63dd20072b2e | bash

# QC Statistics
curl -sL https://imputation.biodatacatalyst.nhlbi.nih.gov/get/492251/f923edd679e2005ac784b889f2371ab4d9ff72da9e033a12c70e1369b64f9780 | bash

# Imputation Results
curl -sL https://imputation.biodatacatalyst.nhlbi.nih.gov/get/492253/48b9481701b499bd9f74da3704c39ea0f82aa3137cba2f70905eae1b06d1eb55 | bash

# Logs
curl -sL https://imputation.biodatacatalyst.nhlbi.nih.gov/get/492254/10831caaa29eae3d6696b35103d7782fb0d8d0e060544cb5abc520753ec0b966 | bash


##### OLD PRE PROCESSING #######

# ## Data prepation
# data_preparation_folder="${base_dir}/data_prepation"
# data_preparation_tools_folder="${base_dir}/data_prepation/tools";
# mkdir -p ${data_preparation_folder}
# mkdir -p ${data_preparation_tools_folder}
# cd ${data_preparation_tools_folder}
# 
# # Download Data Preparation tool (https://imputationserver.readthedocs.io/en/latest/prepare-your-data/)
# wget http://www.well.ox.ac.uk/~wrayner/tools/HRC-1000G-check-bim-v4.2.7.zip
# wget ftp://ngs.sanger.ac.uk/production/hrc/HRC.r1-1/HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz
# 
# # Extract files
# unzip HRC-1000G-check-bim-v4.2.7.zip
# gunzip HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz
# 
# # Output folder for prepared files
# sea_prepared_files_folder="${base_dir}/data_prepation/sea_prepared_files";
# mkdir -p ${sea_prepared_files_folder}
# cd ${sea_prepared_files_folder}
# 
# # Load plink module
# module load plink
# 
# # Convert ped/map to bed
# plink --file ${sea_input_files_local}/SEA_Phase2 --make-bed --out ${sea_prepared_files_folder}/SEA_Phase2.prepared
# 
# # Create a frequency file
# plink --freq --bfile ${sea_prepared_files_folder}/SEA_Phase2.prepared --out ${sea_prepared_files_folder}/SEA_Phase2.prepared.freq
# 
# # Execute script
# perl ${data_preparation_tools_folder}/HRC-1000G-check-bim.pl \
#   -b ${sea_prepared_files_folder}/SEA_Phase2.prepared*.bim \
#   -f ${sea_prepared_files_folder}/SEA_Phase2.prepared*.frq \
#   -h
# 
# sh ${sea_prepared_files_folder}/Run-plink.sh
#

# Use checkVCF to ensure that the VCF files are valid 

# python ${base_dir}/data_prepation/tools/checkVCF.py \
#   -r ${base_dir}/data_prepation/tools/hs37d5.fa \
#   -o ${base_dir}/SEA_Phase2.checkVCF.out \
#   ${base_dir}/SEA_Phase2.vcf.gz 
# 
# python ${base_dir}/data_prepation/tools/checkVCF.py \
#   -r ${base_dir}/tmp/hg17.fa \
#   -o ${base_dir}/tmp/SEA_Phase2.hg17_checkVCF.out \
#   ${base_dir}/SEA_Phase2.vcf.gz 

# python ${base_dir}/data_prepation/tools/checkVCF.py \
#   -r ${base_dir}/tmp/human_b36_male.fa \
#   -o ${base_dir}/tmp/SEA_Phase2.human_b36_male.out \
#   ${base_dir}/SEA_Phase2.vcf.gz 

# python ${base_dir}/data_prepation/tools/checkVCF.py \
#   -r ${base_dir}/tmp/human_g1k_v37.fasta \
#   -o ${base_dir}/tmp/SEA_Phase2.human_g1k_v37_checkVCF.out \
#   ${base_dir}/SEA_Phase2.vcf.gz 