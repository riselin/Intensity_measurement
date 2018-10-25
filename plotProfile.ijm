var ActiveWindow;
var count = 0;
var AnaG1 = 0;
var zoom = 1600; //set zoom (%)
var tempTitle = NaN;
var profile = NaN; //necessary?
var len1 = 0;
var cellcounter = 1;
var fluorophore = "";
var channelValue = 0;
var lineValue = 2;


print("Press 'o' to open the file") 

macro "Set Fluorophore and Line width [f]"{
        //channelValue = Dialog.getNumber("Do you want to measure mCherry (second channel; press '2') \n or do you want to measure GFP (third channel; press '3')?");
        Dialog.create ("Settings for intensity measurement");
	Dialog.addMessage ("Do you want to measure mCherry (second channel; press '2') \nor do you want to measure GFP (third channel; press '3')?\nSet Line Width (Standard: 2)");
	Dialog.addNumber ("Channel:", channelValue); //number 1
	Dialog.addNumber ("Line Width:", lineValue); //number 2
        Dialog.show ();
	channelValue = Dialog.getNumber (); //1
	lineValue = Dialog.getNumber (); //2
        
        if (channelValue == 2){
                fluorophore = "SUM_C2-";
        };
        else if (channelValue == 3){
                fluorophore = "SUM_C3-";
        };
        run("Line Width...", "line="+lineValue);
        print("Channel set to " + fluorophore + " and LineWidth set to "+lineValue);
}

macro "open and set channels [o]"{
        print("Did you set the channels and linewidth?")
	ActiveWindow = "NA";
	openDVFile();
	makeRectangle(519, 500, 45, 45);
	setTool("rectangle");
}


macro "close all [q]"{
	run("Close All");
	print("image closed:  ", ActiveWindow);
	print("done, "+ count + " cells analyzed from this image.");
	print("");
	count = 0;
	
}

macro "close and open next [w]"{
	run("Close All");
	print("image closed:  ", ActiveWindow);
	print("done, "+ count + " cells analyzed from this image.");
	print("");
	count = 0;
	print("");
	print("New file will be opened...");
	print("");
	AWpre = replace(ActiveWindow,"_R3D_D3D.dv",""); //prefix of ActiveWindow plus cellcount
	len = lengthOf(AWpre);
	len = len - 2; //removes the cellcount in the filename (always doubledigit number
	AWpre = substring(AWpre, 0, len);
 	AWend = replace(ActiveWindow,AWpre,""); //removes prefix from active window, leaves cellcount+ending
	AWint = replace(AWend,"_R3D_D3D.dv",""); //removes ending, leaves cellcount
	AWint = parseInt(AWint);
	AWint = AWint +1;
	AWend = "_R3D_D3D.dv";
	if (AWint < 10){
		ActiveWindow = AWpre + "0" + AWint + AWend;
		};
	else if (AWint > 9){	  
		ActiveWindow = AWpre + AWint + AWend;
		};
	//else{
	//	ActiveWindow = "Na";
          //      print("ActiveWindow was set to Na; AWint was not a number ?!");
		//};
	print("Next File will been opened");
	openDVFile();
	makeRectangle(519, 500, 45, 45);
	setTool("rectangle");
}

macro "Macro_saveFiles_cropx [s]"{
	//run("Clear", "slice");
        print(fluorophore+ActiveWindow); //delete as soon as it works
	openSave(count);
	
	tempTitle=getTitle();
	
	run("Set... ", "zoom=" + (1*zoom));
	setTool("line");
	print(tempTitle);
	print("   --> Press 'g' for G1 cell.");
	print("	  --> Press 'a' for Anaphase mother cell.");
	print("	  --> Press 'd' for Anaphase daughter cell.");
	print("   --> Or press 'c' to close and save the values and crop.");
	print("");
}

macro "Macro_analyse intensity in G1 [g]"{
	AnaG1 = 0;
        writeTableContent(cellcounter, AnaG1);


}
macro "Macro_analyse intensity in Ana [a]"{
	AnaG1 = 1;
        writeTableContent(cellcounter, AnaG1);


}

