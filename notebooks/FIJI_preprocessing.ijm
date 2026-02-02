#@ File (label="Input directory", style="directory") input
#@ File (label="Output directory", style="directory") output
#@ String (label="File suffix", value=".tif") suffix

// Function to scan folders recursively
function processFolderAux(dir) {
    processFolder("");
}

function processFolder(dir) {
	fullindir = input + File.separator + dir;
	fulloutdir = output + File.separator + dir;
    list = getFileList(fullindir);
    for (i = 0; i < list.length; i++) {
    	list[i] = replace(list[i], "/", "");
        if(File.isDirectory(fullindir + File.separator + list[i])) {
           File.makeDirectory(fulloutdir + File.separator + list[i]);
           processFolder(dir + File.separator + list[i]);
        }
        if(endsWith(list[i], suffix))
            processFile(dir, list[i]);
    }
}

// Function to process each file
function processFile(dir, file) {
	
	// Extract the name of the file to create a folder with same name
	dot = lastIndexOf(file, ".");    // Find the last dot position
	filename = substring(file, 0, dot);  // Extract the name
	print("filename = " + filename);
 
 	// Check for existence of a folder, if not create
 	folder = fulloutdir + File.separator + filename +  File.separator;
	if (!File.exists(folder)) {
    	File.makeDirectory(folder);
	}

//-------------------------------------------
// Open the image
	fullindir = input + File.separator + dir;
    fulloutdir = output + File.separator + dir;
    run("Bio-Formats Importer", "open=[" + fullindir + File.separator + file + "] autoscale color_mode=Default view=Hyperstack stack_order=XYCZT");
    //open(fullindir + File.separator + file);
    rename("original_image");																				  // [original_image]	


//-------------------------------------------
// Preprocessing of the image - saturation + Gaussian
	selectImage("original_image");
	run("Duplicate...", "title=preprocessed_image");														 // [preprocessed_image] - no CLAHE
	run("Enhance Contrast", "saturated=0.35");              // Enhance the contrast
	run("Gaussian Blur...", "sigma=0.75");                  // Gaussian blur to reduce the noise

// Preprocessing of the image - CLAHE
	run("Duplicate...", "title=preprocessed_image_CLAHE");                                                  
	selectImage("preprocessed_image_CLAHE");	
	run("Enhance Local Contrast (CLAHE)", "blocksize=49 histogram=256 maximum=3 mask=*None* fast_(less_accurate)");    // CLAHE step - makes the results worse on A volume 	
    
    //Save preprocessed image with CLAHE
	saveAs("Tiff", fulloutdir + File.separator + filename +  File.separator + "preprocessed_original.tif");
	rename("preprocessed_image_CLAHE");																		// [preprocessed_image_CLAHE]
	
	
//-------------------------------------------
// Detect mask for a good wood - excluding dark regions
	selectImage("preprocessed_image_CLAHE");
	run("Duplicate...", "title=mask_image_dark");
	
	run("Subtract Background...", "rolling=5 light create");    //run("Subtract Background...", "rolling=10/5 light create"); 5
	//run("Minimum...", "radius=2");
	setAutoThreshold("Otsu dark no-reset");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("8-bit");
	run("Invert");
	run("Gray Morphology", "radius=3 type=circle operator=erode");
 	run("Analyze Particles...", "size=3000.00-Infinity show=Masks display clear overlay add composite record");  // 2500 -> 3000
 	run("Invert LUT");
 	run("Gray Morphology", "radius=3 type=circle operator=dilate");
 	run("Invert");
 	rename("good_wood_mask");																				//  [good_wood_mask]					
 	
	
// Save good wood mask-dark
	selectImage("good_wood_mask");
	run("Duplicate...", "title=good_wood_mask_copy");
    saveAs("Tiff", fulloutdir + File.separator + filename +  File.separator + "nodark_wood_mask.tif");
    close();
    close("good_wood_mask_copy");
	
	
// Save inverse of the background mask 
    selectImage("good_wood_mask");
	run("Duplicate...", "title=good_wood_mask_copy");
	run("Fill Holes");
//	run("Invert");
	saveAs("Tiff", fulloutdir + File.separator + filename +  File.separator + "wood_mask.tif");       // inverse of this would be a background mask
	rename("wood_mask");																					//  [wood_mask]
    close("good_wood_mask_copy");
    

//Save segmentation overlaid on original image
	selectImage("good_wood_mask");
	run("Duplicate...", "title=good_wood_mask_copy");
	run("Analyze Particles...", "display clear overlay add composite record");
	
	selectImage("preprocessed_image");
	run("Duplicate...", "title=preprocessed_image_copy");

	roiManager("Show All without labels");
	run("Flatten");
	saveAs("Tiff", fulloutdir + File.separator + filename +  File.separator + "wood_mask_dark_transparent.tif");
   	close();
	close("preprocessed_image_copy");
	close("good_wood_mask_copy");


////-------------------------------------------
//// Detect mask for a good wood - excluding bright regions
//	selectImage("preprocessed_image_CLAHE");
//	run("Duplicate...", "title=mask_image_bright");

//	//waitForUser("Postprocess the lumen segmentation - remove small objects 2");
//	//run("Enhance Local Contrast (CLAHE)", "blocksize=49 histogram=256 maximum=3 mask=*None* fast_(less_accurate)");
//	run("Subtract Background...", "rolling=10 create");    //run("Subtract Background...", "rolling=10 light create");
//	//run("Minimum...", "radius=2");
//	setAutoThreshold("Yen dark no-reset");
//	setOption("BlackBackground", true);
//	run("Convert to Mask");
//	run("8-bit");
// 	run("Analyze Particles...", "size=1000.00-Infinity show=Masks display clear overlay add composite record");
// 	run("Invert LUT");
// 	run("Duplicate...", "title=mask_image3");
//	run("Duplicate...", "title=mask_image_to_save2");
//	run("Duplicate...", "title=mask_image_to_overlay2");
//	
//	
//// Save wood mask-dark
//	selectImage("mask_image_to_save2");
//    saveAs("Tiff", fulloutdir + File.separator + filename +  File.separator + "wood_mask_bright.tif");
//
////Save segmentation overlaid on original image
//	selectImage("mask_image_to_overlay2");
//	run("Analyze Particles...", "display clear overlay add composite record");
//	selectImage("preprocessed_image");
//	run("Duplicate...", "title=preprocessed_image_copy");
//	selectImage("preprocessed_image_copy");
//	roiManager("Show All without labels");
//	run("Flatten");
//	saveAs("Tiff", fulloutdir + File.separator + filename +  File.separator + "wood_mask_bright_transparent.tif");
//	close();
//	close("preprocessed_image_copy");
//

//-------------------------------------------	
// Local threshold to detect the wood lumen	
	selectImage("preprocessed_image");
	run("Duplicate...", "title=preprocessed_image_copy");
	run("8-bit");
	run("Auto Local Threshold", "method=Sauvola radius=15 parameter_1=0 parameter_2=0 white");
	run("Invert");
	
	selectImage("wood_mask");
	run("Duplicate...", "title=wood_mask_copy");
	run("8-bit");
	
	imageCalculator("AND create", "preprocessed_image_copy", "wood_mask_copy");                                    // or [good_wood_mask_copy] or commented out this to have whole segmentation
	rename("masked_preprocessed_image");                                                           // This is still needed here because otherwise I loose in FIll holes step part of the segmentation so at least the largest component needs to stay
                
	run("Fill Holes");
	run("Gray Morphology", "radius=1 type=circle operator=dilate");
	run("Fill Holes");
	run("Gray Morphology", "radius=1 type=circle operator=erode");
	run("Analyze Particles...", "size=5-Infinity show=Masks display clear overlay add composite record");
	run("Invert LUT");
	run("Invert");
	rename("thresholded_image");                                                                    //  [thresholded_image]
	close("preprocessed_image_copy");
	close("wood_mask_copy");
	

	
	selectImage("thresholded_image");
	run("Duplicate...", "title=local_threshold_image_no_small_regions");
	
	selectImage("thresholded_image");
	run("Duplicate...", "title=long_cell_segmentation");
	
	selectImage("thresholded_image");
	run("Duplicate...", "title=local_threshold_image_to_overlay");
	
	selectImage("thresholded_image");
	run("Duplicate...", "title=local_threshold_image_to_save");
//	waitForUser("Postprocess the lumen segmentation - remove small objects 2");
	
// Save Lumen segmentation
	selectImage("local_threshold_image_to_save");
	run("8-bit");
	run("Invert");
	saveAs("Tiff", fulloutdir + File.separator + filename +  File.separator + "segmentation.tif");
//waitForUser("Postprocess the lumen segmentation - remove small objects 2");

//Long cell segmentation
	selectImage("long_cell_segmentation");
	run("Invert");
	
	// 1) Measure all particles including AR
	run("Set Measurements...", "area fit shape redirect=None decimal=3");
	run("Analyze Particles...", "size=5-Infinity circularity=0.00-0.5 show=Nothing display clear add");
	
	// 2) Filter ROIs by AR threshold and build a mask
	minAR = 2.0; // adjust threshold for "elongated"
	n = nResults;
	run("Select None");
	newImage("elongated", "8-bit black", getWidth(), getHeight(), 1);
	
	for (i = 0; i < n; i++) {
	    ar = getResult("AR", i);
	    if (ar >= minAR) {
	        roiManager("Select", i);
	        run("Fill");
	    }
	}
	selectWindow("elongated");

//	waitForUser("Postprocess the lumen segmentation - remove small objects 2");
	//run("Analyze Particles...", "size=100-Infinity circularity=0.00-0.30 show=Masks");
	//run("Invert LUT");
	//run("Invert");
	run("8-bit");
	rename("long_cells");

	selectImage("good_wood_mask");
	run("Duplicate...", "title=good_wood_mask_copy");
	imageCalculator("AND create", "long_cells", "good_wood_mask_copy");                                    // commented out this to have whole segmentation         
	saveAs("Tiff", fulloutdir + File.separator + filename +  File.separator + "long_cells2.tif");
	close("good_wood_mask_copy");

//Save lumen segmentation on original image
	selectImage("local_threshold_image_to_overlay");
	run("Analyze Particles...", "display clear overlay add composite record");
	
	selectImage("preprocessed_image");
	run("Duplicate...", "title=preprocessed_image_copy");
	selectImage("preprocessed_image_copy");
	roiManager("Show All without labels");
	run("Flatten");
	saveAs("Tiff", fulloutdir + File.separator + filename +  File.separator + "segmentation_on_input_transparent.tif");
	close();
	close("preprocessed_image_copy");
//-------------------------------------------

//// Create and save late wood segmentation
//	
//	selectImage("preprocessed_image");
//	run("Duplicate...", "title=preprocessed_image_copy");

//	run("Gaussian Blur...", "sigma=30");                  // Gaussian blur to reduce the noise
//	run("8-bit");
//	setAutoThreshold("Otsu dark no-reset");
//	run("Convert to Mask");
//	saveAs("Tiff", fulloutdir + File.separator + filename +  File.separator + "late_wood_segmentation.tif");
//	close();
//	close("preprocessed_image_copy");

//// Create and save ring segmentation
//	selectImage("preprocessed_image_CLAHE");
//	run("Duplicate...", "title=mask_ring");
//	//waitForUser("Postprocess the lumen segmentation - remove small objects 2");
//	run("Gaussian Blur...", "sigma=30");
//	run("Find Edges");
//	run("Enhance Contrast...", "saturated=0.35");
//	//setAutoThreshold("Huang dark no-reset");
//	//run("Convert to Mask");
//	//run("8-bit");
//	saveAs("Tiff", fulloutdir + File.separator + filename +  File.separator + "ring_segmentation.tif");
	
	
green_flag = 1;
if (green_flag==1) {		
//-------------------------------------------
// --- Watershed - excluding small regions - seeds only on large cells
	selectImage("thresholded_image");
	run("Duplicate...", "title=thresholded_image_copy");
	run("Invert");
	run("8-bit");
	run("Analyze Particles...", "size=350-infinity pixel circularity=0.00-1.00 show=Masks"); //0-2000, 0.5-1.0
	run("Invert LUT");	
	run("Invert");
	
	run("Distance Map");
	run("Enhance Contrast", "saturated=0.35");
	saveAs("Tiff", fulloutdir + File.separator + filename +  File.separator + "DT_on_removed_small_regions.tif");
	rename("distance_map");
	close("thresholded_image_copy");

// --- Watershed - normal - seeds on cell regions	
//	selectImage("thresholded_image");
//	run("Duplicate...", "title=thresholded_image_copy");
//	run("Invert");
//	run("8-bit");
//	run("Analyze Particles...", "size=0-2000 pixel circularity=0.5-1.00 show=Masks"); //0-2000, 0.5-1.0
//	run("Invert LUT");	
//	run("Invert");
//	
//	run("Distance Map");
//	run("Enhance Contrast", "saturated=0.35");
//	saveAs("Tiff", fulloutdir + File.separator + filename +  File.separator + "DT_on_cell_regions.tif");
//	rename("distance_map");
//	close("thresholded_image_copy");

	
    run("Classic Watershed", "input=[distance_map] mask=None use min=0 max=255");
    rename("watershed_image");
   

// Save watershed as a binary image
	selectImage("watershed_image");
	run("Duplicate...", "title=watershed_image_to_save");
    run("8-bit");
	setAutoThreshold("Default dark no-reset");
	setThreshold(1, 255);
	run("Threshold...");
	run("Convert to Mask");
	run("Duplicate...", "title=watershed_image_to_save1");
	saveAs("Tiff", fulloutdir + File.separator + filename +  File.separator + "cell_segmentation.tif");

// Save watershed as a binary image - remove large cells and elongated cells
	selectImage("watershed_image_to_save");
	run("Analyze Particles...", "size=0-5000 pixel circularity=0.00-1.00 show=Masks display clear overlay add composite record"); //0-2000, 0.5-1.0
	run("Invert LUT");

	run("Duplicate...", "title=watershed_image_to_overlay");
	selectImage("Mask of watershed_image_to_save");
    saveAs("Tiff", fulloutdir + File.separator + filename +  File.separator + "good_cell_mask.tif");
  //  waitForUser("Clean the segmentation and continue processing2");
    


//-------------------------------------------
// Create wall segmentation by overlaying lumen and cell segmentation


//    selectImage("preprocessed_image");
//	run("Duplicate...", "title=preprocessed_image_copy");
//	selectImage("preprocessed_image_copy");
	selectImage("thresholded_image");
	run("Duplicate...", "title=thresholded_image_copy");
	
    imageCalculator("AND create 32-bit", "thresholded_image_copy", "watershed_image");
    run("6 shades");
    run("8-bit");
    rename("wall_segmentation");
    close("thresholded_image_copy");
   
// Overlay wall segmentation on the original image
	selectImage("original_image");
    run("Duplicate...", "title=original_image_copy");
    
	selectImage("wall_segmentation");																// * wall_segmentation
	run("8-bit");
	setAutoThreshold("Default dark no-reset");
	setThreshold(1, 255);
	run("Threshold...");
	run("Convert to Mask");
	
	selectImage("wall_segmentation");
	run("Duplicate...", "title=wall_segmentation_copy");
	selectImage("wall_segmentation_copy");
	imageCalculator("AND create", "wall_segmentation_copy", "original_image_copy");
	rename("wall_segmentation_on_original_image");
	run("8-bit");
	saveAs("Tiff", fulloutdir + File.separator + filename +  File.separator + "wall_segmentation_on_original_image.tif");
	close();
	close("wall_segmentation_copy"); 
	close("original_image_copy");
	
	
// Saving the wall segmentation
	selectImage("wall_segmentation");
	run("Duplicate...", "title=wall_segmentation_copy");
	selectImage("wall_segmentation_copy");
    saveAs("Tiff", fulloutdir + File.separator + filename +  File.separator + "wall_segmentation.tif");
    close(); 
    close("wall_segmentation_copy");

    
	
	selectImage("watershed_image_to_overlay");
	run("Analyze Particles...", "display clear overlay add composite record");
	
	selectImage("original_image");
    run("Duplicate...", "title=original_image_copy");
	selectImage("original_image_copy");
	roiManager("Show All without labels");
	run("Flatten");
	saveAs("Tiff", fulloutdir + File.separator + filename +  File.separator + "cell_on_input_transparent.tif");
	close();
	close("watershed_image_to_overlay"); 
	close("original_image_copy");
	
// Saving the wall segmentation on 
	selectImage("wall_segmentation");
	run("Duplicate...", "title=wall_segmentation_copy");
	selectImage("wall_segmentation_copy");
	run("Analyze Particles...", "display clear overlay add composite record");
	
	selectImage("original_image");
    run("Duplicate...", "title=original_image_copy");
	selectImage("original_image_copy");
	roiManager("Show All without labels");
	run("Flatten");
	saveAs("Tiff", fulloutdir + File.separator + filename +  File.separator + "wall_on_input_transparent.tif");
	close();
	close("wall_segmentation_copy"); 
	close("original_image_copy");
}	
	//waitForUser("Look at the resulting images, then click OK to continue on the next image.");

// CLose all the windowslucia.rossova@gmail.com 
	 while (nImages>0) { 
          selectImage(nImages); 
          close(); 
      } 
      
      if (isOpen("ROI Manager")) {
    	selectWindow("ROI Manager");
    	run("Close");
		}
      if (isOpen("Log")) {
    	selectWindow("Log");
    	run("Close");
		}
	  if (isOpen("Results")) {
    	selectWindow("Results");
    	run("Close");
		}
      if (isOpen("Threshold")) {
    	selectWindow("Threshold");
    	run("Close");
		}		
	  if (isOpen("Console")) {
    	selectWindow("Console");
    	run("Close");
		}
//	saveAs("Tiff", fulloutdir + File.separator + file + "_proc");
//    close();

}

// Run the macro
org_input = input;
processFolderAux(input);
