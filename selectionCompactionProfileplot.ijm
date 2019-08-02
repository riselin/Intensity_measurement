var ActiveWindow;
var count = 0;
var AnaG1 = NaN;
var constZoom = 200; //set zoom (%)
var tempFile = NaN;
var tempTitle = NaN;
var tempFluoro = NaN;
var fileTitle = "";
var fileCount = 0;
var filelist = "";
var fluorophore = "";
var channelValue = 0;
var lineValue = 2;
var cellcounter = 0;


print("Press 'o' to open the file");

macro "Set Line width [i]"{
    //channelValue = Dialog.getNumber("Do you want to measure mCherry (second channel; press '2') \n or do you want to measure GFP (third channel; press '3')?");
    Dialog.create ("Settings for intensity measurement");
	Dialog.addMessage ("Set Line Width (Standard: 2)");
	Dialog.addNumber ("Line Width:", lineValue); //number 2
    Dialog.show ();
	lineValue = Dialog.getNumber (); //2
        
    run("Line Width...", "line="+lineValue);
    print("LineWidth set to "+lineValue);
}

macro "open [o]"{
    pathImages = getDirectory("Choose directory...");
    filelist = getFileList(pathImages);
    filelist = Array.sort(filelist);
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
    run("Close All");
    ActiveWindow = filelist[fileCount];
	print("Next File will been opened");
	openTIFfile();
}

macro "Undo that cell [u]"{
    tFile = cropTitleFilename();
    run("Measure");
    setResult("Fluorophore", nResults-1, "RemoveResult");
    setResult("Filename", nResults-1, tFile);
    count++;
    fileCount++;
}

macro "draw new circle [c]"{
	makeOval(40, 40, 3, 3); //position x, position y, width, heigth
	setTool("oval");
}

macro "select line [x]"{
	setTool("line");
}

macro "Macro_analyse intensity in G1 [g]"{
	AnaG1 = 0;
    tFluoro = cropTitleFluorophore();
    tFile = cropTitleFilename();
    writeTableContent(count, AnaG1, tFluoro, tFile);
    saveAsCSV(count, "line");
    count++;
    print("Count: ", count, "; File Count: ", fileCount);
}

macro "Macro_analyse intensity in Ana mother [f]"{
	AnaG1 = 1;
    tFluoro = cropTitleFluorophore();
    tFile = cropTitleFilename();
    writeTableContent(count, AnaG1, tFluoro, tFile);
    saveAsCSV(count, "line");
    count++;
    print("Count: ", count, "; File Count: ", fileCount);
}

macro "Macro_analyse intensity in Ana daughter [d]"{
	AnaG1 = 2;
    tFluoro = cropTitleFluorophore();
    tFile = cropTitleFilename();
    writeTableContent(count, AnaG1, tFluoro, tFile);
    saveAsCSV(count, "line");
    count++;
    print("Count: ", count, "; File Count: ", fileCount);
}

macro "analyse intensity dot[a]"{
	run("Measure");
}

macro "analyse intensity nuclear backbround[s]"{
    tFluoro = cropTitleFluorophore();
    tFile = cropTitleFilename();
    run("Measure");
    setResult("Fluorophore", nResults-1, tFluoro);
    setResult("Filename", nResults-1, tFile);
	run("Clear", "slice");
    saveAsCSV(count, "circle");
    count++;
	print("Count: ", count, "; File Count: ", fileCount);
}

