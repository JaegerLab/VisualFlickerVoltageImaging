%% Plot mean trace of all trials 
% The script was used to generate Figure 1B in manuscript
% "Brain rhythms control microglial response and cytokine expression via NFκB signaling"

%  Plots are generated in a new folder named 'plots' in the parent directory
%% Dependency: 
% 1. 'Statistics and Machine Learning Toolbox'
% 2. 'DSP System Toolbox'
% 3. CIshade_flicker.m file (included in the same script folder)
function plot_Figure1B_peristimulus_traces
%% Set up font and line size
axis_font = 7;
legend_font = 5;
label_font = 7;
title_font = 7;
lineWidth = 0.3;

% Set up x axis for plotting
duration = 20.48;
IMG_sampleRate = 200;
IMG_x = 0:(1/IMG_sampleRate):(duration - 1/IMG_sampleRate);

currentFolder = mfilename('fullpath'); % determine the filepath based on where the script locates
scriptFN = mfilename;
filePath = erase(erase(currentFolder, scriptFN), strcat('scripts', filesep));
savePath = strcat(filePath, filesep, 'plots', filesep, 'Figure1B', filesep);

if ~isfolder(savePath)
    mkdir(savePath)
end

searchPath = strcat(filePath, filesep, 'data', filesep, 'Figure1B_V1_traces');

%% Load and output data

[cycleTrace20] = loadV1Traces(20, IMG_x, searchPath);

[cycleTrace40] = loadV1Traces(40, IMG_x, searchPath);

x_t = 0:1/IMG_sampleRate:((size(cycleTrace40, 1)-1)*1/IMG_sampleRate);

% cycleTrace = reshape(meanTrace, 30, 3600);
[~, ~] = CIshade_flicker(cycleTrace20', 0.1, [1 0 0], x_t, [], '-');
hold on
[lineOut, fillOut] = CIshade_flicker(cycleTrace40', 0.1, [0 0 0], x_t, [], '-');
shift_x = -0.05;
shift_y = -1;

x_axis_txt_pos = [-0.04, -1.3];
y_axis_txt_pos = [-0.07, -1.1];

%plot scale bars for dff
plot([0; 0.02] + shift_x, [-0.2; -0.2] + shift_y, '-k', 'LineWidth', 0.75)
plot([0; 0] + shift_x, [-0.2; 0] + shift_y, '-k', 'LineWidth', 0.75)

text(x_axis_txt_pos(1), x_axis_txt_pos(2), '10 ms', 'HorizontalAlignment','center', 'FontSize', label_font)
text(y_axis_txt_pos(1), y_axis_txt_pos(2), {'0.2 %', 'dF/F'}, 'HorizontalAlignment','center', 'FontSize', label_font)

set(gca,'box','off')
set(gca, 'Visible', 'off')
set(gcf,'units', 'centimeters', 'Position',[10,1,10,6]);

imgFN = strcat(savePath, '20vs40Hz_peristimulus_activity');
savefig(imgFN)
saveas(gcf, imgFN, 'pdf')
saveas(gcf, imgFN, 'jpg')
end


%% Function(s) in use

function [cycleTrace] = loadV1Traces(selectedFrequency, IMG_x, searchPath)

searchTerm = strcat('*', string(selectedFrequency), '_*.mat');
filelist = dir(fullfile(searchPath, '**', searchTerm));

%% Load and concatenate files into one structure array 
allStimTrace = struct('stimTrace', cell(1, 6));
for fileN = 1:length(filelist)
    fullFN = strcat(filelist(fileN).folder, '\', filelist(fileN).name);
    load(fullFN, 'v1_traces')
    nameParts = split(filelist(fileN).name, '_');
    AnimalID = nameParts{1};
    % For each trial
    subTrace = zeros(2000, 10);
    for trialN = 1:length(v1_traces)

        rg_trace = - v1_traces(trialN).regressed_g * 100; 
        stimOnsetT = v1_traces(trialN).AP_onsetT;
        
        % Identify the first and last frame
        onsetFrame = find(IMG_x >= stimOnsetT, 1, 'first');
        offsetFrame = onsetFrame + 1999;
        
        stimTrace = rg_trace(onsetFrame:offsetFrame);

        subTrace(:, trialN) = stimTrace;
    end

    
        allStimTrace(fileN).stimTrace = subTrace;
        allStimTrace(fileN).onsetFrame = onsetFrame;
        allStimTrace(fileN).offsetFrame = offsetFrame;
        allStimTrace(fileN).AnimalID = AnimalID;
        
end

%% Output activity 

allMeanTraces = [allStimTrace.stimTrace]; % concatenate data from all mice and all trials
allMeanTraces = allMeanTraces(201:end, :); % Remove first 1s of stimulus response
% there is a sharp sensory response to the onset of the flicker, which is
% removed by removing the first 1 s of data (200 data points)

% reshape the data to 0.15 s and 3600 stimuli (cycles)
cycleTrace = reshape(allMeanTraces, [30, 60, 60]); 
cycleTrace = reshape(cycleTrace, [30, 3600]);

end

