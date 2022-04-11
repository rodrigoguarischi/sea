#!/bin/bash

# Process SEA array data (Perlegen): Data preparation and imputation
# Project detail: https://www.ncbi.nlm.nih.gov/projects/gap/cgi-bin/study.cgi?study_id=phs000349.v1.p1
# Modified by Rodrigo Guarischi Sousa on Fev 14, 2022
# version 0.2

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
  --keep-allele-order \
  --ped ${sea_input_files_local}/SEA_Phase2.ped \
  --map ${sea_input_files_local}/SEA_Phase2.map \
  --out ${sea_processed_files}/SEA_Phase2

# plink \
#   --recode vcf-iid \
#   01 \
#   --ped ${sea_input_files_local}/SEA_Phase2.ped \
#   --map ${sea_input_files_local}/SEA_Phase2.map \
#   --out ${sea_processed_files}/TOBEDELETED/SEA_Phase2_01



data_preparation_folder="${base_dir}/data_preparation";

mkdir -p "${data_preparation_folder}";

# wget "https://www.well.ox.ac.uk/~wrayner/tools/HRC-1000G-check-bim-v4.3.0.zip"
# wget "ftp://ngs.sanger.ac.uk/production/hrc/HRC.r1-1/HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz"

# curl 'https://bravo.sph.umich.edu/freeze5/hg38/download/all' -H 'Accept-Encoding: gzip, deflate, br' -H 'Cookie: _ga=GA1.2.645902790.1647474047; _gid=GA1.2.202243235.1647474047; remember_token="rodrigoguarischi@gmail.com|909ced69655877963deb6629019b538b23bceaa3e84cd5852d476b90791b8d6280347700271bcb59dd2d2aa97f36b25a65d00bbd2686a2d1595a83e6edc67536"; _gat_gtag_UA_73910830_2=1' --compressed > bravo-dbsnp-all.vcf.gz

perl HRC-1000G-check-bim.pl \
  -b ${data_preparation_folder}/sea/86679/NHLBI/SEA_Herrington/phs000349v1/p1/genotype/phg000121v1/genotype-calls-matrixfmt/SEA_Phase2.bim \
  -f ${data_preparation_folder}/sea/86679/NHLBI/SEA_Herrington/phs000349v1/p1/genotype/phg000121v1/genotype-qc/SEA_Phase2.frq \
  -r ${data_preparation_folder}/HRC.r1-1.GRCh37.wgs.mac5.sites.tab \
  -h 

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

# Imputation servers expect chromosomes encoded without prefix (e.g. 20) when imputing 
# an array on genome build hg19 (hg38 is the opposite). 
# Fix this encoding on VCFs the header
zcat ${sea_processed_files}/SEA_Phase2.ucsc_chr.liftover_hg19.vcf.gz | \
  grep "^#" | \
  perl -pe "s/contig=<ID=chr/contig=<ID=/" > ${sea_processed_files}/SEA_Phase2.chr_no_prefix.liftover_hg19.vcf

# Fix this encoding on VCF body and append it to the file
zcat ${sea_processed_files}/SEA_Phase2.ucsc_chr.liftover_hg19.vcf.gz | \
  grep -v "^#" | \
  perl -pe "s/^chr//" >> ${sea_processed_files}/SEA_Phase2.chr_no_prefix.liftover_hg19.vcf

# Compress VCF file and creates tbi index for it
bgzip ${sea_processed_files}/SEA_Phase2.chr_no_prefix.liftover_hg19.vcf
tabix -p vcf ${sea_processed_files}/SEA_Phase2.chr_no_prefix.liftover_hg19.vcf.gz

# Split both VCF files by chromosome (necessary for imputation)
split_vcf_by_chr ${sea_processed_files}/SEA_Phase2.chr_no_prefix.liftover_hg19.vcf.gz
split_vcf_by_chr ${sea_processed_files}/SEA_Phase2.ucsc_chr.liftover_hg38.vcf.gz

# # Quick analysis using VCF from Elias
# mkdir -p ${sea_processed_files}/starting_from_elias_vcf
# ln -s /labs/tassimes/elyas/SEA/SEA_Phase2.1kb37.vcf.gz
# split_vcf_by_chr ${sea_processed_files}/

# cd /labs/tassimes/rodrigoguarischi/projects/sea/imputed_genotypes/topmed/hg19_elias
# curl -sL https://imputation.biodatacatalyst.nhlbi.nih.gov/get/513702/0ab98a638f52fb3581ca7776f48a22cac5963407f7b005f64a6c87ce7954fd40 | bash
# curl -sL https://imputation.biodatacatalyst.nhlbi.nih.gov/get/513706/48ede0615fac0294afcb1a942571d17e1e8389b869d7fb3e9983342975626b30 | bash
# curl -sL https://imputation.biodatacatalyst.nhlbi.nih.gov/get/513709/1ca02aec9d221396789c1608be0b125efafaaa5b23722bb795790dddb92965ab | bash
# curl -sL https://imputation.biodatacatalyst.nhlbi.nih.gov/get/513708/b29d98f9db47e72e866014dc6f042c796a5e256b5b4c2d2cdfb8cd123c262a60 | bash

### Download imputed results based on TopMed reference panel from Topmed imputation server

# QC Report


# QC Statistics


# Imputation Results


# Logs


## Download imputed results based on HRC from Michigan Imputation Server (from hg38 liftover)
imputation_results_michigan="${base_dir}/imputed_genotypes/michigan_hrc";