//functions 
function openTIFfile(){
	// 20171015
	// For the order of brightfield, red and green, check the deconv log file:
	// Example: 
	// Wavelengths selected......       0    617    528 
	// means 1. brightfield, 2. TRITC (red), 3. FITC (green)
	//  ***** Adjusted from Anne Meinema's contraction analysis script *****
	//
	// R. Iselin
	//
	//********************start*************
	// ****OPEN FILE****
	//necessary for [w] macro to open next: fiji needs something to open!
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
	

	//split channels for sum intensity prjections
	run("Set... ", "zoom=95"); 
	run("Split Channels"); //change to contraction: all with sum slices, not max intensity!
	selectWindow("C1-"+ ActiveWindow); //brightfield
	run("Z Project...", "projection=[Sum Slices]");
	run("16-bit");
	selectWindow("C2-"+ ActiveWindow);
	run("Z Project...", "projection=[Sum Slices]");
	run("16-bit");
	selectWindow("C3-"+ ActiveWindow);
	run("Z Project...", "projection=[Sum Slices]");
	run("16-bit");
	
   	// Merge and Set channels for z-stack
   	run("Merge Channels...", "title=" + ActiveWindow + " c1=C1-" + ActiveWindow + " c2=C2-" + ActiveWindow + " c3=C3-" + ActiveWindow + " create");
    Stack.setSlice(5);
    Stack.setChannel(1);
    run("Grays");
    Stack.setChannel(2);
    run("Red");		
    Stack.setChannel(3);
    run("Green");
    Stack.setActiveChannels("111");
   	
	
	selectWindow(ActiveWindow);
	run("In [+]"); //zoom in to 150%
    run("In [+]");
    run("In [+]");
    run("In [+]");
    run("In [+]");
	//run("In [+]"); //zoom in to 200%
	
	//set oval for measurement
	selectWindow("SUM_C1-" + ActiveWindow); 
	close();
	run("In [+]"); //zoom in to 150%
	selectWindow("SUM_C2-" + ActiveWindow);//SUM_C2-
	run("In [+]"); //zoom in to 150%
	run("In [+]"); //zoom in to 200%
    run("In [+]");
    run("In [+]");
    run("In [+]");
    run("In [+]");
    run("In [+]");
	//close();
	selectWindow("SUM_C3-" + ActiveWindow);//SUM_C3-
	//run("Set... ", "zoom=" + (1*constZoom));
	run("In [+]"); //zoom in to 150%
	run("In [+]"); //zoom in to 200%
    run("In [+]");
    run("In [+]");
    run("In [+]");
    run("In [+]");
    run("In [+]");
	makeOval(40, 40, 3, 3); //position x, position y, width, heigth
	//setTool("oval");
    setTool("zoom");
	run("Channels Tool...");
	run("Brightness/Contrast..."); // not really necessary - allows you to adjust brightness
	print(ActiveWindow);
	print("  --> Press 'q' to quit, 'w' to load the next file, or 'o' to open an image.");
    print("Draw a circle of around 3x3 pixel to measure at 1200% magnification. Remember to measure for both channels.");
	print("	  --> Press 'a' to measure intensity of the dot.");
	print("	  --> Press 's' to measure intensity of the background and mark the measured cell.");
	print("");
	
}

function writeTableContent(setCellcounter, setAnaG1, fFluoro, fFile){
    profile = getProfile();
	for (i=0; i<profile.length; i++){
 		setResult("Value", i, profile[i]);
 		setResult("AnaG1", i, setAnaG1);
        setResult("Fluorophore", i, fFluoro);
        setResult("Filename", i, fFile);
        setResult("CellID", i, setCellcounter);
    };
	selectWindow(tempTitle);
}

function cropTitleFluorophore(){
    tempTitle=getTitle();
    tempFluoro=substring(tempTitle,4,6); //only take C2 or C3 as identifier for mChe/GFP, respectively
    return tempFluoro;
}

function cropTitleFilename(){
    tempTitle=getTitle();
    tempFile=substring(tempTitle, 7, lengthOf(tempTitle));
    return tempFile;
}

function saveAsCSV(fcount, mtype){
    
    SaveNameCSV = cropTitleFilename();
	path1 =  getDirectory("current") + "compactionCSVs\\";
    if (!File.exists(path1)){
        File.makeDirectory(path1);
        write("Folder 'compactionCSVs' created");
	}
	store_nameCSV = SaveNameCSV + "_" + fcount + "_" + mtype + ".csv";
	saveAs("Measurements", path1 + store_nameCSV);
	run("Clear Results"); // clear after saving
}