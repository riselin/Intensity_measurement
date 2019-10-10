#Circle Stitcher
# Take csv files, and stitch them into a single one
# Only take files ending in "_circle.csv"

library(stringr)

rm(list=ls())

#foldernames
foldernames <- list.files(path="./")
foldernames <- foldernames[str_sub(foldernames,1,8)=="Analysis"]


#FUNCTIONS
completeFluoroFilename <- function(fdata){
  for (k in 1:(nrow(fdata)-1)){
    if (k%%2==1){
      fdata[k,"fluorophore"] <-  fdata[k+1,"fluorophore"]
      fdata[k,"filename"] <- fdata[k+1,"filename"]
    }
  }  
  fdata
}
replaceChannelFluoro <- function(fdata){
  fdata$fluorophore <- as.character(fdata$fluorophore)
  fdata[fdata[,"fluorophore"]=="C2","fluorophore"] <- "mChe"
  fdata[fdata[,"fluorophore"]=="C3","fluorophore"] <- "GFP"
  fdata
}
completeSignalBackground <- function(fdata){
  #alternatively use "x" column. 1 is signal, 2 is background
  for (k in 1:nrow(fdata)){
    if (k%%2==1){
      fdata[k,"signal"] <- "signal"
    }
    if (k%%2==0){
      fdata[k,"signal"] <- "background"
    }
  }
  fdata
}
assignMotherDaughter <- function(fdata){
  genealogy <- c("daughter", "mother")
  fdata <- cbind(fdata, celltype=(rep(genealogy, each = 2, times = nrow(fdata)/4)))
  fdata
}

for(i in 1:length(foldernames)){
  #csv import path
  csvimportpath <- paste(foldernames[i], "/compactionCSVs/", sep="")
  #csv export path
  csvexportpath <- paste(foldernames[i], "/stitchedCSVs/", sep="")
  #import and prepare data
  filenames <- list.files(path=csvimportpath)
  filenames <- filenames[str_sub(filenames, -10,-5) == "circle"]
  csvfileimportpaths <- paste(csvimportpath, filenames, sep="")
  csvfileexportpaths <- paste(csvexportpath, paste(strsplit(filenames[1], "_")[[1]][1], 
                                                   strsplit(filenames[1], "_")[[1]][2], 
                                                   strsplit(filenames[1], "_")[[1]][3],sep="_"), 
                              ".csv", sep="")
  d.experiment_overview <- data.frame()
  for (j in 1:length(filenames)){
    d.temp <- read.csv(csvfileimportpaths[j], header = T, sep = ",")
    if (nrow(d.temp)<2){
      next
    }
    if (str_sub(d.temp[2,7],-9,-7)=="NaN"){
      next
    }
    if (nrow(d.temp)>2){
      if (d.temp[1,8]==0 && d.temp[2,8]==0){
        d.temp <- d.temp[c(2:3),]
      }
    }
    if (ncol(d.temp)>7){
      d.temp <- d.temp[,c("X", "Area", "Mean", "Min", "Max", "Fluorophore", "Filename")]
    }
    
    d.experiment_overview <- rbind(d.experiment_overview,d.temp)
  }
  if(foldernames[i]=="Analysis_3476_p2424"){
    d.experiment_overview <- d.experiment_overview[c(1:20, 27:150),]
  }
  colnames(d.experiment_overview) <- c("x", "area", "mean", "min", "max", "fluorophore", "filename")
  # d.experiment_overview <- d.experiment_overview[c(1:24, 28:155),]
  row.names(d.experiment_overview) <- NULL
  #apply functions
  d.experiment_overview <- completeFluoroFilename(d.experiment_overview)
  d.experiment_overview <- completeSignalBackground(d.experiment_overview)
  d.experiment_overview <- replaceChannelFluoro(d.experiment_overview)
  #make G1 and Ana specific dataframes
  g1_id <-  which(str_sub(d.experiment_overview$filename, -7,-7)=="G")
  ana_id <- which(str_sub(d.experiment_overview$filename, -7,-7)=="A")
  d.g1 <- d.experiment_overview[g1_id,]
  row.names(d.g1) <- NULL
  d.g1$celltype <- "G1"
  d.ana <- d.experiment_overview[ana_id,]
  row.names(d.ana) <- NULL
  d.ana <- assignMotherDaughter(d.ana)
  #export
  d.export <- rbind(d.g1, d.ana)
  write.table(d.export, file = csvfileexportpaths,row.names=FALSE, sep=";")
}
#csv import path
csvimportpath <- paste(foldernames[2], "/compactionCSVs/", sep="")
#csv export path
csvexportpath <- paste(foldernames[2], "/stitchedCSVs/", sep="")
