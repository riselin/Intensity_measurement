var ActiveWindow = "";
var count = 0;
var constZoom = 200; //set zoom (%)
var tempFile;
var tempTitle = "";
var tempFluoro = "";


print("Press 'o' to open a file");

run("Channels Tool...");

macro "open [o]"{
	ActiveWindow = "NA";
	openImage();
}

macro "pick cell [x]"{
    run("Colors...", "foreground=orange background=orange selection=yellow");
    run("Draw", "slice");
    pickCell();
}

macro "draw new circle [a]" {
    makeOval(252, 252, 3, 3); //position x, position y, width, heigth
	setTool("oval");
}

macro "measure intensity [s]"{
    run("Measure");
}

macro "measure background intensity [d]"{
    run("Measure");
    setResult("Fluorophore", nResults-1, tempFluoro);
    setResult("Filename", nResults-1, tempFile);
    run("Colors...", "foreground=black background=black selection=yellow");
	run("Clear", "slice");
}

macro "select line tool [r]" {
    setTool("line");
}

macro "measure length [e]"{
    run("Measure");
}

macro "close picked cell [c]{
    run("Close All");
	print("image closed:  ", ActiveWindow);
	print("done, "+ count + " cells analyzed from this image.");
	print("");
	count = 0;
	print("");
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
    // until here: as macro close all
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
		ActiveWindow = "NA"; 
	}
	print("Next File will been opened");
	openImage();
}

function openImage(){
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
    run("Set... ", "zoom=constZoom");
    
    run("Split Channels"); //change to contraction: all with sum slices, not max intensity!
	selectWindow("C2-"+ ActiveWindow);
		run("Z Project...", "projection=[Sum Slices]");
		run("16-bit");
	selectWindow("C3-"+ ActiveWindow);
		run("Z Project...", "projection=[Sum Slices]");
		run("16-bit");
	

   	// Merge and Set channels for z-stack
   	run("Merge Channels...", "title=" + ActiveWindow + " c1=C1-" + ActiveWindow + " c2=C2-" + ActiveWindow + " c3=C3-" + ActiveWindow + " create");
   	   	Stack.setSlice(5);
		Stack.setChannel(2);
		run("Red");		
		Stack.setChannel(3);
		run("Green");
        Stack.setChannel(1);
		run("Grays");
		Stack.setActiveChannels("111");
    Stack.setChannel(1);
    selectWindow("SUM_C2-" + ActiveWindow);
    run("In [+]"); //zoom in to 150%
	run("In [+]"); //zoom in to 200%
	run("In [+]"); //zoom in to 300%
	run("In [+]"); //zoom in to 400%
    selectWindow("SUM_C3-" + ActiveWindow);
	run("In [+]"); //zoom in to 150%
	run("In [+]"); //zoom in to 200%
	run("In [+]"); //zoom in to 300%
	run("In [+]"); //zoom in to 400%
    makeOval(252, 252, 60, 60);
    setTool("oval");
}

function pickCell(){
    
}

function saveImage(){
}