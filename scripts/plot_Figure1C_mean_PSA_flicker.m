%% Plot mean PSA of all trials 
% The script was used to generate Figure 1C in manuscript
% "Brain rhythms control microglial response and cytokine expression via NFκB signaling"

% Plots are generated in a new folder named 'plots' in the parent directory

% Dependencies
% 1. 'Statistics and Machine Learning Toolbox'
% 2. 'DSP System Toolbox'
% 3. CIshade_flicker.m file (included in the same script folder)

%% Plot PSA for 20 Hz flicker and 40 Hz flicker, respectively
plot_mean_PSA_flicker(20) % for plotting 20 Hz map
plot_mean_PSA_flicker(40) % for plotting 40 Hz map

%% Function to plot
function plot_mean_PSA_flicker(selectedFrequency)
axis_font = 7;
legend_font = 5;
label_font = 7;


duration = 20.48;
IMG_sampleRate = 200;
IMG_x = 0:(1/IMG_sampleRate):(duration - 1/IMG_sampleRate);


currentFolder = mfilename('fullpath'); % determine the filepath based on where the script locates
scriptFN = mfilename;
filePath = erase(erase(currentFolder, scriptFN), strcat('scripts', filesep));
savePath = strcat(filePath, filesep, 'plots', filesep, 'Figure1C', filesep);
%% Find list of files 

if ~isfolder(savePath)
    mkdir(savePath)
end

searchPath = strcat(filePath, filesep, 'data', filesep, 'Figure1B_V1_traces');
searchTerm = strcat('*', string(selectedFrequency), '_*.mat');
filelist = dir(fullfile(searchPath, '**', searchTerm));

%% Load and concatenate files into one structure array 
V1_allMice = struct('regressed_g', cell(1, length(filelist)*10), 'AP_onsetT', cell(1, length(filelist)*10), 'AP_offsetT', cell(1, length(filelist)*10));
for fileN = 1:length(filelist)
    fullFN = strcat(filelist(fileN).folder, '\', filelist(fileN).name);
    load(fullFN, 'v1_traces')
    
    V1_allMice(1, (1+10*(fileN-1)):(10*fileN)) = v1_traces;
end

%% Calculate PSA of baseline and stimulus period
onsetInd = zeros(length(V1_allMice), 1);
offsetInd = zeros(length(V1_allMice), 1);
LEDonsetTimes = [V1_allMice.AP_onsetT];
LEDoffsetTimes = [V1_allMice.AP_offsetT];
for trialN = 1:length(LEDonsetTimes)
    onsetInd(trialN, 1) = find(IMG_x >= LEDonsetTimes(trialN), 1, 'first');
    offsetInd(trialN, 1) = find(IMG_x <= LEDoffsetTimes(trialN), 1, 'last');
end
onsetIndexAll = mode(onsetInd);
offSetIndexAll = mode(offsetInd);
all_v1_traces = - [V1_allMice.regressed_g];
[x_frequency_baseline, y_PSA_baseline] = calculate_FFT(all_v1_traces(1:(onsetIndexAll-1), :), IMG_sampleRate, {}, 0);
[x_frequency_flicker, y_PSA_flicker] = calculate_FFT(all_v1_traces(onsetIndexAll:offSetIndexAll, :), IMG_sampleRate, {}, 0);
%% Plot
% plot(x_frequency_baseline, mean(y_PSA_baseline, 2));
[~, ~] = CIshade_flicker(y_PSA_baseline', 0.1, [0 0.4470 0.7410], x_frequency_baseline, [], '-');
hold on
[~, ~] = CIshade_flicker(y_PSA_flicker', 0.1, [0.8500 0.3250 0.0980], x_frequency_flicker, [], '-');

xlim([0 70])
ylim([-55 0])

xlabel('Frequency (Hz', 'FontSize', label_font)
ylabel('Power spectral density (dB/Hz)', 'FontSize', label_font)

legend('', 'Baseline', '', strcat(string(selectedFrequency), " Hz flicker"), 'FontSize', legend_font)
ax = gca;
ax.FontSize = axis_font; 
ax.FontSize = axis_font; 
set(ax.YAxis,'TickDir','out');
ax.XRuler.TickLength = [0.06, 0.06];
ax.YRuler.TickLength = [0.06, 0.06];
ax.LineWidth = 1;
set(gca,'box','off')
set(gcf,'units', 'centimeters', 'Position',[30,1,4.5,4.5]);
legend boxoff  
imgName = strcat(savePath, 'Mean_PSA_', string(selectedFrequency), 'Hz_stim_shaded_CI');
savefig(imgName)
saveas(gcf,imgName, 'jpg') 
saveas(gcf, imgName, 'pdf')

end


%% Function in use
function [x_frequency, y_PSA] = calculate_FFT(traces, Fs, ChannelNames, PlotOnOff)
    SA = dsp.SpectrumAnalyzer('SampleRate',Fs, 'Method', 'Welch', ...
        'SpectrumType','Power density', 'PlotAsTwoSidedSpectrum',false,...
        'FrequencyResolutionMethod', 'WindowLength', 'WindowLength', 512,...
        'ChannelNames',{'Power spectrum of the input'}, 'YLimits',[-120 40],...
        'ShowLegend',true,'ChannelNames',ChannelNames);

    SA(traces)

    PSA_results = getSpectrumData(SA);

    x_frequency = PSA_results.FrequencyVector{1,1};
    y_PSA = PSA_results.Spectrum{1,1};
    
    if PlotOnOff == 1
     %if PlotOnOff is set to be ON (1)
%         colors = {'k', 'g', 'b', 'k'};
        for traceN = 1:size(y_PSA, 2)
            plot(x_frequency, y_PSA(:, traceN), 'LineWidth', 1.2)
            hold on
        end
    elseif PlotOnOff == 0
        %No plot
    else
        fprintf('The input for PlotOnOff is incorrect');
    end
    release(SA)
    close all
end