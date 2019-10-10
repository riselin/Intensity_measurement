

var ActiveWindow;
var count = 0;
var AnaG1 = NaN;
var zoom = 200; //set zoom (%)
var tempTitle = NaN;


print("Press 'o' to open the file") 

macro "open and set channels [o]"{
	ActiveWindow = "NA";
	openDVFile();
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
		
	//print("Next file is:   "+ActiveWindow);
	
	print("Next File will been opened");
	
	//run("Open Next")
	openDVFile();


	
}

macro "re do, aka fuck'it [f]"{

               setResult(ActiveWindow + "_" + count, 0, NaN);
               setResult(ActiveWindow + "_" + count, 1, NaN);
               setResult(ActiveWindow + "_" + count, 2, NaN);
               setResult(ActiveWindow + "_" + count, 3, NaN);
               setResult(ActiveWindow + "_" + count, 4, NaN);
               setResult(ActiveWindow + "_" + count, 5, NaN);
                              
               count = count - 1;

               //print(count);
               //Prepare image for new round of analysis
               close("Temp");
               close("cell*");
               
               //Prepare image for new round of analysis
               selectWindow("Composite");
               makeRectangle(519, 500, 45, 45);
               setTool("rectangle");
               
               print("Cell ID is reset, cell count of next cell will be " + count+1);
               print("Data is removed from table");
               print("");
}


macro "Macro_saveFiles_cropx [s]"{
	
	//print("macro1, count is: ", count) 
	//print("")
	
	//run function
	openSave(count);
	tempTitle=getTitle();
	print(tempTitle);
	print("   --> Select mother cell. Press 'g' for G1 cell.");
	print("	  --> Press 'm' for Metaphase cell.");
	print("	  --> Press 'e' for early Anaphase cell.");
	print("	  --> Press 'a' for Anaphase mother cell.");
	print("	  --> Press 'd' for Anaphase daughter cell.");
	print("	  --> Press 't' for post-Anaphase cell.");
	print("   --> Or press 'c' for next cell.");
	print("");
	};

macro "Macro_analyse distance in G1 [g]"{
	
	AnaG1 = 0;
	analyse(count);
	print("   Press 'c' for next cell.");
	print("   Press 'w' for new image.");
	print("   Press 'q' to close everything.");
	count = count + 1;
	print(count);
}

macro "Macro_analyse distance in Ana [a]"{
	
	AnaG1 = 1;
	analyse(count);
	print("   Press 'c' for next cell.");
	print("   Press 'w' for new image.");
	print("   Press 'q' to close everything.");
	selectWindow(tempTitle);
	count = count + 1;
	print(count);
}

macro "Macro_analyse distance in Ana [d]"{
	
	AnaG1 = 5;
	analyse(count);
	print("   Press 'c' for next cell.");
	print("   Press 'w' for new image.");
	print("   Press 'q' to close everything.");
	count = count + 1;
	print(count);
}

macro "Macro_analyse distance in early Ana [e]"{
	
	AnaG1 = 2;
	analyse(count);
	print("   Press 'c' for next cell.");
	print("   Press 'w' for new image.");
	print("   Press 'q' to close everything.");
	count = count + 1;
	print(count);
}

macro "Macro_analyse distance in Metaphase [m]"{
	
	AnaG1 = 3;
	analyse(count);
	print("   Press 'c' for next cell.");
	print("   Press 'w' for new image.");
	print("   Press 'q' to close everything.");
	count = count + 1;
	print(count);
}

macro "Macro_analyse distance in post-Anaphase [t]"{
	
	AnaG1 = 4;
	analyse(count);
	print("   Press 'c' for next cell.");
	print("   Press 'w' for new image.");
	print("   Press 'q' to close everything.");
	count = count + 1;
	print(count);
}

macro "close plots and crops [c]"{
	close("Temp");
	close("Cell*");
		
	
	//Prepare image for new round of analysis
	selectWindow("Composite");
	makeRectangle(519, 500, 45, 45);
	setTool("rectangle");
}




//functions 


