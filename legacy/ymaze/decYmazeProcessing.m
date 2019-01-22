% Load the master data file to store data
[fName,fDir,fFilter]=uigetfile('*.txt;*','Open Master Data Struct','C:\Users\debivort\Documents\MATLAB\Decathlon Raw Data');
structpath = strcat(fDir,strrep(fName, '.mat', ''));
load(structpath);

%%  Save parameters pre-calculated by flyY120LoadData

% Specify data file path
[fName,fDir,fFilter] = uigetfile('*.txt;*','Open data file','C:\Users\debivort\Documents\MATLAB\Decathlon Raw Data');
path = strcat(fDir,strrep(fName, '.data.txt', ''));
data = flyY120LoadData(path);
numFlies = length([data{:,2}]);
data=data(1:numFlies,:);
IDs=data(:,9);
numTurns = cell2mat(data(:,12));
TurnsPerMin = numTurns/120;
TurnBias = cell2mat(data(:,13));
TurnSequence = data(:,14);
tStamps = data(:,15);
ROIcoords = cell2mat(data(:,[10 11]));
date = data(:,3);
time = data(:,4);

clear  fName fDir fFilter

%% Determine clumpiness and switchiness scores
%NOTE: Need to use bootstrapping to determine whether or not MAD is higher
%than expected

% Clumpiness = MAD of inter-choice intervals
% Switchiness = MAD of consecutive R-turn run lengths
minTurns=50;
numReps = 5000;
active=cell2mat(data(:,12))>minTurns;
pData=data(active,:);
d = decYmazeBootstrap(pData,numReps);
clumpiness = d.observed(:,1);
switchiness = d.observed(:,2);

%% Record scores in master flyData file

for i = 1:numFlies
    
    % Save behavioral parameters in the master data file
    yData(i).ID = IDs(i);
    yData(i).ymaze.y_TurnBias = TurnBias(i);
    yData(i).ymaze.y_TurnsPermin = TurnsPerMin(i);
    yData(i).ymaze.y_TurnSeq = cell2mat(TurnSequence(i));
    %yData(i).ymaze.y_switchiness = switchiness(i);
    %yData(i).ymaze.y_clumpiness = clumpiness(i);
    
    flylabel = cell2mat(IDs{i});
    spaces=flylabel==' ';
    flylabel(spaces)=[];
    datIndex = find(cellfun(@(x)isequal(x,flylabel), {flyData.ID}));
    %Note: Save as ymaze2 if data set is positive control
    flyData(datIndex).ymaze2 = yData(i).ymaze;
    
    % Save additional parameters in processed Y-maze file
    yData(i).ymaze.y_numTurns = numTurns(i);
    yData(i).ymaze.y_TurnSequence = cell2mat(TurnSequence(i));
    yData(i).ymaze.y_tStamps = cell2mat(tStamps(i));
    yData(i).ymaze.y_ROIcoords = ROIcoords(i,:);
    yData(i).ymaze.y_date = date(i);
    yData(i).ymaze.y_time = time(i);
end

clear TurnPerMin TurnSequence tStamps time TurnBias ROIcoords mazeData numReps numTurns IDs
clear date clumpiness d flylabel i strain

save(structpath,'flyData');