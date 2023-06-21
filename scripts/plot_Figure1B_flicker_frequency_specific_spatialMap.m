%% The function plots the spatial map in Figure 1B
% The script was used to generate Figure 1B in manuscript
% "Brain rhythms control microglial response and cytokine expression via NFκB signaling"

% Plots are generated in a new folder named 'plots' in the parent directory

%% Plot spatial map of power difference for 20 Hz flicker and 40 Hz flicker, respectively
plot_flicker_frequency_specific_spatialMap(20) % for plotting 20 Hz map
plot_flicker_frequency_specific_spatialMap(40) % for plotting 40 Hz map

function plot_flicker_frequency_specific_spatialMap(selectedFrequency)
% font and line size
axis_font = 7;
label_font = 7;
% Animal ID to plot
AnimalID = "EMXJ21";

area = 2500; % 50 x 50 pixels
%% Load calculated power difference between stim and baseline
% create a folder to save the output files
currentFolder = mfilename('fullpath'); % determine the filepath based on where the script locates
scriptFN = mfilename;
filePath = erase(erase(currentFolder, scriptFN), strcat('scripts', filesep));
savePath = strcat(filePath, filesep, 'plots', filesep, 'Figure1B', filesep);

if ~isfolder(savePath)
    mkdir(savePath)
end

searchPath = strcat(filePath, filesep, 'data', filesep, 'Figure1B_powerDifference');
searchTerm = strcat(AnimalID , '*', string(selectedFrequency), 'Hz*.mat');        
titleStr = strcat(string(selectedFrequency), "Hz LED stimulation");

filelist = dir(fullfile(searchPath, '**', searchTerm));

%% Load file and calculate average
sumPowerDifference = zeros(area, length(filelist)); % pre-allocate data
for fileN = 1:length(filelist)
    fullFileName = strcat(filelist(fileN).folder, '\', filelist(fileN).name);
    load(fullFileName, 'powerDifference'); % load power difference from the file
    sumPowerDifference(:, fileN) = powerDifference;
end

meanPowerDifference = mean(sumPowerDifference, 2);
%% Plot the averaged power difference
reshapePowerAtFreq = reshape(meanPowerDifference, 50, 50); %reshape the image
resizeI_no_mask = imresize(reshapePowerAtFreq, 2); % resize to 100 x 100

figure
% Plot masked image
imagesc(resizeI_no_mask)
axis off;
colormap('hot')

% Setscale to desired range
% The scale is kept the same for 20 Hz and 40 Hz for comparison
caxisMax = 10; % maximum value determined previous with masked image
caxisMin = -1.8; % minimum value determined previous with masked image
caxis([caxisMin, caxisMax]);
c = colorbar;

parString = strcat("at ", string(selectedFrequency), " Hz (dB");
c.Label.String = strcat("Power spectral density difference" + newline + parString); % would be dB/Hz if it's pds
c.Label.FontSize = axis_font;
ax = gca;
ax.FontSize = label_font;
title(titleStr, 'FontSize', label_font)

set(gcf,'units', 'centimeters', 'Position',[30,1,6,4.5]);
imgName = strcat(AnimalID, '_Mean_', string(selectedFrequency), 'Hz_power_difference_10dB_max');
imgName = strcat(savePath, imgName);
% 
savefig(imgName)
saveas(gcf,imgName, 'jpg')  
saveas(gcf, imgName, 'pdf') % the pdf file is further masked on illustrator

close all
end