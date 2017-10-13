%% ROI selection and background subtraction For SWIR Images

clear all; close all; clc;
s = pwd;


%% Open image files: 

[FileName1,PathName] = uigetfile('*.tif','Pre-Inject White Light');
WL_Pre = imread(FileName1);
WL_Pre = uint8((WL_Pre-2^15)/128);

[FileName2] = uigetfile('*.tif','Pre-Inject SWIR');
SWIR_Pre = imread(FileName2);
[pretoken, remain] = strtok(FileName2,'.'); 

[FileName3] = uigetfile('*.tif','Post-Inject White Light');
WL_Post = imread(FileName3);
WL_Post = uint8((WL_Post-2^15)/128);

[FileName4] = uigetfile('*.tif','Post-Inject SWIR');
SWIR_Post = imread(FileName4);
[token, remain2] = strtok(FileName4,'.'); 

n = input('Select # of regions to analyze: ');


%% ROI Selection on PRE-injection images:

for i = 1:n                                     % Loop through n ROI's
    figure('Name',['Pre-inject, ROI #',num2str(i)]); imshow(WL_Pre,[0,150]);          
    [mask,xi,yi] = roipoly;                     % Allow user to select an ROI 
    hold on;                            
    plot(xi,yi,'r-','LineWidth',2);                   

    Pre_Roi_mean(i) = mean(SWIR_Pre(mask));     % Store the mean pixel value for each ROI 
end


%% ROI Selection on POST-injection images:

for i = 1:n                             
    figure('Name',['Post-inject, ROI #',num2str(i)]); imshow(WL_Post,[0,150]);         
    [mask,xi,yi] = roipoly;             
    hold on; 
    plot(xi,yi,'b-','LineWidth',2);                   
    
    Not_mask(:,:,i) = ~mask;          
                                                % Create an array containing only the mean background level for that ROI
    SWIR_inj_roi = zeros(size(SWIR_Post,1),size(SWIR_Post,2)) + Pre_Roi_mean(i);     
    Post_Roi_mask(:,:,i) = SWIR_inj_roi.*mask;  % Set elements outside the mask to zero, retain values within ROI
       
    Post_Roi_mean(i) = mean(SWIR_Post(mask));       % Store the mean pixel value within the POST SWIR ROI
    Post_Roi_max(i) = max(SWIR_Post(mask(:)));      % Store the max pixel value within the ROI
end


%% Write an Excel file with information for the post-injection SWIR image. 

Param_list1 = {'Filename:', FileName4; 'Processed on:', datestr(clock)};      

xlswrite([token, '_metrics'], Param_list1,'metrics1','A1');                  
xlswrite([token, '_metrics'], {'ROI #:'},'metrics1','A4');
xlswrite([token, '_metrics'], (1:n)', 'metrics1','A5'); 
xlswrite([token, '_metrics'], {'Mean Post ROI Values:'},'metrics1','B4');          
xlswrite([token, '_metrics'], Post_Roi_mean', 'metrics1', 'B5');         
xlswrite([token, '_metrics'], {'Mean Pre ROI Values:'},'metrics1','C4');      
xlswrite([token, '_metrics'], Pre_Roi_mean', 'metrics1','C5');
xlswrite([token, '_metrics'], {'Mean Corrected ROI Values:'}, 'metrics1', 'D4');   
xlswrite([token, '_metrics'], (Post_Roi_mean-Pre_Roi_mean)', 'metrics1','D5');
xlswrite([token, '_metrics'], {'Max pixel values:'}, 'metrics1', 'E4');       
xlswrite([token, '_metrics'], Post_Roi_max', 'metrics1','E5');


%% Subtract mean PRE-inject pixel value from POST-inject values in each ROI 

Final_Roi_mask = max(Post_Roi_mask,[],3);                      % Merge all ROI masks into a single 2-D array
Back_sub = imsubtract(double(SWIR_Post), Final_Roi_mask);      % Subtract the PRE inject ROI mean values from from ROIs in the POST image                        


%% Subtract the background pixel values for pixels OUTSIDE of the ROIs

Min_Not_mask = min(Not_mask,[],3);             % Merge the masks of inverted image into a single 2-D array storing minimum values to keep zeros within ROI. 
Invert = uint16(Min_Not_mask).*SWIR_Post;      % Multiply SWIR_Post with the inverted mask image to yield zeros inside ROIs and SWIR_Post values outside. 
I = imsubtract(Back_sub,double(Invert));       % Subtract original background subtraction image from inverted mask image. 

imwrite(uint16(I),[token,'_Corrected.tif'],'tif','Compression','none');

figure; imshow(I,[0 512]); 

%%

