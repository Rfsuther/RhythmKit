%{ 
makeDataStruct
This function will import the data as 2 structs obtained from Blackrock
and associated behavioral file.
Args in: 
struct rawData "A struct produced as the output of openNSx function call
struct behavioralData "A struct of metadata related to rawData
Output:
struct data "A struct containing the correct format to call ftredefinetrial"
Author: Robert Sutherland
%}

function [data] = makeDataStruct(rawData, behavioralData)

data={};
assert(isstruct(rawData)&isstruct(behavioralData)) %check to make sure that args are both strucs

%take in labels from metadata file
labelsCA1 = string(length(behavioralData.CA1_Channels));
labelsCA3 = string(length(behavioralData.CA3_Channels));
labelsCA1(:) = "CA1";
labelsCA3(:) = "CA3";

%labels the channels with spatial marker
chansCA1 = strcat(string(behavioralData.CA1_Channels).', {', '}, labelsCA1);
chansCA3 = strcat(string(behavioralData.CA3_Channels).', {', '}, labelsCA3);
data.label = num2cell([chansCA1;chansCA3]);

%Grabs FS in hertz
data.fsample = rawData.MetaTags.SamplingFreq; 
 
 %extracts good channels from whole dataset. This will import the entire
 %time series as a single trial
 activeChans = ([behavioralData.CA1_Channels,behavioralData.CA3_Channels].');
 data.trial = {double(rawData.Data(activeChans,:))};
 
 %timeInformation as single trial
 data.time = {double([1:length(rawData.Data)])}; 