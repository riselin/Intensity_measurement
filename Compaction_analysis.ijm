

var ActiveWindow;
var count = 0;
var AnaG1 = NaN;
var constZoom = 200; //set zoom (%)
var tempFile = NaN;
var tempTitle = NaN;
var tempFluoro = NaN;
var i = 0;
manualName = "initialize";
runSave = false;

//compliment_list = newArray("Well done!", "Keep going", "Some more would be great", "Do you have 50 total already?", "Very good!", "This is great!", "You could go up to 70...");


print("Press 'o' to open the file");

macro "open [o]"{
    ActiveWindow = "NA";
	openDVFile();
}

macro "close and open next [w]"{
    saveFile();
	run("Close All");
	print("image closed:  ", ActiveWindow);
	print("done, "+ count + " cells analyzed from this image.");
	print("");
	count = 0;
	print("");
	print("New file will be opened...");
	print("");
	//print("Active Window"+ ActiveWindow);
	AWpre = replace(ActiveWindow,"_R3D_D3D.dv","");
	//print("Check A1: " + AWpre);
	len=lengthOf(AWpre);
	len = len - 2;
	AWpre = substring(AWpre, 0, len);
 	//print(AWpre);
 	AWend = replace(ActiveWindow,AWpre,"");
	//print("end  :" + AWend);
	AWint = replace(AWend,"_R3D_D3D.dv","");
	//print("Check A2: " + AWint);
	AWint = parseInt(AWint);
	//print(AWint);
	AWint = AWint +1;
	//print("Check A3: " + AWint);
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
	print("Next File will been opened");
	//run("Open Next")
	openDVFile();
}

macro "draw new circle [c]"{
	makeOval(252, 252, 3, 3); //position x, position y, width, heigth
	setTool("oval");
}

macro "draw new circle for background [b]"{
	makeOval(252, 252, 60, 60); //position x, position y, width, heigth
	setTool("oval");
}


macro "analyse intensity dot[a]"{
	run("Measure");
}

macro "analyse intensity nuclear backbround[s]"{
	tempTitle=getTitle();
    tempFluoro=substring(tempTitle,4,6); //only take C2 or C3 as identifier for mChe/GFP, respectively
    tempFile=substring(tempTitle, 7, lengthOf(tempTitle));
    run("Measure");
    setResult("Fluorophore", nResults-1, tempFluoro);
    setResult("Filename", nResults-1, tempFile);
    roiManager("Add");
	run("Clear", "slice");
    //setTool("text");
    count = count + 1;
}


macro "select line dot cortex [d]"{
	setTool("line");
}

macro "close all [q]"{
    Dialog.create ("Save?");
    Dialog.addMessage ("Do you want to close with or without saving?");
    Dialog.addCheckbox("Save", true);
    Dialog.show ();
    runSave = Dialog.getCheckbox();
    if(runSave){saveFile();}
	run("Close All");
	print("image closed:  ", ActiveWindow);
	print("done, "+ count + " cells analyzed from this image.");
	print("");
	count = 0;
}

macro "test names [j]"{
    //ActiveWindow = File.name;
   print(ActiveWindow);
   manualName = getTitle();
   print(manualName);
}

//functions 
function openDVFile(){
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
	
	//print("opened file from current directory: " + getDirectory("current"));
	print("File opened: " + ActiveWindow );
	print("Location: " + getDirectory("current"));
	print("");
	

	//split channels for sum intensity prjections
	run("Set... ", "zoom=constZoom"); 
	
	run("Split Channels"); //change to contraction: all with sum slices, not max intensity!
	selectWindow("C1-"+ ActiveWindow); //brightfield
		run("Z Project...", "projection=[Sum Slices]");
		run("16-bit");
	selectWindow("C2-"+ ActiveWindow);
		run("Z Project...", "projection=[Sum Slices]");//Max Intensity or Sum Slices
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
   	
	
	selectWindow(File.name);
	run("In [+]"); //zoom in to 150%
	//run("In [+]"); //zoom in to 200%
	
	//set oval for measurement
	selectWindow("SUM_C1-" + ActiveWindow); 
	close();
	run("In [+]"); //zoom in to 150%
	//run("In [+]"); //zoom in to 200%
	//run("In [+]"); //zoom in to 300%
	//run("In [+]"); //zoom in to 400%
	selectWindow("SUM_C2-" + ActiveWindow);//SUM_C2-
	run("In [+]"); //zoom in to 150%
	run("In [+]"); //zoom in to 200%
	//run("In [+]"); //zoom in to 300%
	//run("In [+]"); //zoom in to 400%
	//close();
	selectWindow("SUM_C3-" + ActiveWindow);//SUM_C3-	//run("Set... ", "zoom=" + (1*constZoom));
	run("In [+]"); //zoom in to 150%
	run("In [+]"); //zoom in to 200%
	//run("In [+]"); //zoom in to 300%
	//run("In [+]"); //zoom in to 400%
	//makeOval(252, 252, 60, 60); //position x, position y, width, heigth
	//setTool("oval");
    setTool("zoom");
	run("Channels Tool...");
	run("Brightness/Contrast..."); // not really necessary - allows you to adjust brightness
	//run("Scale Bar...", "width=5 height=4 font=14 color=White background=None location=[Lower Right]");
 	String.copy(ActiveWindow);  // Copy WindowID to clipboard
	print(ActiveWindow);
	print("  --> Press 'q' to quit, 'w' to load the next file, or 'o' to open an image.");
    print("Draw a circle of 3x3 pixel to measure at 1200% magnification. Remember to measure for both channels.");
	print("	  --> Press 'a' to measure intensity of the dot.");
	print("	  --> Press 's' to measure intensity of the background and mark the measured cell.");
	print("");
	
}

function saveFile(){
    lengthEnding = lengthOf(File.name);
    lengthStartOfEnd = lengthEnding-6;
    nametest = substring(File.name, lengthStartOfEnd, lengthEnding);
    if (nametest != "D3D.dv"){
        Dialog.create ("manually enter the name");
        Dialog.addMessage ("You opened another file after the image. Please enter the original image file name: ");
        Dialog.addString ("Name:", "");
        Dialog.show ();
        manualName = Dialog.getString();
        ActiveWindow = manualName;
    }
    else{
        selectWindow(File.name);
        ActiveWindow = File.name;
    }
    print(ActiveWindow);
	path1 =  getDirectory("current") + "Analysis\\";
	if (!File.exists(path1)){
		File.makeDirectory(path1);
		write("Folder 'Analysis' created");
	}
    
    
    selectWindow("SUM_C2-" + ActiveWindow);
    roiManager("Show All");
    run("Flatten");
	SaveName1 = "mChe-" + ActiveWindow;
	//***SAVE AS PNG****	
    store_name1 = SaveName1 + ".png";
	saveAs("PNG", path1 + store_name1);
	print("Cropped Tiff saved: " +  store_name1);
    
    
    selectWindow("SUM_C3-" + ActiveWindow);
    roiManager("Show All");
    run("Flatten");
    SaveName2 = "GFP-" + ActiveWindow;
    //***SAVE AS PNG****
    store_name2 = SaveName2 + ".png";
    saveAs("PNG", path1 + store_name2);
    print("Cropped Tiff saved: " +  store_name2);
    roiManager("Delete");
    
}