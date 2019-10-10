#Cellsize stitcher.
# Similar to circle, but combine distances

library(stringr)
setwd("Y:/Raphael/Data/20190528_WT_standardization/SelectedCells/distanceCSVs/")
rm(list=ls())

#filenames
filenames <- list.files(path="./")

#csv import path
csvimportpath <- "./"
csvfileimportpaths <- paste(csvimportpath, filenames, sep="")
#csv export path
csvexportpath <- "./stitchedCellsize/"
csvfileexportpaths <- paste(csvexportpath, "cellsize.csv", sep="")
d.experiment_overview <- data.frame()

for(i in 1:length(filenames)){
  d.temp <- read.csv(csvfileimportpaths[i], header = T, sep = ",")
  d.experiment_overview <- rbind(d.experiment_overview,d.temp)
}
colnames(d.experiment_overview) <- c("x", "area", "angle", "length", "filename", "section")
row.names(d.experiment_overview) <- NULL
#make G1 and Ana specific dataframes
g1_id <-  which(str_sub(d.experiment_overview$filename, -7,-7)=="G")
ana_id <- which(str_sub(d.experiment_overview$filename, -7,-7)=="A")
d.g1 <- d.experiment_overview[g1_id,]
row.names(d.g1) <- NULL
d.g1$cellPhase <- "G1"
d.ana <- d.experiment_overview[ana_id,]
row.names(d.ana) <- NULL
d.ana$cellPhase <- rep(c("overall", "AnaM", "AnaD"), times = nrow(d.ana)/3)


#export
d.export <- rbind(d.g1, d.ana)
write.table(d.export, file = csvfileexportpaths,row.names=FALSE, sep=";")
