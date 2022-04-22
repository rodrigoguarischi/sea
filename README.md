# Predicting atherosclerosis in youth using Polygenic Risk Scores

## History

### PDAY (https://doi.org/10.1001/jama.281.8.727)

PDAY was a quantitative, post-mortem study published in Fev/99 on JAMA

Objective: Document extent and severity of **atherosclerosis in adolescents and young adults** in the US

Study Design:

 - Autopsy study conducted between **Jun/87** and **Aug/94**
 - **2,876 subjects** between **15 and 34 years** of age who died of non-atherosclerotic causes (mostly trauma)
   - Whites (48%) and Blacks (52%)
   - Men (76%) and Women (24%)
 - Post-mortem quantitative assessment of lesions in their aorta and coronary arteries:
   - % surface area with **fatty streaks** and **fibrous plaques**

### SEA 
 
SEA study genotyped a subset of PDAY cohort

Objective: 
SNPs and the Extent of Atherosclerosis (**SEA**) was a **GWAS study** to identify genetic variants associated with premature atherosclerosis in PDAY cohort

Study Design:
 - Study conducted between **2006** and **2008**
 - **1,068 subjects**
   - Whites (564; 53%) and Blacks (504; 47%)
   - Men (848; 79%) and Women (220; 21%)
 - Genotyped with **Perlegen Sciences** microarrays
   - One of the first genome-wide arrays available
   - 106,285 SNPs on array (66,166 QC passed<sup>1</sup>)
 - Data available on dbGAP, project ID: phs000349.v1.p1 [[link](https://www.ncbi.nlm.nih.gov/projects/gap/cgi-bin/study.cgi?study_id=phs000349.v1.p1&phv=159038&phd=3526&pha=&pht=2191&phvf=&phdf=&phaf=&phtf=&dssp=1&consent=&temp=1)]


<sup>1.</sup>[Salfati E, Nandkeolyar S, et al. Susceptibility Loci for Clinical Coronary Artery Disease and Subclinical Coronary Atherosclerosis Throughout the Life-Course. Circ Cardiovasc Genet. 2015; PMID: 26417035](https://doi.org/10.1161/CIRCGENETICS.114.001071)

## Hypothesis and Aims

Availability of **improved reference panels** (TOPMed r2) and more **advanced PRSs for CAD** (ie. metaGRS) enables significant improvements on **predicting atherosclerosis in youth** (early lesions)

### Specific goals:

 1. To **assess improvements** on the imputation quality of SEA data using the **new TOPMed reference panel**
 1. Evaluate **metaGRS** on predicting raised lesions and compare its performance with the approach of 49 SNPs used previously
    - Expand this analysis by comparing the two PRSs to the recently developed (and not yet published) multi-ancestry PRS developed **within VA with MVP data**
 1. Because TOPMed and metaGRS are more ethnically diverse, we also would like to **assess the performance of PRSs for the black subpopulation within SEA.**
 1. **Extend analyses to causal risk factor analyses** such as hypertension and LDL whose PRSs have also substantially improved over the last 5 years

## Data processing

Data processing consisted of the following steps/workflows:

1. [data_preparation_to_imputation.ipynb](./data_preparation_to_imputation.ipynb)
1. [imputed_data_download.ipynb](./imputed_data_download.ipynb)
1. [imputed_data_qc.ipynb](./imputed_data_qc.ipynb)
1. [liftover_topmed_hg38_to_hg19.ipynb](./liftover_topmed_hg38_to_hg19.ipynb)
   1. Sbatch slurm script: [liftover_topmed_hg38_to_hg19.sh](./liftover_topmed_hg38_to_hg19.sh)
   1. Sbatch slurm script: [liftover_topmed_post_processing_vcf](./liftover_topmed_post_processing_vcf)
1. [apply_pgs_and_plot_odds_ratios.ipynb](./apply_pgs_and_plot_odds_ratios.ipynb)
