# csv adjustment
# select working directory
# save adjusted .csv in ./csv
# save overview with stored filename and cell type into an overview csv in working directory

#IMPORTANT NOTE ON PATHS:
#ON MAC: WRITE "~/FOLDER/FOLDER/"
#ON WINDOWS: WRITE "../FOLDER/FOLDER/"


rm(list=ls())

#setwd("//pasteur/SysBC-Home/riselin/Desktop/8_Misc/Coding/Python/Pythonscripts")
#setwd("~/polybox/PhD/Pythonscripts")

#csv import path
csvimportpath <- "../original_csv/"

#csv export path
csvexportpath <- "../csv/"

#loop through all files
filenames <- list.files(path=csvimportpath)
csvfileimportpaths <- paste(csvimportpath, filenames, sep="")
csvfileexportpaths <- paste(csvexportpath, filenames, sep="")

#make overview
d.experiment_overview <- data.frame(x=NA, y=NA)
colnames(d.experiment_overview) <- c("strain", "celltype")

for (i in 1:length(filenames)){
  d.temp <- read.csv(csvfileimportpaths[i], header = T, sep = ",")
  names(d.temp) <- gsub("\\.csv", "", filenames[i])
  d.experiment_overview[i,'strain'] <- filenames[i]
  d.experiment_overview[i,'celltype'] <- d.temp[1, 3]
  d.export <- d.temp[,1:2]
  colnames(d.export) <- c("X", "Y")
  d.export[,"X"] <- d.export[,"X"]*0.128*1000
  write.table(d.export, file = csvfileexportpaths[i],row.names=FALSE, sep=";")
}

write.table(d.experiment_overview, file = '../intensity_overview.csv',row.names=FALSE, sep=";")
