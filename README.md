# Predicting atherosclerosis in youth using Polygenic Risk Scores

## History

### PDAY (https://doi.org/10.1001/jama.281.8.727)

PDAY was a quantitative, post-mortem study published in Fev/99 on JAMA

Objective: Document extent and severity of **atherosclerosis in adolescents and young adults** in the US

Study Design:

 - Autopsy study conducted between **Jun/87** and **Aug/94**
 - **2,876 subjects** between **15 and 34 years** of age who died of non-atherosclerotic causes (mostly trauma)
   - White subjects (48%) and Black subjects (52%)
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
   - White subjects (564; 53%) and Black subjects (504; 47%)
   - Men (848; 79%) and Women (220; 21%)
 - Genotyped with **Perlegen Sciences** microarrays
   - One of the first genome-wide arrays available
   - 106,285 SNPs on array (66,166 QC passed<sup>1</sup>)
 - Data available on dbGAP, project ID: phs000349.v1.p1 [[link](https://www.ncbi.nlm.nih.gov/projects/gap/cgi-bin/study.cgi?study_id=phs000349.v1.p1&phv=159038&phd=3526&pha=&pht=2191&phvf=&phdf=&phaf=&phtf=&dssp=1&consent=&temp=1)]
 
<sup>1.</sup>[Salfati E, Nandkeolyar S, et al. Susceptibility Loci for Clinical Coronary Artery Disease and Subclinical Coronary Atherosclerosis Throughout the Life-Course. Circ Cardiovasc Genet. 2015; PMID: 26417035](https://doi.org/10.1161/CIRCGENETICS.114.001071)

 ### Demographic and clinical characteristics

 Demographic and clinical characteristics of our study sample are provided in the table below (stratified by race)

 The matching on age, sex, and race as well as a case-control ratio of 1 to 2 are consistent with sampling procedures adopted by SEA. 
 Mean BMI as well as the mean and median proportion of surface area of the RCA involved with raised lesions was also similar between groups.  

 |                                               | White subjects | Black subjects |
 | --------------------------------------------- | :------------: | :------------: |
 | Number                                        | 564            | 504            | 
 | Sex (n, % of total)                           |                |                | 
 | &nbsp;&nbsp;&nbsp;&nbsp;Male                  | 436 (77.3%)    | 412 (81.7%)    |
 | &nbsp;&nbsp;&nbsp;&nbsp;Female                | 128 (22.7%)    | 92 (18.3%)     |
 | Age (mean, SD)                                | 26.7 (5.0)     | 27.5 (4.3)     |
 | BMI (mean, SD)                                | 25.3 (5.0)     | 25.1 (5.1)     |
 | Raised lesions in the RCA (n, percent)        |                |                |                                
 | &nbsp;&nbsp;&nbsp;&nbsp;Yes (cases)           | 181 (32.1%)    | 165 (32.7%)    |
 | &nbsp;&nbsp;&nbsp;&nbsp;No (controls)         | 383 (67.9%)    | 339 (67.3%)    |
 | % Surface area involved among cases           |                |                |
 | &nbsp;&nbsp;&nbsp;&nbsp;Mean (percent, SD)    | 12.7% (17.4%)  | 12.9% (18.4%)  |
 | &nbsp;&nbsp;&nbsp;&nbsp;Median (percent, IQR) | 5.0% (17.0)    | 4.3% (16.3)    |

Abbreviations: n = number, RCA, Right Coronary Artery; SD, Standard Deviation; IQR, Interquartile Range. 

## Hypothesis and Aims

Availability of **improved reference panels** (TOPMed r2) and more **advanced PRSs for CAD** (ie. metaGRS) enables significant improvements on **predicting atherosclerosis in youth** (early lesions)

### Specific goals:

 1. To **assess improvements** on the imputation quality of SEA data using the **new TOPMed reference panel**
 1. Evaluate **new PRS for CAD** (e.g., metaGRS and new LDPred (PGS 3356)) on predicting raised lesions and compare its performance with the approach of 49 SNPs used previously
 1. Because TOPMed and metaGRS are more ethnically diverse, we also would like to **assess the performance of PRSs for the black subpopulation within SEA.**
 1. **Extend analyses to causal risk factor analyses** such as hypertension and LDL whose PRSs have also substantially improved over the last 5 years

## Polygenic Risk Scores tested

We assessed one PGS for CAD and eight for traditional risk factors and highly related biomarkers showing the strongest correlation with their respective trait from recent large-scale multi-ancestry discovery and validation studies of PGSs (table below). We also recalculated and normalized the 49-SNP PGS derived from genome wide significant hits for CAD as of 2013 that we previously tested.

| GRS (links to [pgscatalog.org](https://www.pgscatalog.org/))                                                                                                | Trait abbreviation | Source GWAS Ancrestry | Source GWAS N individuals     | Development method               | Predictive performance in White subjects (or mostly white)<sup>*</sup> | Predictive performance in Black subjects<sup>*</sup> | Total Variants | Variants Used | Coverage |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------- | :----------------: | :-------------------: | :---------------------------: | :------------------------------: | :--------------------------------------------------------------------: | :--------------------------------------------------: | :------------: | :-----------: | :------: | 
| PGS003356<br>[ [info](https://www.pgscatalog.org/score/PGS003356/) / [files](https://ftp.ebi.ac.uk/pub/databases/spot/pgs/scores/PGS003356/ScoringFiles/) ] | CAD                | Multi-ancestry        | 1,165,690                     | LDpred                           | HR: 1.61                                                               | Not Available                                        | 2,324,683      | 2,311,334     | 99.43%   |
| PGS000889<br>[ [info](https://www.pgscatalog.org/score/PGS000889/) / [files](https://ftp.ebi.ac.uk/pub/databases/spot/pgs/scores/PGS000889/ScoringFiles/) ] | LDL                | Multi-ancestry        | 1,088,526                     | Pruning and Thresholding (P+T)   | R<sup>2</sup>: 0.13 to 0.158                                           | R<sup>2</sup>: 0.067 to 0.173                        | 9,009          | 8,749         | 97.11%   |
| PGS002133<br>[ [info](https://www.pgscatalog.org/score/PGS002133/) / [files](https://ftp.ebi.ac.uk/pub/databases/spot/pgs/scores/PGS002133/ScoringFiles/) ] | Fat %              | European              | 391,124                       | LDpred2 (bigsnpr)                | partial-r: 0.3256 to 0.3456                                            | partial-r: 0.153 to 0.1577                           | 995,419        | 991,179       | 99.57%   |
| PGS002161<br>[ [info](https://www.pgscatalog.org/score/PGS002161/) / [files](https://ftp.ebi.ac.uk/pub/databases/spot/pgs/scores/PGS002161/ScoringFiles/) ] | BMI                | European              | 391,124                       | LDpred2 (bigsnpr)                | partial-r: 0.3595 to 0.3698                                            | partial-r: 0.1573 to 0.2104                          | 990,022        | 985,849       | 99.58%   |
| PGS000667<br>[ [info](https://www.pgscatalog.org/score/PGS000667/) / [files](https://ftp.ebi.ac.uk/pub/databases/spot/pgs/scores/PGS000667/ScoringFiles/) ] | Lp(a)              | European              | 48,333                        | Significant variants             | HR: 1.06 to 1.45                                                       | R<sup>2</sup>: 0.038                                 | 43             | 41            | 95.35%   |
| PGS001351<br>[ [info](https://www.pgscatalog.org/score/PGS001351/) / [files](https://ftp.ebi.ac.uk/pub/databases/spot/pgs/scores/PGS001351/ScoringFiles/) ] | Ins                | European              | 151,013 + 95,002<sup>**</sup> | PRS-CS                           | R<sup>2</sup>: 0.095                                                   | R<sup>2</sup>: 0.028                                 | 1,025,098      | 1,020,204     | 99.52%   |
| PGS002197<br>[ [info](https://www.pgscatalog.org/score/PGS002197/) / [files](https://ftp.ebi.ac.uk/pub/databases/spot/pgs/scores/PGS002197/ScoringFiles/) ] | Trig               | European              | 391,124                       | LDpred2 (bigsnpr)                | partial-r: 0.3494 to 0.3655                                            | partial-r: 0.1521 to 0.1776                          | 731,035        | 728,113       | 99.60%   |
| PGS002026<br>[ [info](https://www.pgscatalog.org/score/PGS002026/) / [files](https://ftp.ebi.ac.uk/pub/databases/spot/pgs/scores/PGS002026/ScoringFiles/) ] | T2D                | European              | 391,124                       | LDpred2 (bigsnpr)                | partial-r: 0.0862 to 0.1304                                            | partial-r: 0.0806 to 0.1001                          | 830,783        | 827,256       | 99.58%   |
| PGS002009<br>[ [info](https://www.pgscatalog.org/score/PGS002009/) / [files](https://ftp.ebi.ac.uk/pub/databases/spot/pgs/scores/PGS002009/ScoringFiles/) ] | SBP                | European              | 391,124                       | Penalized regression (bigstatsr) | partial-r: 0.2197 to 0.2702                                            | partial-r: 0.104 to 0.1046                           | 68,449         | 68,141        | 99.55%   |

<sup>*</sup>Predictive performance in the reference study

<!-- | [PGS000018](https://www.pgscatalog.org/score/PGS000018/)     | CAD                | Multi-ancestry        | 382,026 + 3,000<sup>**</sup>  | metaGRS                          | HR: 1.706        -->
<!-- <sup>**</sup>Cohort sizes of Source of Variant Associations and Score Development, respectively -->

## Data processing

Data processing consisted of the following steps/workflows:

1. [data_preparation_to_imputation.ipynb](./data_preparation_to_imputation.ipynb)
1. [imputed_data_download.ipynb](./imputed_data_download.ipynb)
1. [imputed_data_qc.ipynb](./imputed_data_qc.ipynb)
1. [liftover_topmed_hg38_to_hg19.ipynb](./liftover_topmed_hg38_to_hg19.ipynb)
   1. Sbatch slurm script: [liftover_topmed_hg38_to_hg19.sh](./liftover_topmed_hg38_to_hg19.sh)
   1. Sbatch slurm script: [liftover_topmed_post_processing_vcf](./liftover_topmed_post_processing_vcf.sh)
1. [pca_analysis.ipynb](./pca_analysis.ipynb)
1. [apply_grs.ipynb](./apply_grs.ipynb)
1. [calculate_grs_odds_ratios_and_create_plots.ipynb](./calculate_grs_odds_ratios_and_create_plots.ipynb)

## Citation

If you use these results/scripts, please cite us as below (*Cite this repository* option is also available on the right side bar).

```
@article{Guarischi-Sousa_Contemporary_Polygenic_Scores_2023,
author = {Guarischi-Sousa, Rodrigo and Salfati, Elias and Kho, Pik Fang and Iyer, Kruthika Raman and Hilliard, Austin and David, Herrington and Tsao, Philip S. and Clarke, Shoa L. and Assimes, Themistocles L.},
doi = {10.1161/CIRCGEN.122.004047},
journal = {Circulation: Genomic and Precision Medicine},
title = {{Contemporary Polygenic Scores of Low-Density Lipoprotein Cholesterol and Coronary Artery Disease Predict Coronary Atherosclerosis in Adolescents and Young Adults}},
year = {2023},
URL = {https://www.ahajournals.org/doi/abs/10.1161/CIRCGEN.122.004047},
eprint = {https://www.ahajournals.org/doi/pdf/10.1161/CIRCGEN.122.004047}
}
```
