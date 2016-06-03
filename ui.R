library(shiny)
library(shinyFiles)
#library(gdata)
options(shiny.maxRequestSize=500*1024^2) 
# Define UI for slider demo application
shinyUI(pageWithSidebar(
  #  Application title
  headerPanel("PCA (projected)"),
  
  # Sidebar with sliders that demonstrate various available options
  sidebarPanel(width=12,height=20,
               # file
               fileInput("filename1", label = "File input (support .csv, .txt, .tab). For projected PCA, this file will be used as a reference"),
               
               # grouping vector
               fileInput("filename2", label = "File input (support .csv, .txt, .tab). For projected PCA, PCs will be generated using the previous file and this data will be projected on."),
               
               column(4,
		          # Normalization
		          radioButtons("Norm_button",
                                label = "Do you need normalization?",
                                choices = list("Yes" = 1,
                                               "No" = 2),
                                selected = 2),
		          # Outlier
		          radioButtons("OL_whether",
                                label = "Do you want to adjust outlier (top/bottom 5%)?",
                                choices = list("Yes" = 1,
                                               "No" = 2),
                                selected = 2),
		          numericInput("LOD",
                                label = "Lower limit of detection (max value)",
                                               value = 10),							
				  # num of PC (k)
				  numericInput("numk",
				               label = "The number of PCs to output (k)",
				               value = 5),
				  # Projected?
				  radioButtons("proj_button",
				               label = "Do you want projected PCA?",
				               choices = list("Yes" = 1,
				                              "No" = 2),
				               selected = 2)
				  ),
               
               column(width=4,
                                      # For heatmap:
                     radioButtons("biplot_button",
                                  label = "Do you want to plot a biplot?",
                                  choices = list("Yes" = 1,
                                                 "No" = 2),
                                  selected = 1),
                      # For heatmap:
                     radioButtons("screeplot_button",
                                  label = "Do you want to plot a scree plot?",
                                  choices = list("Yes" = 1,
                                               "No" = 2),
                                  selected = 1),
                     br(),
                     # output dir
                     shinyDirButton('Outdir', 'output folder select', 'Please select a folder'),
                     br(),
                     br(),
                     
                      # plot name
                      textInput("BiplotName", 
                                label = "Export file name for the Biplot?", 
                                value = "Biplot"),
                      
                      textInput("ScreeplotName", 
                                label = "Export file name for the Scree plot?", 
                                value = "Screeplot")
                      
               ),
               
               column(width=4,                          
                      # plot name
                      textInput("TrdataplotName", 
                                label = "Export file name for pairwise transformed data plot?", 
                                value = "TransformedData_Plot"),
                      textInput("VarExpName", 
                                label = "Export file name for percentage of SD explained by each PC", 
                                value = "Variance_explained"),
                      textInput("LoadingName", 
                                label = "Export file name for gene loading for the top k PCs", 
                                value = "Gene_loadings"),
                      textInput("SortLoadingName", 
                                label = "Export file name for sorted gene loading for the top k PCs", 
                                value = "SortedGene_loadings"),
                      textInput("InfoFileName", 
                                label = "Export file name - input parameters and version info", 
                                value = "PCA_info")
               ),

			          br(),
               actionButton("Submit","Submit for processing")
  ),
  
  # Show a table summarizing the values entered
  mainPanel(
    h4(textOutput("print0")),
    #tableOutput("values")
    dataTableOutput("tab")
  )
))
