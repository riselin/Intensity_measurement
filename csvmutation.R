# csv adjustment
# select working directory
# save adjusted .csv in ./csv
# save overview with stored filename and cell type into an overview csv in working directory

#IMPORTANT NOTE ON PATHS:
#ON MAC: WRITE "~/FOLDER/FOLDER/"
#ON WINDOWS: WRITE "../FOLDER/FOLDER/"


rm(list=ls())

#setwd()
#setwd()

#csv import path
csvimportpath <- "./original_csv/"

#csv export path
csvexportpath <- "./csv/"

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
  d.temp[,2] <- d.temp[,2]*1000
  #d.temp[,2] <- gsub(".", "", d.temp[,2], fixed = T)
  if (ncol(d.temp) == 3){
    d.temp2 <- c(1:nrow(d.temp))
    d.experiment_overview[i,'celltype'] <- d.temp[1, 2]
    d.experiment_overview[i,'cellID'] <- d.temp[1, 3]
    d.export <- data.frame(cbind(d.temp2,d.temp[,1]))
  }
  if (ncol(d.temp) == 4){
    d.experiment_overview[i,'celltype'] <- d.temp[1, 3]
    d.experiment_overview[i,'cellID'] <- d.temp[1, 4]
    d.export <- d.temp[,c(1:2)]
  }
  d.experiment_overview[i,'strain'] <- filenames[i]
  
  d.export <- d.temp[,1:2]
  colnames(d.export) <- c("x", "y") #renaming the columns
  d.export[,"x"] <- d.export[,"x"]*0.128 #be careful about this part: he allways has 0.128nm between each pixel we could just delete it. 
  write.table(d.export, file = csvfileexportpaths[i],row.names=FALSE, sep=";")
}

write.table(d.experiment_overview, file = './intensity_overview.csv',row.names=FALSE, sep=";")
