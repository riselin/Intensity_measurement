//The script allows you to measure the length of the cell. 
//If a second measurement is done per cell, that is assumed to be the distance mother-tip to budneck.

var ActiveWindow;
var count = 0; //for each image starting at 0
var zoom = 800; //set zoom (%)
var tempTitle = NaN;
var fileTitle = "";
var fileCount = 0;
var filelist = "";


macro "open [o]"{
    pathImages = getDirectory("Choose directory...");
    run("Set Measurements...", "area redirect=None decimal=3");
    filelist = getFileList(pathImages);
    filelist = Array.sort(filelist);
    //print(filelist[0]);
    fileCount = 0;
	ActiveWindow = "NA";
	openTIFfile();
    fileTitle = File.name;
    for (i = 0; i<filelist.length;i++){ 
        if (filelist[i] == fileTitle){
            fileCount = i; //sets the start of your analysis session. If you started at the top then count = i
            break;
        }
    }
}

macro "close all [q]"{
	run("Close All");
	print("image closed:  ", ActiveWindow);
    fileCount = 0;
    print("count reset to ", fileCount);
	print("");
	
}

macro "close and open next [w]"{
    saveAsCSV(fileCount);
    run("Close All");
    count = 0;
    fileCount++;
    ActiveWindow = filelist[fileCount];
	print("Next File will been opened");
	openTIFfile();
}

macro "Undo that cell [u]"{
    tFile = cropTitleFilename();
    run("Measure");
    setResult("Filename", nResults-1, tFile);
    setResult("section", nResults-1, "RemoveResult");
    count = 0;
}

macro "select line [x]"{
    run("Set Measurements...", "  redirect=None decimal=3"); //to only output angle and length
	setTool("line");
}

macro "determine distance [d]"{
    tFile = cropTitleFilename();
    run("Measure");
    setResult("Filename", nResults-1, tFile);
    if (count == 0){
        setResult("section", nResults-1, "overall");
    }
    if (count == 1){
        setResult("section", nResults-1, "mothertip-budneck");
    }
    if (count == 2){
        setResult("section", nResults-1, "budtip-budneck");
    }
    if (count > 2){
        setResult("section", nResults-1, "varia");
    }
	print("   Press 'w' for next cell.");
	print("   Press 'q' to close everything.");
	count++;
}

//functions 
function openTIFfile(){
	// originally by Anne Meinema
    // adjusted by Raphael Iselin

    len1 = lengthOf(ActiveWindow);
	if (len1 > 10){
		open(ActiveWindow);
	}
	else{
		open();
		ActiveWindow = File.name;
		path =  getDirectory("current");
	}
	print("File opened: " + ActiveWindow );
	print("Location: " + getDirectory("current"));
	print("");
	
	//split channels for max and sum intensity projections
	run("Set... ", "zoom=95"); 
	run("Split Channels");
	selectWindow("C1-"+ ActiveWindow);
	run("Z Project...", "projection=[Sum Slices]");
	run("16-bit");
	selectWindow("C2-"+ ActiveWindow);
	run("Z Project...", "projection=[Max Intensity]");
	selectWindow("C3-"+ ActiveWindow);
	run("Z Project...", "projection=[Max Intensity]");
	
   	// Merge and Set channels for z-stack
   	run("Merge Channels...", "title=" + ActiveWindow + " c1=C1-" + ActiveWindow + " c2=C2-" + ActiveWindow + " c3=C3-" + ActiveWindow + " create");
    Stack.setSlice(5);
    Stack.setChannel(1);
    run("Enhance Contrast", "saturated=0.05");
    run("Grays");
    Stack.setChannel(2);
    run("Enhance Contrast", "saturated=0.05");
    run("Red");
    Stack.setChannel(3);
    run("Enhance Contrast", "saturated=0.05");
    run("Green");
    Stack.setActiveChannels("011");
    run("Set... ", "zoom=" + (1*zoom)); 
   	
   	// Merge and Set channels for projections
   	run("Merge Channels...", "title=Projections c1=SUM_C1-" + ActiveWindow + " c2=MAX_C2-" + ActiveWindow + " c3=MAX_C3-" + ActiveWindow + " create");
    Stack.setChannel(1);
    run("Enhance Contrast", "saturated=0.15");
    run("Grays");
    Stack.setChannel(2);
    run("Enhance Contrast", "saturated=0.15");
    run("Red");
    Stack.setChannel(3);
    run("Enhance Contrast", "saturated=0.05");
    run("Green");  
    Stack.setActiveChannels("111");

	run("Channels Tool...");
	run("Brightness/Contrast...");
	run("Set... ", "zoom=" + zoom); 
	
	//set line for Cropping
	selectWindow("Composite");
	setTool("line");
	print(ActiveWindow);
	print("	   --> Press 'd' to measure distance.");
	print("    --> Or press 's' to remove a value from the results windowo.");
	print("    --> Or press 'q' to quit, or 'w' to load another file.");
}


function cropTitleFilename(){
    tempFile=File.name;
    return tempFile;
}

function saveAsCSV(fcount){
    SaveNameCSV = cropTitleFilename();
	path1 =  getDirectory("current") + "distanceCSVs\\";
    if (!File.exists(path1)){
        File.makeDirectory(path1);
        write("Folder 'distanceCSVs' created");
	}
	store_nameCSV = SaveNameCSV + "_" + fcount + "_" + "distance" + ".csv";
	saveAs("Measurements", path1 + store_nameCSV);
	run("Clear Results"); // clear after saving
    }