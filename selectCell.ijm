//20190710
// Script to select and correctly save image cutouts

// open image [o]

// read out name, add iterating number to distinguish different selections
// possibly add cellphase to name?

// select rectangle, make duplicate, save entire stack with all channels with the correct name [s]

// open next image [w]

//START SCRIPT

var ActiveWindow;
var count = 1;
var constZoom = 200; //set zoom (%)
var tempTitle = NaN;
var AnaG1 = NaN;


print("Press 'o' to open a file");

// macros

macro "open [o]"{
    ActiveWindow = "NA";
	openImage();
}

macro "close and open next [w]"{
	run("Close All");
	print("image closed:  ", ActiveWindow);
	print("done, "+ count-1 + " cells analyzed from this image.");
	print("");
	count = 1;
	print("");
	print("New file will be opened...");
	print("");
	AWpre = replace(ActiveWindow,"_R3D_D3D.dv","");
	len=lengthOf(AWpre);
	len = len - 2;
	AWpre = substring(AWpre, 0, len);
 	AWend = replace(ActiveWindow,AWpre,"");
	AWint = replace(AWend,"_R3D_D3D.dv","");
	AWint = parseInt(AWint);
	AWint = AWint +1;
    AWend = "_R3D_D3D.dv";
	if (AWint < 10){
		ActiveWindow = AWpre + "0" + AWint + AWend;
		}
	else if (AWint > 9){	  
		ActiveWindow = AWpre + AWint + AWend;
		}
	else{
		ActiveWindow = "Na"; 
		}
	openImage();
}

macro "Macro_saveFiles_cropx [s]"{
	tempTitle=getTitle();
    duplicateAndSave(count);
    count = count + 1;
	print("   Press 'w' for new image.");
	print("   Press 'q' to close everything.");
	print("");
}

macro "Macro_saveFiles_cropx G1 cell [g]"{
    AnaG1 = "G";
	tempTitle=getTitle();
    duplicateAndSave(count);
    count = count + 1;
    print("Next count: ", count);
	print("   Press 'w' for new image.");
	print("   Press 'q' to close everything.");
	print("");
}

macro "Macro_analyse distance in Ana [a]"{
    AnaG1 = "A";
	tempTitle=getTitle();
    duplicateAndSave(count);
    count = count + 1;
    print("Next count: ", count);
	print("   Press 'w' for new image.");
	print("   Press 'q' to close everything.");
	print("");
}

macro "close all [q]"{
	run("Close All");
	print("image closed:  ", ActiveWindow);
	print("");
	count = 1;
    ActiveWindow = "NA";
}

//functions 

function openImage(){
	len1 = lengthOf(ActiveWindow);
	if (len1 > 10){ //for some reason, filenames are always larger than 10 characters
		open(ActiveWindow);
	};
	else{
		open();
		ActiveWindow = File.name;
		path =  getDirectory("current");
	};

	print("File opened: " + ActiveWindow );
	print("Location: " + getDirectory("current"));
	print("");
	

	//split channels for max and sum intensity prjections
	run("Set... ", "zoom=" + constZoom); 
	
	run("Split Channels");
	

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
		Stack.setActiveChannels("111");
		//run("Set... ", "zoom=" + (1*constZoom));

    run("In [+]");
    run("In [+]");
	run("Channels Tool...");
	run("Brightness/Contrast...");
	//run("Set... ", "zoom=" + constZoom); 
	
	makeRectangle(252, 252, 41, 41);
	setTool("rectangle");
	
 	String.copy(ActiveWindow);  // Copy WindowID to clipboard
	
	print(ActiveWindow);
	print("    --> Select cell of interest, press 'g' or 'a' to save the specific cell phase.");
	print("    --> Or press 'q' to quit, or 'w' to load another file.");
}

function duplicateAndSave(fcount){
	//print(ActiveWindow)	
	SaveName = replace(ActiveWindow,".dv","_Crop_" + AnaG1 + "_" + fcount);
	path1 =  getDirectory("current") + "SelectedCells\\";
	if (!File.exists(path1)){
        File.makeDirectory(path1);
        write("Folder 'SelectedCells' created");
	}
	
	run("Duplicate...", "title=Temp duplicate channels=1-3 slices=1-10");
    run("In [+]");
	run("In [+]");
	selectWindow(tempTitle);
    for (i=0; i< nSlices; i++){
    Stack.setSlice(i);
    Stack.setChannel(2);
    run("Clear", "slice");
    Stack.setChannel(3);
    run("Clear", "slice");
    }
	selectWindow("Temp");
	
	//***SAVE AS TIFF****
	store_name = SaveName + ".tif";
	saveAs("Tiff", path1 + store_name);
	print("Cropped Tiff saved: " +  store_name);
    close();
    selectWindow(tempTitle);
    Stack.setSlice(5);
    makeRectangle(252, 252, 41, 41);
	setTool("rectangle");
}