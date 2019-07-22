var ActiveWindow;
var count = 0;
var AnaG1 = NaN;
var zoom = 200; //set zoom (%)
var tempTitle = NaN;
var fileTitle = "";
var fileCount = 0;
var filelist = "";

macro "open [o]"{
    pathImages = getDirectory("Choose directory...");
    filelist = getFileList(pathImages);
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

macro "Scratch that cell [s]"{
    setResult(ActiveWindow + "_" + count, 0, ActiveWindow); //col, row, content
    setResult(ActiveWindow + "_" + count, 1, "removeCell");
    setResult(ActiveWindow + "_" + count, 2, 0);
    setResult(ActiveWindow + "_" + count, 3, 0);
    setResult(ActiveWindow + "_" + count, 4, 0);
    setResult(ActiveWindow + "_" + count, 5, 0);
    setResult(ActiveWindow + "_" + count, 6, 0);
    count++;
    fileCount++;
}

macro "Macro_analyse distance in G1 [g]"{
	AnaG1 = 0;
	analyse(count);
	print("   Press 'w' for next cell.");
	print("   Press 'q' to close everything.");
	count++;
    fileCount++;
	print(count);
}

macro "Macro_analyse distance in Ana [a]"{
	AnaG1 = 1;
    tempTitle=getTitle();
	analyse(count);
    selectWindow(tempTitle);
	print("   Press 'q' to close everything.");
	count++;
	print(count);
}

macro "Macro_analyse distance in Ana [d]"{
	
	AnaG1 = 2;
	analyse(count);
	print("   Press 'w' for next cell.");
	print("   Press 'q' to close everything.");
	count++;
    fileCount++;
	print(count);
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
	
	//set rectangle for Cropping
	selectWindow("Composite");
	makeRectangle(40, 40, 10, 10);
	setTool("rectangle");
	print(ActiveWindow);
	print("   --> Select mother cell. Press 'g' for G1 cell.");
	print("	  --> Press 'm' for Metaphase cell.");
	print("	  --> Press 'e' for early Anaphase cell.");
	print("	  --> Press 'a' for Anaphase mother cell.");
	print("	  --> Press 'd' for Anaphase daughter cell.");
	print("	  --> Press 't' for post-Anaphase cell.");
	print("    --> Or press 'f' to remove a value from the results windowo.");
	print("    --> Or press 'q' to quit, or 'w' to load another file.");
}


function analyse(count){
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
    getSelectionBounds(x, y, w, h); 
    toScaled(x, y);
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
	x_mCh = x;
	y_mCh = y;
	run("Draw");
	
	d_x = x_GFP - x_mCh;
	d_y = y_GFP - y_mCh;

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

setResult(ActiveWindow + "_" + count, 0, ActiveWindow); //col, row, content
setResult(ActiveWindow + "_" + count, 1, AnaG1);
setResult(ActiveWindow + "_" + count, 2, x_GFP);
setResult(ActiveWindow + "_" + count, 3, y_GFP);
setResult(ActiveWindow + "_" + count, 4, x_mCh);
setResult(ActiveWindow + "_" + count, 5, y_mCh);
setResult(ActiveWindow + "_" + count, 6, d);
updateResults;	
}	