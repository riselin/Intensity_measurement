#Circle Stitcher
# Take csv files, and stitch them into a single one
# Only take files ending in "_circle.csv"

library(stringr)
library(reshape2)

rm(list=ls())

#foldernames
#foldernames <- list.files(path="./")
#foldernames <- foldernames[str_sub(foldernames,1,8)=="Analysis"]


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

#csv import path
csvimportpath <- "./"
#csv export path
csvexportpath <-"./stitchedCSVs/"
#import and prepare data
filenames <- list.files(path=csvimportpath)
filenames <- filenames[str_sub(filenames, -10,-5) == "circle"]
csvfileimportpaths <- paste(csvimportpath, filenames, sep="")
# csvfileexportpaths <- paste(csvexportpath, paste(strsplit(filenames[1], "_")[[1]][1], 
#                                                  strsplit(filenames[1], "_")[[1]][2], 
#                                                  strsplit(filenames[1], "_")[[1]][3],sep="_"), 
#                             ".csv", sep="")
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
    d.temp <- d.temp[,c("x", "area", "mean", "min", "max", "fluorophore", "filename")]
  }
  
  d.experiment_overview <- rbind(d.experiment_overview,d.temp)
}
colnames(d.experiment_overview) <- c("x", "area", "mean", "min", "max", "fluorophore", "filename")
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
d.g1_long <- melt(d.g1, measure.vars = c("mean", "max"))
d.g1_wide <- dcast(d.g1_long, filename + fluorophore + celltype ~ signal + variable, value.var = "value")

d.ana <- d.experiment_overview[ana_id,]
row.names(d.ana) <- NULL
d.ana <- d.ana[-c(57:62),]
d.ana <- assignMotherDaughter(d.ana)

typeof(d.ana$max)
d.ana_long <- melt(d.ana, measure.vars = c("mean", "max"))
d.ana_wide <- dcast(d.ana_long, filename + fluorophore + celltype ~ signal + variable, value.var = "value")

#delta of background and dot
ggplot(d.ana, aes(x=length, y=distance)) + 
  geom_point() +
  geom_smooth(method=lm)





#export
d.export <- rbind(d.g1_wide, d.ana_wide)
write.table(d.export, file = "./stitchedCSVs/CompactionAnalysis.csv",row.names=FALSE, sep=";")


