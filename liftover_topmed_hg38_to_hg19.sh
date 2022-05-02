#!/bin/bash
#SBATCH --job-name=VCFliftOverHg38Hg19
#SBATCH --partition=batch
#SBATCH --account=tassimes
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=80gb
#SBATCH --time=12:00:00
#SBATCH --output=./liftover_hg19/chr%a.dose.liftover_hg19-%A.out
#SBATCH --error=./liftover_hg19/chr%a.dose.liftover_hg19-%A.log
#SBATCH --array=1-23

# Launch picard to liftover hg38 to hg19 for all VCF files with imputation data
# Modified by Rodrigo Guarischi Sousa on May 2, 2022
# version 0.2

### PREAMBLE ###################################################################################### 

# Settings for environment

# Load required modules
module load picard

### FUNCTIONS #####################################################################################

usage() { 
    message="\n";
    message+=" Usage: liftover_topmed_hg38_to_hg19.sh -r [whites|blacks]\n\n";
    message+=" Options:\n";
    message+=" \t-r\tRace option (whites OR blacks) is required\n";
    echo -e "${message}" >&2;
    exit 1;
    }

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
cd "/labs/tassimes/rodrigoguarischi/projects/sea/imputed_data/topmed/${race}"

# Create a subfolder directory to save output (in case it doesn't exist yet)
mkdir -p "./liftover_hg19/"

# Get current chromosome ID from slurm array (When array=23, process X chromosome)
if [ ${SLURM_ARRAY_TASK_ID} -eq 23 ]; then
  current_chr="X";
else
  current_chr=${SLURM_ARRAY_TASK_ID};
fi;

# Run liftover hg38 > hg19 using picard LiftOverVcf
picard LiftoverVcf \
  CHAIN=../../../aux_files/hg38ToHg19.over.chain.gz \
  R=../../../aux_files/hg19.sorted.fa.gz \
  I=chr${current_chr}.dose.vcf.gz \
  O=./liftover_hg19/chr${current_chr}.dose.liftover_hg19.vcf.gz \
  REJECT=./liftover_hg19/chr${current_chr}.dose.liftover_hg19.rejected.vcf.gz \
  MAX_RECORDS_IN_RAM=50000