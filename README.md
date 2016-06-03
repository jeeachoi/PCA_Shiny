# PCA_Shiny

R/shiny app for PCA (including projected PCA)

## 1. Installation
This app requires the following packages: EBSeq <!--- ... -->

To install the shiny packages, in R run: 

> install.packages("shiny")

> install.packages("shinyFiles")

> source("http://bioconductor.org/biocLite.R")

> biocLite("EBSeq")

Or install locally.

### Run the app
To launch GUI, in R run:

> library(shiny)

> runGitHub('jeeachoi/PCA_Shiny')

![Screenshot](https://github.com/jeeachoi/PCA_Shiny/blob/master/figs/pcavisual2.png)

## 2. Input files

The first input file should be the expression matrix. 
Rows are the genes and columns are the samples/cells. Row names and column names are required in the input file.
Currently the program only takes csv files or tab delimited file.
The input file will be treated as a tab delimited file if the suffix is not '.csv'.
For the "Projected PCA", this entry of input data file will be used as the 'reference file' (e.g. Bulk RNA-seq) - the program will calculate PCs using this data set and project the next file on these PCs.

The second input file is needed only if a user wants to perform projected PCA. If projected PCA is specified, the script will generate PCs using the data file from the first file (e.g. Bulk RNA-seq), and generate projected PCA plots for the second data (e.g. scRNA-seq). Note that when calculating PCs from the first file, only the common genes in both files are used.


### Example files
Example input files for PCA: **PCA_example.csv** and example input files for projected PCA: **BulkRNA_Mat.csv**, **scRNA_Mat.csv** could be found at https://github.com/jeeachoi/PCA_Shiny/tree/master/example_data   

## 3. Customize options

- Need normalization? If Yes, Median-by-ratio normalization will be performed. If the input matrix is normalized (e.g. by median-by-ratio normalization or TMM), this option should be disabled. In addition, if the input expression matrix only contains a small set of genes, it is suggested to normalize using all genes first before taking the subset.
- Adjust outlier? If Yes, values <= 5 th quantile (>= 95 th quantile) will be pushed to 5 th quantile (95 th quantile). 
- Lower limit of detection threshold? Default is 0. Genes with max expression below this threshold will be removed. 
- Projected PCA? If Yes, PCs will be generated using the first input file, and projected PCA plots will be generated for the second input file.
- Number of PCs to output? (define it as k, default k = 5).
- Plot biplot (biplot shows genes with samples together)? If Yes, biplot will be generated. Nor recommended if the number of samples and genes are large.
- Plot scree plot (variance explained plot)? 
- Output directory, will be set as home directory (~/) if it is empty.
- 1. Output file name for biplot (pdf)
- 2. Output file name for scree plot (pdf)
- 3. Output file name for pairwise transformed data plot (pdf)
- 4. Output file name for percentage of SD explained by each PC (csv)
- 5. Output file name for gene loading for the top k PCs (csv)
- 6. Output file name for sorted gene loading for the top k PCs (for each of the top k PCs, genes are sorted by their absolute loadings in each PC)
- 7. Output file name for input parameters (txt) 
- If projected PCA is performed, output 4-6 is obtained using the first input file

## 4. Outputs
One to three pdf files and three csv files will be generated:
- Biplot.pdf: This file will be generated only when the user choose to plot biplot. Biplot maps a data matrix by plotting both the rows and columns in the same figure. Here the genes are arrows and samples/cells are points.
- Screeplot.pdf: This file will be generated only when the user chooses to plot scree plot. The x-axis shows the number of PCs and y-axis shows variance explained. 
- TransformedData_Plot.pdf: The pairwise plot between k PCs are shown.
- Gene_loading.csv: Gene loading for the top k PCs are shown.
- SortedGene_loadings.csv: For each of the top k PCs, genes are sorted by their absolute loadings in each PC.
- Variance_explained.csv: Percentage of SD explained by each PC.
- PCA_info.txt: This file contains all input parameters.
## Note
The 'create new folder' button in the output folder selection pop-up is disfunctional right now



