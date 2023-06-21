%% The function plots the mean V1 traces in Figure 1S
% The script was used to generate Figure 1S in manuscript
% "Brain rhythms control microglial response and cytokine expression via NFκB signaling"

% Plots are generated in a new folder named 'plots' in the parent directory
plot_mean_trace(20)
plot_mean_trace(40)

function plot_mean_trace(selectedFrequency)
axis_font = 7;
label_font = 7;

duration = 20.48;
IMG_sampleRate = 200;
IMG_x = 0:(1/IMG_sampleRate):(duration - 1/IMG_sampleRate);

% create a folder to save the output files
currentFolder = mfilename('fullpath'); % determine the filepath based on where the script locates
scriptFN = mfilename;
filePath = erase(erase(currentFolder, scriptFN), strcat('scripts', filesep));
savePath = strcat(filePath, filesep, 'plots', filesep, 'Figure1S', filesep);

if ~isfolder(savePath)
    mkdir(savePath)
end

%% Find list of files 

searchPath = strcat(filePath, filesep, 'data', filesep, 'Figure1B_V1_traces');
searchTerm = strcat('*', string(selectedFrequency), '_*.mat');

filelist = dir(fullfile(searchPath, '**', searchTerm));

%% Load and concatenate files into one structure array 

for fileN = 1:length(filelist)
    fullFN = strcat(filelist(fileN).folder, '\', filelist(fileN).name);
    load(fullFN, 'v1_traces')
    
    if fileN == 1
        V1_allMice = v1_traces;
    else
        V1_allMice = [V1_allMice, v1_traces];
    end

end


%% all traces from V1
%%
LEDonsetTimes = [V1_allMice.AP_onsetT];
LEDoffsetTimes = [V1_allMice.AP_offsetT];
onsetInd = size(length(LEDonsetTimes), 1);
for trialN = 1:length(LEDonsetTimes)
    onsetInd(trialN, 1) = find(IMG_x >= LEDonsetTimes(trialN), 1, 'first');
%     offsetInd(trialN, 1) = find(IMG_x > LEDoffsetTimes(trialN), 1, 'first');
end
onsetIndexAll = mode(onsetInd);
% offSetIndexAll = mode(offsetInd);
all_v1_traces = - [V1_allMice.regressed_g];

shift_x = -0.05;
shift_y = -1;

shiftImg_x = IMG_x - IMG_x(onsetIndexAll);
plot(shiftImg_x, mean(all_v1_traces, 2) * 100);

hold on

x_axis_txt_pos = [0.05, -0.15];
y_axis_txt_pos = [-0.05, -0.1];

%plot scale bars for dff
plot([0; 0.1] + shift_x, [-0.2; -0.2] + shift_y, '-k', 'LineWidth', 0.75)
plot([0; 0] + shift_x, [-0.2; 0.3] + shift_y, '-k', 'LineWidth', 0.75)
%label scale bars
text(x_axis_txt_pos(1), x_axis_txt_pos(2), '0.1 s', 'HorizontalAlignment','center', 'FontSize', label_font)
text(y_axis_txt_pos(1), y_axis_txt_pos(2), {'0.5 %', 'dF/F'}, 'HorizontalAlignment','center', 'FontSize', label_font)
% Add vertical line indicating onset and off set of flicker
xl1 = xline(0,'k', {strcat(string(selectedFrequency), " Hz onset")}, 'LineStyle', ':', 'LineWidth', 1, 'Fontsize', label_font);


xl1.LabelHorizontalAlignment = 'left';


xlim([-0.2, 1])
ylim([-2.5, 0.5])

ax = gca;
ax.FontSize = axis_font; 


xlabel('Time (s)', 'FontSize', 7)
ylabel('dF/F %', 'FontSize', 7)
set(gca,'box','off')

set(gca, 'Visible', 'off')

set(gcf,'units', 'centimeters', 'Position',[10,1,6.2,3]);
imgName = strcat(savePath, 'Mean_trace_6mice_', string(selectedFrequency), 'Hz_stim_trace');
savefig(imgName)
saveas(gcf,imgName, 'jpg')  
saveas(gcf, imgName, 'pdf')
close all
end
