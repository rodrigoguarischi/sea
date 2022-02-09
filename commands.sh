#!/bin/bash

# Process SEA array data (Perlegen): Data preparation and imputation
# Project detail: https://www.ncbi.nlm.nih.gov/projects/gap/cgi-bin/study.cgi?study_id=phs000349.v1.p1
# Modified by Rodrigo Guarischi Sousa on Fev 9, 2022
# version 0.1

### PREAMBLE ###################################################################################### 

# Settings for environment 

# Load plink module
module load plink bcftools

### FUNCTIONS #####################################################################################

### DATA ANALYSIS #################################################################################

# Base dir for all files in the project
base_dir='/labs/tassimes/rodrigoguarischi';

## Locate and prepare input SEA files

# Create symbolic links to the input files from SEA (the oldest 21 inside /labs/tassimes/elyas/SEA/)
sea_input_files_path="/labs/tassimes/elyas/SEA"; 
sea_input_files_local="${base_dir}/sea_raw_files";

mkdir -p "${sea_input_files_local}";

for file in $(ls -atr ${sea_input_files_path} | head -n 21); do 
  ln -s ${sea_input_files_path}/${file} ${sea_input_files_local};
done

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

# Load plink module
module load plink bcftools

# Convert ped/map files to VCF files
plink --ped ${base_dir}/sea_raw_files/SEA_Phase2.ped --map ${base_dir}/sea_raw_files/SEA_Phase2.map --recode vcf --out ${base_dir}/SEA_Phase2

# Create a sorted vcf.gz file using BCFtools:
bcftools sort ${base_dir}/SEA_Phase2.vcf -Oz -o ${base_dir}/SEA_Phase2.vcf.gz

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

python ${base_dir}/data_prepation/tools/checkVCF.py \
  -r ${base_dir}/tmp/human_b36_male.fa \
  -o ${base_dir}/tmp/SEA_Phase2.human_b36_male.out \
  ${base_dir}/SEA_Phase2.vcf.gz 

python ${base_dir}/data_prepation/tools/checkVCF.py \
  -r ${base_dir}/tmp/human_g1k_v37.fasta \
  -o ${base_dir}/tmp/SEA_Phase2.human_g1k_v37_checkVCF.out \
  ${base_dir}/SEA_Phase2.vcf.gz 


#

module load picard 

wget "http://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz"
wget "http://hgdownload.soe.ucsc.edu/goldenPath/hg18/liftOver/hg18ToHg38.over.chain.gz"

picard CreateSequenceDictionary R=${base_dir}/hg38.fa O=${base_dir}/hg38.dict

###
picard LiftoverVcf I=${base_dir}/SEA_Phase2.chr_name_corrected.vcf O=${base_dir}/SEA_Phase2.lifted_overhg38.vcf CHAIN=${base_dir}/hg18ToHg38.over.chain REJECT=${base_dir}/SEA_Phase2.lifted_overhg38.rejected.vcf R=${base_dir}/hg38.fa