function openDVFile(){
	//140901
	//
	// PART 1
	//
	//	Script/macro to set colors/BC to images from 3 channels
	//	To crop them with always same dimensions
	//	To save the images in a folder: <current/JPGs>
	//	From each stack, a croped image from the Br, GFP, mCh channel will be saved
	//
	// Anne Meinema
	//
	//********************start*************
	// ****OPEN FILE****


	
	len1 = lengthOf(ActiveWindow);
	//print("test1   " + len1);
	//print(ActiveWindow);
	
	if (len1 > 10){
		open(ActiveWindow);
		//print("test2");
		}
	else{
		open();
		ActiveWindow = File.name;
		path =  getDirectory("current");
		//print("test3");
		};

	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	//print("...."+year + "-" + month + "-" + dayOfMonth + "  " + hour + ":" + minute + ":" + second);
	
	//print("opened file from current directory: " + getDirectory("current"));
	print("File opened: " + ActiveWindow );
	print("Location: " + getDirectory("current"));
	print("");
	

	//split channels for max and sum intensity prjections
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
	
	//set rectangle for Cropping
	selectWindow("Composite");
	makeRectangle(222, 236, 41, 41);
	setTool("rectangle");
	
	
 	String.copy(ActiveWindow);  // Copy WindowID to clipboard

	count = 0;		// set count back to 0
	//print("count is set: ", count) 
	

	print(ActiveWindow);
	print("    --> Select cell of interest, press 's' to save the specific cell.");
	print("    --> Or press 'f' to remove a value from the results windowo.");
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

		
	run("Duplicate...", "title=Temp duplicate channels=1-3 slices=1-10");
	
		run("In [+]");
		run("In [+]");
		selectWindow("Composite");
		Stack.setChannel(2);
		run("Clear", "slice");
		Stack.setChannel(3);
		run("Clear", "slice");
	
	//print("... image successfully cropped     '" + ActiveWindow + "'    _Crop" + count);
		
	
	selectWindow("Temp");
	
	
	//***SAVE AS TIFF****
	
	store_name = SaveName + ".tif";
	saveAs("Tiff", path1 + store_name);
	print("Cropped Tiff saved: " +  store_name);

	
	Stack.setActiveChannels("011");
	rename("Cell"+count);
	run("In [+]");
	setTool("rectangle");
}




function analyse(count){	

	//SaveName = replace(ActiveWindow,".dv","_Crop_" + count);
	
	run("Duplicate...", "title=Temp duplicate channels=1-3");
			run("In [+]");
			run("In [+]");
			run("In [+]");
			run("In [+]");
			Stack.setActiveChannels("011");
				
	Stack.setChannel(3);
	run("Select None");
	getRawStatistics(nPixels, mean, min, max); 
    run("Find Maxima...", "noise="+max+" output=[Point Selection]"); 
    //run("Find Maxima...", "noise="+max+" output=List");
    //print(x);
    getSelectionBounds(x, y, w, h); 
    toScaled(x, y);
    //print("coordinates GFP=("+x+","+y+"), value="+getPixel(x,y)); 
	//toScaled(x, y);
	x_GFP = x;
	y_GFP = y;
	setForegroundColor(1, 1, 1);
	run("Draw");
	print("");

	Stack.setChannel(2);
	run("Select None");
	getRawStatistics(nPixels, mean, min, max); 
    run("Find Maxima...", "noise="+max+" output=[Point Selection]"); 
    getSelectionBounds(x, y, w, h); 
    toScaled(x, y);
    //print("coordinates mCh=("+x+","+y+"), value="+getPixel(x,y)); 
	x_mCh = x;
	y_mCh = y;
	//print(x_mCh);
	run("Draw");
	
	d_x = x_GFP - x_mCh;
	d_y = y_GFP - y_mCh;

	//print(d_x);
	//print(d_y);
	d = sqrt(pow(d_x,2) + pow(d_y,2));

	if (AnaG1 == 0){
			print("distance between dots in G1 cell is " + d +" um.");
		}
	if (AnaG1 == 1){
			print("distance between dots in Anaphase cell is " + d +" um.");
		}
	if (AnaG1 == 2){
			print("distance between dots in early Anaphase cell is " + d +" um.");
		}
	if (AnaG1 == 3){
			print("distance between dots in Metaphase cell is " + d +" um.");
		}	
	if (AnaG1 == 4){
			print("distance between dots in post-Anaphase cell is " + d +" um.");
		}	
	if (AnaG1 == 5){
			print("distance between dots in Anaphase daughter cell is " + d +" um.");
		}			

setResult(ActiveWindow + "_" + count, 0, AnaG1); //col, row, content
setResult(ActiveWindow + "_" + count, 1, x_GFP);
setResult(ActiveWindow + "_" + count, 2, y_GFP);
setResult(ActiveWindow + "_" + count, 3, x_mCh);
setResult(ActiveWindow + "_" + count, 4, y_mCh);
setResult(ActiveWindow + "_" + count, 5, d);
updateResults;	



}	

