% Load the master data file to store data
%load flyData.mat;


% Specify data file path
[fName,fDir,fFilter] = uigetfile('*.txt;*','Open data file','C:\Users\debivort\Desktop\Decathlon Data Files');
raw=decArenaLoadRawData(strcat(fDir,fName));
data=raw.data;
labels=raw.labels;
%load decStruct_4_4_2015.mat;

% I totally fucked up the order of some of the mazes. This is an optional
% function exclusively for unfucking up arena circling files where the
% order of ROIs was reproducibly fucked.
%{
for i = 1:4
    if i == 1
        %data(:,[i*10-5:i*10-4,i*10-3:i*10-2,i*10-1:i*10,i*10+1:i*10+2])=data(:,[i*10+1:i*10+2,i*10-1:i*10,i*10-3:i*10-2,i*10-5:i*10-4]);
    else
        data(:,[i*10-7:i*10-6,i*10-5:i*10-4,i*10-3:i*10-2,i*10-1:i*10,i*10+1:i*10+2])=data(:,[i*10+1:i*10+2,i*10-1:i*10,i*10-3:i*10-2,i*10-5:i*10-4,i*10-7:i*10-6]);
    end
end
%}

% Count fly columns
numFlies = (size(data,2) - 2)/2;

% Search for NaNs  to determine true number of flies since data file may be padded with NaNs

R = {};
C = {};
j = 0;

for i = 1:numFlies*2

[R{i} C{i}] = find(isnan(data(:,i+2)));

    % If a column has > 80% NaN, mark for deletion
    if length(R{i}) > length(data)*0.99
        j = j+1;
        del_Col(j) = i+2;
    end

end

% Delete empty columns, update numFlies
if j>0
data(:,[del_Col]) = [];
numFlies = (size(data,2) - 2)/2;
end

% Define ROI size and process data with flyBurHandData and avgAngle
ROIsize = 160;
dataP = [];   
dataP = flyBurHandData(data,numFlies,ROIsize);

flyCircles = avgAngle(dataP,ROIsize);
figure();
hold on
angPlots = zeros(26,2);
bins=0:2*pi/26:2*pi;
colors = rand(1,3,numFlies);

for i = 1:numFlies
    h1=plot(bins(1:length(bins)-1),flyCircles(i).angleavg(1:length(bins)-1),'color',colors(:,:,i));
    set(h1,'Linewidth',2)
end
axis([0,2*pi,0,inf]);

%% Calculate avg. local velocity over a one-minute sliding window

numFrames = size(dataP(1).speed,1);
windowsize = floor(numFrames/120);

for i = 1:numFlies
    locVel = zeros(1,numFrames-windowsize);
    for j = 1:numFrames-windowsize
        locVel(j) = nanmean(dataP(i).speed(j:j+windowsize));
    end
    X=1:length(locVel);
    nanLoc = find(isnan(locVel)==1);
    X(nanLoc)=[];
    locVel(nanLoc)=[];
    linCoeffs=polyfit(X,locVel,1);
    habRate(i)=linCoeffs(1);
end


%% 

% Calculate averaged circling angle mu. Assign data in flyCircles to master data struct flyData
% Assign flyID to each fly
k=0;

for i = 1:numFlies
    avg=0;
    for j = 1:length(flyCircles(i).angleavg)-1
        avg = avg + flyCircles(i).angleavg(j)*-1*sin(bins(j));
    end
    flyCircles(i).avg = avg;
    mu=flyCircles(i).avg;
    flyCircles(i).mu=mu;
    
    % NOTE: this is only for replacing flyData.circles values; do not use if this is a new file
    % Search for the flyData index that matches mu
    flylabel = cell2mat(labels{i,9});
    flyCircles(i).labels=flylabel;
    datIndex = find(cellfun(@(x)isequal(x,flylabel), {flyData.ID}));

    % Record behavioral parameters and store in master data file
    circData(i).circles.c2_mu = mu;
    circData(i).circles.c2_speed = nanmean(dataP(i).speed);
    circData(i).circles.c2_edgeposition = nanmean(dataP(i).r);
    circData(i).circles.c2_habituation = habRate(i);
    
    %Note: If this is the positive control replicate, save data in
    %flyData.circles2
    if isempty(datIndex)<1 & length(datIndex)<2
    flyData(datIndex).circles2=circData(i).circles;
    end
    
    % Record raw data in separate file
    circData(i).circles.c_angleavg = flyCircles(i).angleavg;
    circData(i).circles.c_numTrials = flyCircles(i).numTrials;
    
    %flyData(fIndex+i).ID = strcat(IDstr,num2str(strain),'-',num2str(fIndex+i));
    k=k+1;
end

decPlotArenaTraces(flyCircles,data)

clearvars -except data dataP ROIsize numFlies flyData datIndex flyCircles

%save 'flyData.mat' flyData