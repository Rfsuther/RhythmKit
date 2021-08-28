%% This script is used for reading raw data from NSx files
% Required toolbox: NPMK - BlackRock open source MATLAB toolbox
% Author: Xiwei She
% Project: Multi-scale Memory Decoding Model

clear; clc
addpath C:\Users\Rob\Desktop\MATLAB\fieldtrip\ %%windows

%% Open raw data file
%{

==================== Elements in the rawData ============================
"rawData.RawData" is the header variable - you may just ignore it
"rawData.ElectrodesInfo" tells your the basic information of electrodes, you can find VALID recording bank/channel here
"rawData.MetaTags" is the variable showing the recording information, and you need to use it for matching signal with behaviroal events
"rawData.Data" is the variable of the actual raw neural signal, and you need to use it for extracting LFP 
First, take a look at the dimensionality of the signal
%} 
%if you dont have this locally you should run the line below
%rawData = openNSx('20190419_Keck15_Recording.ns6'); 
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

% Now extract the raw neural signal
rawSignal = rawData.Data(channels, :);

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



%Apply narrow notch filter to remove 60Hz line noise
%Vector will be passed in of 60Hz, the 2nd, 3rd and 4th harmonic
dataStructRaw.trial{1,1} = ft_preproc_dftfilter(dataStructRaw.trial{1,1}, dataStructRaw.fsample, [60,120,180,240]);


%%

windowLen = 4;

% For example, to extract the first trial information
firstTrialTimePoint = Sample_Resp(1);
firstTrial_start = (firstTrialTimePoint - 2) * samplingFreq; % 2 sec BEFORE Sample Response
firstTrial_end = (firstTrialTimePoint + 2) * samplingFreq; % 2 sec AFTER Sample Response
firstTrial_Extracted = rawSignal(:, firstTrial_start : firstTrial_end);

%{
You need to save all trials' extracted information as a VECTOR
instead of multiple variables, above is just for illustration
 The vector should have a dimensionality as:
%}
rawSignal_trialSampled = zeros(numChannel, windowLen * samplingFreq + 1, numTrial);
rawSignal_AllTrialSampled = cell(numTrial,1);

 
%%
trialLength = windowLen * samplingFreq; 
for i=1:numTrial
    trialStarts = floor(Sample_Resp(i)* samplingFreq)-trialLength/2;
    trialEnds =  floor(Sample_Resp(i)* samplingFreq)+trialLength/2-1;
    rawSignal_AllTrialSampled{i} = rawSignal(:,(trialStarts:trialEnds));
end
%%
for i=1:length(rawSignal_AllTrialSampled)
    averagedSignal = rawSignal_AllTrialSampled{i}(1,:);
    i;
    length(averagedSignal)
    plot([1:1:120000],averagedSignal,'LineWidth',.1);
    hold on
end
% for i = 2:150
%     averagedSignal = mean([rawSignal_AllTrialSampled{i}(1,:),averagedSignal],1);
% end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO 2: Transform the extracted trial information into LFP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Based on your literature reviews, what are the typical ways?

%%
for i=1:10
    
    figure();
    plot((1:200:length(rawSignal)),rawSignal(i,(1:200:length(rawSignal))));
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO 3: Visualize your processed LFP and compare it with other literatures
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Also based on your literature reviews
