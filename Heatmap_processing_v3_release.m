%% Heatmap generation and overlay for SWIR Images

clear all; close all; clc;

SWIR_min = 20;                              % Set the min/max range of pixel values for the colormap
SWIR_max = 200;                             % Reduce SWIR_max to highlight weak SWIR signal

White_min = 0;                              % 
White_max = 130;                            % If the white light image is too bright, increase this value

Add_colorbar = 1;                           % 0 or 1 to include colorbar in heatmap image
load('MyColormap','mycmap');                % Load colormap

[FileName1,PathName1] = uigetfile('*.tif','Post-Inject White Light');
White_Post = imread(FileName1);

[FileName2,PathName2] = uigetfile('*.tif','Post-Injection Corrected SWIR ');
SWIR_Post = imread(FileName2);
[token, remain] = strtok(FileName2,'.');


% Step 1:  Apply a color map to the processed SWIR image
figure; imshow(SWIR_Post);                      
colormap(hot);                              % Choose the colormap
set(gca,'CLim',[SWIR_min SWIR_max]);        
set(gcf,'Colormap',mycmap);
 
cmap_image = getframe;          
cmap_image.cdata(:,end,:) = [];
cmap_image.cdata(end,:,:) = [];
close(gcf);


% Step 2:  Overlay the colormapped SWIR image onto the white light image
White_Post = uint8((White_Post-2^15)/128);                
figure; imshow(White_Post,[White_min,White_max]);         
hold on;                             

hImg = imshow(cmap_image.cdata(1:size(SWIR_Post,1),1:size(SWIR_Post,2),:));            % Show the color-mapped SWIR image in the same axis
set(hImg,'AlphaData',uint8(SWIR_Post));     % Use the SWIR intensity values to define transparency 
alim([1 2]);                                % SWIR pixels < 1 are transparent, > 3 opaque - keep fixed

cmap_image = getframe;              
imwrite(cmap_image.cdata,[token '_Overlay.tif'],'tif','Compression','none'); 
                                            % Save the overlay image (8-bit RGB)
                                          
figure; imshow(SWIR_Post);                      
colormap(hot); 
set(gca,'CLim',[SWIR_min SWIR_max]);                   
set(gcf,'Colormap',mycmap); 

cmap_image = getframe;              
cmap_image.cdata(:,end,:) = [];
cmap_image.cdata(end,:,:) = [];   

if Add_colorbar == 1
    colorbar;
    saveas(gcf, [token '_Heatmap.tif'], 'tiffn')
else
    imwrite(cmap_image.cdata,[token '_Heatmap.tif'],'tif','Compression','none'); 
                                            % Save the color-mapped SWIR image (8-bit RGB)
end
 

                                            