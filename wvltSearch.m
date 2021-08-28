

tms = linspace(-windowLen/2,windowLen/2,240000);

absCfsCln = zeros(35,240000);
absCfsNos = absCfsCln;

filterBank = cwtfilterbank( "SignalLength",240000,'VoicesPerOctave',18,'SamplingFrequency',30000 ,'FrequencyLimits',[25,95]);  

%Pname = '/Users/robertsutherland/Google Drive/GoogleDrive_Direct/Summer21Reasearch/LFP/MATLAB/wavePics';
Pname= 'C:\Users\Rob\Google Drive\GoogleDrive_Direct\Summer21Reasearch\MATLAB\wavePics';
for i = 1:150
    [cfsCln,frqCln] = cwt(dataDenoised.trial{i}(1,:),'FilterBank',filterBank);
    absCfsCln = abs(cfsCln) + absCfsCln;
    figplt = figure('visible','off');
    filename = "figure" + num2str(i);
    surface(tms(240000/4:3*240000/4), frqCln, absCfsCln(:,(240000/4:3*240000/4)));
    axis tight;
    shading flat;
    get(gca, 'yscale');
    sgtitle("Trial" + num2str(i));
    saveas(figplt,fullfile(Pname,filename),'jpeg');
    close all;
    clearvars cfsCln frqCln;
end
%%
    figure;
    subplot(2,1,1);
    
    
    surface(tms(240000/4:3*240000/4), frqCln, absCfsCln(:,(240000/4:3*240000/4)));
    axis tight;
    shading flat;
    get(gca, 'yscale');

    subplot(2,1,2);
    surface(tms(240000/4:3*240000/4), frqNos, absCfsNos(:,(240000/4:3*240000/4)));
    axis tight;
    shading flat;
    get(gca, 'yscale');
    
    sgtitle("Trial" + num2str(i));