macro "Macro_analyse intensity in Ana [d]"{
	AnaG1 = 2;
        writeTableContent(cellcounter, AnaG1);
	

}

macro "Save values from enlargment, go to next cell [n]"{
        count = count + 1;
        SaveNameM = replace(ActiveWindow,".dv","_Cell_" + count);
	path1 =  getDirectory("current") + "Analysis\\";
	store_nameM = SaveNameM + ".csv";
	saveAs("Measurements", path1 + store_nameM);
	run("Clear Results"); // clear after saving
}


macro "close plots and crops [c]"{
	//close("Temp");
	close("Cell*");
        cellcounter = 0;
        count = count + 1;
	SaveNameM = replace(ActiveWindow,".dv","_Cell_" + count);
	path1 =  getDirectory("current") + "Analysis\\";
	store_nameM = SaveNameM + ".csv";
	saveAs("Measurements", path1 + store_nameM);
	run("Clear Results"); // clear after saving
	makeRectangle(519, 500, 45, 45);
	setTool("rectangle");
}

//functions

function openDVFile(){
	// 20181004
	// Based on A. Meinema's script to set colors/BC to images from 3 channels
	// To crop them with always the same dimensions
	// To save the images in a folder

	len1 = lengthOf(ActiveWindow);
	if (len1 > 10){
		open(ActiveWindow);
		}
	else{
		open();
		ActiveWindow = File.name;
		path =  getDirectory("current");
		};
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	print("File opened: " + ActiveWindow );
	print("Location: " + getDirectory("current"));
	print("");
	//split channels for sum intensity prjections
	run("Set... ", "zoom=95"); 
	// for intensity measurements: use sum slices!
	run("Split Channels");
	selectWindow("C1-"+ ActiveWindow);
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
	selectWindow(File.name);
	run("In [+]"); //zoom in to 150%
	//set oval for measurement
	selectWindow("SUM_C1-" + ActiveWindow);
	close();
	selectWindow("SUM_C2-" + ActiveWindow);
	run("In [+]"); //zoom in to 150%
	selectWindow("SUM_C3-" + ActiveWindow);
	run("In [+]"); //zoom in to 150%
	run("Channels Tool...");
	//run("Brightness/Contrast..."); // not really necessary - allows you to adjust brightness
	run("Scale Bar...", "width=5 height=4 font=14 color=White background=None location=[Lower Right]");
 	String.copy(ActiveWindow);  // Copy WindowID to clipboard
	print(ActiveWindow);
	print("    --> Select cell of interest, press 's' to save the specific cell.");
	print("    --> Or press 'q' to quit, or 'w' to load another file.");
}

function openSave(count){
	
	//print(ActiveWindow)	
	SaveName = replace(ActiveWindow,".dv","_Crop_" + count);
	path1 =  getDirectory("current") + "Analysis\\";
		
	if (!File.exists(path1)){
			File.makeDirectory(path1);
			write("Folder 'Analysis' created");
		}
	run("Duplicate...", "title=Temp");
	selectWindow(fluorophore + ActiveWindow);
	run("Clear", "slice");
	selectWindow("Temp");
	//***SAVE AS TIFF****
	store_name = SaveName + ".tif";
	saveAs("Tiff", path1 + store_name);
	print("Cropped Tiff saved: " +  store_name);
	//Stack.setActiveChannels("011");
	rename("Cell"+count);
	run("In [+]");
	setTool("rectangle");
}

function writeTableContent(setCellcounter, setAnaG1){
        profile = getProfile();
	for (i=0; i<profile.length; i++){
 		setResult("Value", i, profile[i]);
 		setResult("AnaG1", i, setAnaG1);
                setResult("CellID", i, setCellcounter);
                };
        cellcounter = cellcounter + 1
        print("   Press 'c' to close and save the values and crop.");
        print("   Press 'n' if you want to save more from the same enlargement.");
	selectWindow(tempTitle);
}