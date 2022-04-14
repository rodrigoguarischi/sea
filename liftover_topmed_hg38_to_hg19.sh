#!/bin/bash
#SBATCH --job-name=VCFliftOverHg38Hg19
#SBATCH --partition=batch
#SBATCH --account=tassimes
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=80gb
#SBATCH --time=12:00:00
#SBATCH --output=/labs/tassimes/rodrigoguarischi/projects/sea/imputed_data/topmed/liftover_hg19/chr%a.dose.liftover_hg19-%A.out
#SBATCH --error=/labs/tassimes/rodrigoguarischi/projects/sea/imputed_data/topmed/liftover_hg19/chr%a.dose.liftover_hg19-%A.log
#SBATCH --array=1-23

# Load required modules
module load picard

# Define root directory for processing
cd "/labs/tassimes/rodrigoguarischi/projects/sea/imputed_data/topmed/"

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
  CHAIN=../../aux_files/hg38ToHg19.over.chain.gz \
  R=../../aux_files/hg19.sorted.fa.gz \
  I=chr${current_chr}.dose.vcf.gz \
  O=./liftover_hg19/chr${current_chr}.dose.liftover_hg19.vcf.gz \
  REJECT=./liftover_hg19/chr${current_chr}.dose.liftover_hg19.rejected.vcf.gz \
  MAX_RECORDS_IN_RAM=100000
