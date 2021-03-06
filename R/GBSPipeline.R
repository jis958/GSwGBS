GBSPipeline <-
function(projectName, keyFile, seqDir, tasselJar, heapSize, enzyme="PstI-MspI", maxMissingData=0.8, minorAlleleFreq=0.01, maxHet=0.1, isDHpopulation=F, callHets=T, pVal=0.001, runPipeline=T, isQseq=F, tagCountsDir=NULL, masterTagsFile=NULL, tbtDir=NULL, tbtFile=NULL, tbtFileMerge=NULL, hapDir=NULL){
  
  #initialize JVM
  if(.jniInitialized){
	warning("The JVM has already been initialized, so heap size can not be changed.")
  }else{
	options(java.parameters=paste("-Xmx", heapSize, "g", sep=""))
  }
  .jpackage("GSwGBS", morePaths=tasselJar)

  #create file directories if needed
  dir.create(file.path(getwd(), projectName), showWarnings = FALSE)
  dir.create(file.path(getwd(), projectName, "tagcounts"), showWarnings = FALSE)
  dir.create(file.path(getwd(), projectName, "tbt"), showWarnings = FALSE)
  
  #prepare arguments for passing to Java
  maxMissingData = as.character(maxMissingData)
  minorAlleleFreq = as.character(minorAlleleFreq)
  maxHet = as.character(maxHet)
  isDHpopulation = tolower(as.character(isDHpopulation))
  isBiparental = "false"
  callHets = tolower(as.character(callHets))
  pVal = as.character(pVal)
  
  #create getDate function equivalent to date format used in TagsToSNPsNoAnchor
  getDate = function() gsub("-", "", Sys.Date())
  
  #create additional arguments for passing to Java
  if(is.null(tagCountsDir)){
    tagCountsDir = file.path(getwd(), projectName, "tagcounts")
  }
  if(is.null(masterTagsFile)){
    masterTagsFile = file.path(getwd(), projectName, 
                               paste("MasterTags_", projectName, ".cnt", sep=""))
  }
  if(is.null(tbtDir)){
    tbtDir = file.path(getwd(), projectName, "tbt")
  }
  if(is.null(tbtFile)){
    tbtFile = file.path(getwd(), projectName, 
                        paste("tbt_", projectName, "_", getDate(), ".bin", sep=""))
  }
  if(is.null(tbtFileMerge)){
    tbtFileMerge = file.path(getwd(), projectName,
                             paste("tbtMerge_", projectName, "_", getDate(), ".bin", sep=""))
  }
  if(is.null(hapDir)){
    hapDir = file.path(getwd(), projectName) 
  }
  
  #create object of GBSPipeline class
  rArgs = c(projectName, keyFile, seqDir, tagCountsDir, masterTagsFile, tbtDir, tbtFile, 
            tbtFileMerge, hapDir, enzyme, maxMissingData, minorAlleleFreq, maxHet, 
            isDHpopulation, isBiparental, callHets, pVal)
  pipeline = .jnew("gbspipeline.GBSPipeline", rArgs)
  if(!runPipeline) return(pipeline)
  
  #run pipeline
  if(isQseq){
	.jcall(pipeline, ,"runQseqDeNovoPipeline")
  }else{
	.jcall(pipeline, ,"runFastqDeNovoPipeline")
  }
}