# Create output dir and enters it
mkdir -p "${imputation_results_michigan}"

cd ${imputation_results_michigan};

# QC Report
# NOT AVAILABLE

# QC Statistics
curl -sL https://imputation.sph.umich.edu/get/2561281/3f62258a4149126497bf83e82b302787f2d69be6edb6a9d26986f7f0b9136779 | bash

# Imputation Results
curl -sL https://imputation.sph.umich.edu/get/2561283/2ced7c9f53b305674708f06426f20306985194b2b865f3b300ff1d1b9d96d27d | bash

# Logs
curl -sL https://imputation.sph.umich.edu/get/2561284/4478f5a8798cd2a1274d20a530a66118e4a2b7e183648c1906d787931d628b0b | bash


------------

### Download imputed results

## Based on TopMed reference panel on Topmed imputation server from hg19 liftover files
imputation_results_topmed_hg19="${base_dir}/imputed_genotypes/topmed/hg19";

# Create output dir and enters it
mkdir -p "${imputation_results_topmed_hg19}"

cd ${imputation_results_topmed_hg19};

# QC Report
curl -sL https://imputation.biodatacatalyst.nhlbi.nih.gov/get/501575/7398c2908412b5e3d28850d39a49232d73d27917a72c8788ccb520bb2a7c3a3e | bash

# QC Statistics
curl -sL https://imputation.biodatacatalyst.nhlbi.nih.gov/get/501579/7c3e5123ba2bcdd748f54d29c37cc237650a368cd240140cf30d0d26d205cd0e | bash

# Imputation Results
curl -sL https://imputation.biodatacatalyst.nhlbi.nih.gov/get/501581/26237f3572887f902b9bb65ddbdaaa84d30e57b61bb45bce5bea3d4c9edc0a3d | bash

# Logs
curl -sL https://imputation.biodatacatalyst.nhlbi.nih.gov/get/501582/654dcdddc5b36d1f546bc2e3bd112da679f293111e7882956330d4c8c5161e50 | bash

## Based on TopMed reference panel on Topmed imputation server from hg38 liftover files
imputation_results_topmed_hg38="${base_dir}/imputed_genotypes/topmed/hg38";

# Create output dir and enters it
mkdir -p "${imputation_results_topmed_hg38}"

cd ${imputation_results_topmed_hg38};

# QC Report
curl -sL https://imputation.biodatacatalyst.nhlbi.nih.gov/get/501553/ff6ff158e3799e09fc6e78b8f42c999e4ac328f13e1a8950c372912021165311 | bash

# QC Statistics
curl -sL https://imputation.biodatacatalyst.nhlbi.nih.gov/get/501557/698a99ac891f7e9842067dbdde8f3d036a3c7899fc22e2765e9f2fe27c3b3b54 | bash

# Imputation Results
curl -sL https://imputation.biodatacatalyst.nhlbi.nih.gov/get/501559/f76aab9ca988dced290a7a299256376a80b6934d554945e46b9c04f11ff5a5cf | bash

# Logs
curl -sL https://imputation.biodatacatalyst.nhlbi.nih.gov/get/501560/0dc88e01837f98116cfd3704cc9bc0083063542ddf9708145254773d72db1efe | bash

## Based on HRC reference panel on Michigan Imputation Server from hg19 liftover files
imputation_results_mis_hg19="${base_dir}/imputed_genotypes/michigan_hrc/hg19";

# Create output dir and enters it
mkdir -p "${imputation_results_mis_hg19}"

cd ${imputation_results_mis_hg19};

# QC Report
curl -sL https://imputationserver.sph.umich.edu/get/2603173/f8305f2c1c078ba1bb7509d64330b29cae993f81eec368fb7bc21c19764ee36a | bash

# QC Statistics
curl -sL https://imputationserver.sph.umich.edu/get/2603177/b27567d73d7d7ba8549dc89470a145b675d1b8e1b945ec83a9918080b0da7584 | bash

# Imputation Results
curl -sL https://imputationserver.sph.umich.edu/get/2603179/f3014e0faedf9f4c81d96559f56843841f9a1b2d1ae3803a7243a8e90fa0a070 | bash

# Logs
curl -sL https://imputationserver.sph.umich.edu/get/2603180/860cdb25905cc3d61a7c1a5f6116848ffc60829b5c6e56655702ef955e7bc1af | bash


## Based on HRC reference panel on Michigan Imputation Server from hg38 liftover files
imputation_results_mis_hg38="${base_dir}/imputed_genotypes/michigan_hrc/hg38";

# Create output dir and enters it
mkdir -p "${imputation_results_mis_hg38}"

cd ${imputation_results_mis_hg38};

# QC Report
curl -sL https://imputationserver.sph.umich.edu/get/2603152/999ba11604b1683dcc911ac4b1f41c1a0998d1d24ec9578a97b22e0d3e53dc6a | bash

# QC Statistics
curl -sL https://imputationserver.sph.umich.edu/get/2603156/47da827ec172e031ab9f3d7552019b02c9490aece12640fa3441b95a8bc82ef4 | bash

# Imputation Results
curl -sL https://imputationserver.sph.umich.edu/get/2603158/fa810c821278639306b1ff0b6264e5577f849c739b69dd45d600b92c7a91c43f | bash

# Logs
curl -sL https://imputationserver.sph.umich.edu/get/2603159/1a249e3bc59bfea4515c1f318f2e5259f403195b715b430f733068874fa7a9c8 | bash