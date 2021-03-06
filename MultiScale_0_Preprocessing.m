%% This script is used for reading raw data from NSx files
% Required toolbox: NPMK - BlackRock open source MATLAB toolbox
% Author: Xiwei She
% Project: Multi-scale Memory Decoding Model

clear; clc
%addpath C:\Users\Rob\Desktop\MATLAB\fieldtrip\ %%windows
addpath('/Users/robertsutherland/Desktop/MATLAB/fieldtrip'); %%Mac
addpath('/Users/robertsutherland/Desktop/MATLAB/fieldtrip/preproc');%%Mac
%% Open raw data file
%{
%rawData = openNSx('20190419_Keck15_Recording.ns6');
==================== Elements in the rawData ============================
"rawData.RawData" is the header variable - you may just ignore it
"rawData.ElectrodesInfo" tells your the basic information of electrodes, you can find VALID recording bank/channel here
"rawData.MetaTags" is the variable showing the recording information, and you need to use it for matching signal with behaviroal events
"rawData.Data" is the variable of the actual raw neural signal, and you need to use it for extracting LFP 
First, take a look at the dimensionality of the signal
%} 

rawData = load('rawDataMatFormat.mat').rawData;
numChannel = size(rawData.Data, 1);
numPoints = size(rawData.Data, 2); 
disp(['This dataset contains ', mat2str(numChannel), ' channels and ', mat2str(numPoints), ' recording timestamps'])

%% Open behavioral file
behavioralData = load('20190419_Keck15_Behavioral.mat');
% The Sample Response event is what we are using for modeling 
% Each data in the Sample_Resp corresponding to the timepoint (unit: second) of one behaviroal trial performed by the subject
Sample_Resp = behavioralData.SAMPLE_RESPONSE;  %timestamped to seconds
numTrial = length(Sample_Resp);
% The Match Response event is another one can use for modeling
Match_Resp = behavioralData.MATCH_RESPONSE; 

%% Choose specific recording channel for extracting raw signal
% You may need to modify this part depends on different datasets
% For this dataset, e.g., Keck #15, the VALID recording channels are:
channels = [1:10, 17:26]; % All recording channels
CA3_channels = [1:6, 17:22]; % CA3 channels from hippocampus
CA1_channels = [7:10, 23:26];


%% Gather Metadata

% Check the raw signal sampling rate
samplingFreq = rawData.MetaTags.SamplingFreq; % Get the sampling frequency Hz
recordingDuration = rawData.MetaTags.DataPointsSec; % The length of the recording in the unit of second
if size(rawData.Data, 2) ~= recordingDuration * samplingFreq
    disp('Raw Signal is not matched with timestamps, please check');
end

%{ 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO 1: Extract TRIAL specific time-series signals
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Here use a 4-second window/interval between the Sample_Resp as the decoding window
%}


%% Begin FieldTrip Preprocessing

%Downsample to 15KHz

% Create a FieldTrip data struct to begin preprocessing
dataStructRaw = makeDataStruct(rawData,behavioralData);
clearvars rawData behavioralData;


%%
%Create cfg.trl Matrix in form (ntrials x 3) where first column is start sample
%sencond column is stop sample and thrid is trigger sample




windowLen = 8; %we only care about the 4 sec window but add paddding for data processing TODO: Investigate how much
trialLength = windowLen * samplingFreq; 

cfg = {};
cfg.trl = zeros(numTrial,3);
for i=1:numTrial
    trialStarts = floor(Sample_Resp(i)* samplingFreq)-trialLength/2;
    trialEnds =  floor(Sample_Resp(i)* samplingFreq)+trialLength/2-1;
    trialTrig = Sample_Resp(i)*samplingFreq;
    cfg.trl(i,:) = [trialStarts, trialEnds, trialTrig];
end


cfg.hdr = {};

cfg.hdr.chantype = 'unknown';
cfg.hdr.chanunit = 'mV';

%call ft_redefinetrial to segment raw data into trials 
dataRawSeged = ft_redefinetrial(cfg, dataStructRaw);


rawTrl = dataRawSeged.trial;

%%
clc
%Apply narrow spectrum interpolation to remove 60Hz line noise
%Vector will be passed in of 60Hz, the 2nd, 3rd and 4th harmonic
%subplot(3,1,1);
%plot(real(fftshift(fft(rawTrl(1,:)))));

%Apply narrow spectrum interpolation to remove 60Hz line noise
%Vector will be passed in of 60Hz, the 2nd, 3rd and 4th harmonic
for i = 1:length(dataRawSeged.trial)
    dataRawSeged.trial{i} = ft_preproc_dftfilter(dataRawSeged.trial{i}, dataStructRaw.fsample,[60,120,180],'dftreplace','neighbour');
end

%subplot(3,1,2);
%plot(real(fftshift(fft(dataRawSeged.trial{1}(1,:)))));

%Perform a global Bandpass filter to isolate LFP singal
%4th order low and high pass between 20 and 250 Hz 
cfg.lpfilter = 'yes';
cfg.hpfilter = 'yes';
cfg.lpfiltord = 6;
cfg.hpfiltord = 4;

cfg.lpfreq = 250;
cfg.hpfreq = 10;
dataDenoised = ft_preprocessing(cfg,dataRawSeged);

%subplot(3,1,3);
%plot(real(fftshift(fft(gleeb.trial{1}(1,:)))))


%%
subplot(3,1,1);
plot(dataRawSeged.trial{1}(1,:));
subplot(3,1,2);
plot(foo(1,:));
subplot(3,1,3);
plot(bar(1,:))

%%


%{
% % For example, to extract the first trial information
% firstTrialTimePoint = Sample_Resp(1);
% firstTrial_start = (firstTrialTimePoint - windowLen/2) * samplingFreq; % first 1/2 of window BEFORE Sample Response
% firstTrial_end = (firstTrialTimePoint + windowLen/2) * samplingFreq; % last 1/2 of window AFTER Sample Response
% firstTrial_Extracted = rawSignal(:, firstTrial_start : firstTrial_end);
%}
%{
You need to save all trials' extracted information as a VECTOR
instead of multiple variables, above is just for illustration
 The vector should have a dimensionality as:
%}
%rawSignal_trialSampled = zeros(numChannel, windowLen * samplingFreq + 1, numTrial);
rawSignal_AllTrialSampled = cell(numTrial,1);









for i=1:length(rawSignal_AllTrialSampled)
    averagedSignal = rawSignal_AllTrialSampled{i}(1,:);
    i;
    length(averagedSignal)
    plot([1:1:120000],averagedSignal,'LineWidth',.1);
    hold on
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO 2: Transform the extracted trial information into LFP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Based on your literature reviews, what are the typical ways?

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO 3: Visualize your processed LFP and compare it with other literatures
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Also based on your literature reviews
