#!/bin/bash
#SBATCH --job-name=postProcessVCF
#SBATCH --partition=batch
#SBATCH --account=tassimes
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=8gb
#SBATCH --time=12:00:00
#SBATCH --output=/tmp/chr%a.dose.liftover_hg19.no_chr_prefix-job%A.out
#SBATCH --error=/tmp/chr%a.dose.liftover_hg19.no_chr_prefix-job%A.log
#SBATCH --array=1-23%8

# Perform adjustments on VCF file to adequate to expected format during GRS calculation
# Modified by Rodrigo Guarischi Sousa on May 3, 2022
# version 0.2

# NOTE: Limit to 8 parallel jobs to avoid going over the limit on disk quota 

### PREAMBLE ###################################################################################### 

# Settings for environment

# Load required modules
module load tabix

### FUNCTIONS #####################################################################################

### DATA ANALYSIS #################################################################################

while getopts ":r:" opt; do
    case ${opt} in
        r)
            race=${OPTARG}
            ;;
        h)
            usage
            ;;
        *)
	    echo -e "\n ERROR: Invalid parameters -${OPTARG}" >&2;
            usage
            ;;
        esac
    done
    shift $((OPTIND-1))


# Checks if an race option has being provided
if [ -z "${race}" ]; then
    echo -e "\n ERROR: A race must be provided and equals to 'whites' OR 'blacks'" >&2;
    usage
fi

# Checks if an race option is valid (equals 'whites' OR 'blacks')
if [ "${race}" != "whites" ] && [ "${race}" != "blacks" ]; then
    echo -e "\n ERROR: A race must be provided and equals to 'whites' OR 'blacks'" >&2;
    usage
fi

# Define root directory for processing
cd "/labs/tassimes/rodrigoguarischi/projects/sea/imputed_data/topmed/${race}/liftover_hg19/"

# Get current chromosome ID from slurm array (When array=23, process X chromosome)
if [ ${SLURM_ARRAY_TASK_ID} -eq 23 ]; then
  current_chr="X";
else
  current_chr=${SLURM_ARRAY_TASK_ID};
fi;

# Variables with input/output filenames
vcf_file="chr${current_chr}.dose.liftover_hg19.vcf.gz"
output_vcf_filename="chr${current_chr}.dose.liftover_hg19.no_chr_prefix.vcf"

# Edit VCF header (filter other contigs from the header; subset the first 1000 lines to speed up processing)
zcat ${vcf_file} | \
  head -n 1000 | \
  grep "^#" | \
  perl -pe "s/ID=chr/ID=/" | \
  awk -v chr="contig=<ID=${current_chr}," '$0 ~ chr || $0 !~ /contig/' > ${output_vcf_filename}

# Edit body (remove 'chr' prefix and exclude SNPs in other chromosomes)
zcat ${vcf_file} | \
  grep -v "^#" | \
  grep -P "^chr${current_chr}\t" | \
  perl -pe "s/^chr//" >> ${output_vcf_filename}

# Compress files as bzip
bgzip ${output_vcf_filename}

# Copy log and out files from /tmp to liftover folder
cp /tmp/chr${SLURM_ARRAY_TASK_ID}.dose.liftover_hg19.no_chr_prefix-job${SLURM_ARRAY_JOB_ID}.out .
cp /tmp/chr${SLURM_ARRAY_TASK_ID}.dose.liftover_hg19.no_chr_prefix-job${SLURM_ARRAY_JOB_ID}.log .