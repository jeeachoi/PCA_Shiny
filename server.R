library(shiny)
library(shinyFiles)
library(EBSeq)

# Define server logic for slider examples
shinyServer(function(input, output, session) {
  volumes <- c('home'="~")
  shinyDirChoose(input, 'Outdir', roots=volumes, session=session, restrictions=system.file(package='base'))
  output$Dir <- renderPrint({parseDirPath(volumes, input$Outdir)})
  
  
  In <- reactive({
    print(input$Outdir)
    #outdir <- paste0("~", input$Outdir[[1]][[2]], "/")
    outdir <- paste0("~",do.call("file.path",input$Outdir[[1]]),"/")
    print(outdir)
    
    the.file1 <- input$filename1$name
    if(is.null(the.file1))stop("Please upload data")
    Sep=strsplit(the.file1,split="\\.")[[1]]
    if(Sep[length(Sep)]=="csv")a1=read.csv(input$filename1$datapath,stringsAsFactors=F,header=TRUE, row.names=1)
    if(Sep[length(Sep)]!="csv")a1=read.table(input$filename1$datapath,stringsAsFactors=F,header=TRUE, row.names=1)
    Data=data.matrix(a1)
    
    the.file2 <- input$filename2$name
    if(!is.null(the.file2)){
      Sep=strsplit(the.file2,split="\\.")[[1]]
      if(Sep[length(Sep)]=="csv")a2=read.csv(input$filename2$datapath,stringsAsFactors=F,header=TRUE, row.names=1)
      if(Sep[length(Sep)]!="csv")a2=read.table(input$filename2$datapath,stringsAsFactors=F,header=TRUE, row.names=1)
      scData=data.matrix(a2)
    }      
      Group.file <- input$filename3$name
      if(is.null(Group.file))GroupVIn = list(c1=rep(1,ncol(Data)))
      if(!is.null(Group.file)){
        Group.Sep=strsplit(Group.file,split="\\.")[[1]]
        if(Group.Sep[length(Group.Sep)]=="csv")GroupVIn=read.csv(input$filename3$datapath,stringsAsFactors=F,header=F)
        if(Group.Sep[length(Group.Sep)]!="csv")GroupVIn=read.table(input$filename3$datapath,stringsAsFactors=F,header=F, sep="\t")
      }
      GroupV=GroupVIn[[1]]
      
    # Compose data frame
    #input$filename$name
    List <- list(
      Input1=the.file1,
      Input2=the.file2,
      NormTF = ifelse(input$Norm_button=="1",TRUE,FALSE),
      OLTF = ifelse(input$OL_whether=="1",TRUE,FALSE),
	  LODNum = input$LOD,
	  Numk = input$numk,
      
	  ProjTF = ifelse(input$proj_button=="1",TRUE,FALSE),
      BiplotTF=ifelse(input$biplot_button=="1",TRUE,FALSE), 
      ScreeplotTF=ifelse(input$screeplot_button=="1",TRUE,FALSE), 
	    ColplotTF=ifelse(input$color_button=="1",TRUE,FALSE), 
   	  Dir=outdir, 
	  BiPlot = paste0(outdir, input$BiplotName,".pdf"),
      ScreePlot = paste0(outdir,input$ScreeplotName,".pdf"),
	  
      TrDataPlot = paste0(outdir,input$TrdataplotName,".pdf"),    
      VarExp = paste0(outdir,input$VarExpName,".csv"),    
      Loading = paste0(outdir,input$LoadingName,".csv"),    
      SortedLoading = paste0(outdir,input$SortLoadingName,".csv"),
    Info = paste0(outdir,input$InfoFileName,".txt")
    )
	if(List$ProjTF==FALSE){
	  if(length(GroupV)!=ncol(Data)) stop("Length of the condition vector is not the same as the number of samples!")
	}  
  if(List$ProjTF==TRUE&List$ColplotTF==TRUE){
      if(length(GroupV)!=ncol(scData)) stop("Length of the condition vector is not the same as the number of samples!")
  }  
  Maxbk=apply(Data,1,max)
	WhichbkRM=which(Maxbk<List$LODNum)
    print(paste(length(WhichbkRM),"File1: genes with max expression < ", List$LODNum, "are removed"))
	Matbk=Data
    if(length(WhichbkRM)>0)Matbk=Data[-WhichbkRM,]
    print(str(Matbk))

    if(List$ProjTF){
		Maxsc=apply(scData,1,max)
		WhichscRM=which(Maxsc<List$LODNum)
	    print(paste(length(WhichscRM),"File2: genes with max expression < ", List$LODNum, "are removed"))
		Matsc=scData
	    if(length(WhichscRM)>0)Matsc=scData[-WhichscRM,]
	    print(str(Matsc))
    }
	# normalization     
    if(List$NormTF){
    Sizes <- MedianNorm(Matbk)
    if(is.na(Sizes[1])){
      Sizes <- MedianNorm(Matbk, alternative=TRUE)
      message("File1: alternative normalization method is applied")
    }
    DataUse <- GetNormalizedMat(Matbk,Sizes)
    }    
    if(!List$NormTF){
      DataUse <- Matbk
    }

    if(List$ProjTF){
	    if(List$NormTF){
	    Sizes <- MedianNorm(Matsc)
	    if(is.na(Sizes[1])){
	      Sizes <- MedianNorm(Matsc, alternative=TRUE)
	      message("File2: alternative normalization method is applied")
	    }
	    scDataUse <- GetNormalizedMat(Matsc,Sizes)
	    }    
	    if(!List$NormTF){
	      scDataUse <- Matsc
	    }
    }	
	# PushOL     
    if(List$OLTF){
		Q5 = apply(DataUse, 1, function(i) quantile(i, 0.05))
		Q95 = apply(DataUse, 1, function(i) quantile(i, 0.95))
		DataSc2 = DataUse
		for (i in 1:nrow(DataUse)) {
		    DataSc2[i, which(DataSc2[i, ] < Q5[i])] = Q5[i]
		    DataSc2[i, which(DataSc2[i, ] > Q95[i])] = Q95[i]
		}
		DataUse = DataSc2    
    }  
    if(List$ProjTF){
	    if(List$OLTF){
			Q5 = apply(scDataUse, 1, function(i) quantile(i, 0.05))
			Q95 = apply(scDataUse, 1, function(i) quantile(i, 0.95))
			scDataSc2 = scDataUse
			for (i in 1:nrow(scDataUse)) {
			    scDataSc2[i, which(scDataSc2[i, ] < Q5[i])] = Q5[i]
			    scDataSc2[i, which(scDataSc2[i, ] > Q95[i])] = Q95[i]
			}
			scDataUse = scDataSc2    
	    }  
    }
	
	Matscale=t(apply(DataUse,1,scale))
	rownames(Matscale)=rownames(DataUse)
	colnames(Matscale)=colnames(DataUse)
	Matscale[which(is.na(Matscale))]=0
	bkPCAres =PCAres=prcomp(t(Matscale))
	
 	if(List$ProjTF){ 
	    MatSCscale=t(apply(scDataUse,1,scale))
	    rownames(MatSCscale)=rownames(scDataUse)
	    colnames(MatSCscale)=colnames(scDataUse)
	    MatSCscale[which(is.na(MatSCscale))]=0	

		if(length(all.equal(rownames(Matscale),rownames(MatSCscale)))>1) print("For PCA, use genes that are in both File1 (bulk) and File2 (sc)")
		  Commg = intersect(rownames(Matscale),rownames(MatSCscale))
		  Matscalecommg = Matscale[Commg,]
		  PCAres=bkPCAres=prcomp(t(Matscalecommg))
		  MatSCscalecommg = MatSCscale[Commg,]
		  scPCAres=prcomp(t(MatSCscalecommg))  
		  SConbulkPCA=t(PCAres$rotation) %*% MatSCscalecommg # bulk projected PCA
		  PCAres = list(x=t(SConbulkPCA))
	}
		
	# biplot  
	if(List$ProjTF)List$BiplotTF=FALSE
    if(List$BiplotTF){
        pdf(List$BiPlot, height=10,width=10)
		biplot(bkPCAres,main="Biplot on File 1")
        dev.off()
	    print("Biplot...")
	}
    
	# screeplot     
    if(List$ScreeplotTF){
        pdf(List$ScreePlot, height=10,width=10)
	    	screeplot(bkPCAres,type="lines")
        dev.off()
	    print("Scree Plot...")
    }
	
	pdf(List$TrDataPlot, height=10,width=10)
	pairs(PCAres$x[,1:List$Numk],col=as.factor(GroupV))
	plot(PCAres$x[,1],PCAres$x[,2],col=as.factor(GroupV),cex=2,pch=16,xlab="PC1",ylab="PC2",cex.lab=1.5)
	text(PCAres$x[,1], PCAres$x[,2], labels=as.character(GroupV), cex=1.5, pos=3)
	dev.off()
	
	Perc=bkPCAres$sdev/sum(bkPCAres$sdev)
	write.csv(Perc, file=List$VarExp)
	
	PCA_sort=sapply(1:List$Numk,function(j){
	  tmp=abs(bkPCAres$rotation[,j])
	  t2=names(sort(tmp,decreasing=T))
	})
	colnames(PCA_sort)=paste0("PC",1:List$Numk)
	
	write.csv(bkPCAres$rotation[,1:List$Numk], file=List$Loading)
	write.csv(PCA_sort[,1:List$Numk], file=List$SortedLoading)

	sink(List$Info)
  print("Input parameters")
  print(paste0("whether normalize the data? ",List$NormTF ))
	print(paste0("whether adjust outlier (top/bottom 5%)? ",List$OLTF ))
	print(paste0("what is the lower limit of detection (max value)? ",List$LODNum ))
	print(paste0("how many PCs to output? ",List$Numk ))
	print(paste0("whether perform projected PCA? ",List$ProjTF ))
	print(paste0("whether plot a biplot? ",List$BiplotTF ))
	print(paste0("whether plot a scree plot? ",List$ScreeplotTF ))	
	sink()
	List=c(List, list(Sig=rownames(Matscale)))  
	
})

 Act <- eventReactive(input$Submit,{
   In()})
 # Show the values using an HTML table
 output$print0 <- renderText({
   tmp <- Act()
   str(tmp)
   paste("output directory:", tmp$Dir)
 })
 
 output$tab <- renderDataTable({
   tmp <- Act()$Sig
   t1 <- tmp
   print("done")
   t1
 },options = list(lengthManu = c(4,4), pageLength = 20))
 
#  output$done <- renderText({"Done"})
})
