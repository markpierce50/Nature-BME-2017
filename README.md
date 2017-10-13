# Nature-BME-2017
Image processing Matlab code for in vivo SWIR analysis, 10-13-2017.

For full details see the accompanying paper by Kantamneni et al, Nature Biomedical Engineering (2017)

This repository contains two Matlab scripts for:
1) Selecting regions of interest in pre-clinical SWIR images ("ROI_Processing_V1_Release.m")
2) Applying a false color heatmap overlay of SWIR intensity on top of a white light image
These scripts are separate so that the user can test different heatmap settings without having to re-define ROIs

Also within this repository are four image files for testing the image processing code.

Instructions:
1) Run the ROI_Processing_V1_Release.m file.
2) Load images as instructed (Pre-inject white light, Pre-inject SWIR, Post-inject white light, Post-inject SWIR)
3) Enter the number of regions of interest you wish to analyze
4) Draw your first ROI in the Pre-inject image by clicking the vertices of a polygon shape.  Double click to complete the ROI.  Repeat for additional ROIs.  Draw the same ROIs in the Post-inject image.
This script will perform background subtraction for each ROI and generate a background-corrected Post-inject SWIR image.

5) Run the "Heatmap_Processing_v3.m" file
6) Load the Post-inject white light image and the Post-inject corrected SWIR image
This script will generate a SWIR heatmap image and a SWIR overlay image.  The brightness of the white light and SWIR images can be adjusted within the script.  The colormap can be modified.
