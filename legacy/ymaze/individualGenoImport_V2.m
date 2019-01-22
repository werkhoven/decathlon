function [outDataArray,turnLength] = individualGenoImport_V2(roi,minFrames)
% Kyobi Skutt-Kakaria
% 4.22.2015
% This is my version of flyDataImport from Ymaze, somewhat based on Sean
% Buchanen's script. I wanted to do it differently and import each fly into
% a field in a structured array, so that I can easily explore the data
% later and also to keep better track of things. What I want to do is when
% I import a data file coming from labview, I want to match it with its
% labels file and store it as a multidemensional array.

clear allDataStruct
[fName,fDir,fFilter] = uigetfile('*.txt;*','Open data file','C:\Users\debivort\Documents\MATLAB\Decathlon Raw Data');
datapath = strcat(fDir,fName);
labelpath = strcat(datapath(1:end-8),'labels.txt');
importData = importdata(datapath); % Here I import the .data file from labview
labelFile = readtable(labelpath,'Delimiter','\t','ReadVariableNames',false); % This is for the .labels file
timeVect = (importData(:,2)-importData(1,2))/(1000*60); % This is the entire time vector for the .data file
%allDataStruct(120)=cell('mazeNum',[],'genotype',[],'sex',[],'turnVect',[],'turnTiming',[],'xycor',[],'timeStamp',[],'startsAndEnds',[],'dateAndTime',[],'boxAndTray',[],'additionalLabels',[]);
allDataArray = cell(120,12);
minFrames = minFrames;
if size(importData,2) < 242
    importData(:,size(importData,2):242) = NaN;
end
%% Filter out turns which are less than minFrames long and output a vector of turn lengths
turnLength=[];

for m = 1:size(labelFile,1) % This loop is initialized for all flies
    
    data = importData(:,[(2*m+1) (2*m+2)]);
    %%
    posNotNans = ~isnan(data(:,1));
    turnStarts = [];
    turnEnds = [];
    for i = 1:(size(data,1))
        if i <= 5
            continue
        elseif i >= (size(data,1)-minFrames)
            continue
        elseif posNotNans(i) == 0 && posNotNans(i-1) == 0
            continue
        elseif posNotNans(i) == 1 && posNotNans(i+1) == 1 && posNotNans(i-1) == 1
            continue
        elseif mean(posNotNans(i:i+2)) == 1 && posNotNans((i-1)) == 0
            turnStart = i;
            turnStarts = [turnStarts; turnStart];
        elseif mean(posNotNans((i-2):i)) == 1 && posNotNans(i+1) == 0 && ~isempty(turnStarts)
            turnEnd = i;
            turnEnds = [turnEnds; turnEnd];
        else
            continue
        end
    end
    %%
    

    if length(turnStarts) > length(turnEnds)
        turnStarts = turnStarts(1:(end-1));
    elseif length(turnStarts) < length(turnEnds)
        turnEnds = turnEnds(2:end);
    end
    %%
    turnLength=[turnLength (turnEnds-turnStarts)'];
    indexes = turnEnds-turnStarts >= minFrames;
    turnStarts = turnStarts(indexes);
    turnEnds = turnEnds(indexes);
    startVals = data(turnStarts,:);
    endVals = data(turnEnds,:);
    
    %% Setting the exit points
    if m <= 64
        points = [0 (3*roi)/4;roi/2 0;roi (3*roi)/4];
    else
        points = [0 roi/4;roi/2 roi;roi roi/4];
    end

    %% Calculating least squares difference
    diffStarts = [];
    diffEnds = [];
    sumOfSquaresStart = [];
    sumOfSquaresEnd = [];
    for i = 1:3
        diffStarts(:,1) = startVals(:,1)-points(i,1);
        diffStarts(:,2) = startVals(:,2)-points(i,2);
        diffEnds(:,1) = endVals(:,1)-points(i,1);
        diffEnds(:,2) = endVals(:,2)-points(i,2);
        sumOfSquaresStart(:,i) = diffStarts(:,1).^2+diffStarts(:,2).^2;
        sumOfSquaresEnd(:,i) = diffEnds(:,1).^2+diffEnds(:,2).^2;
    end
    
    [~,minStarts] = min(sumOfSquaresStart,[],2);
    [~,minEnds] = min(sumOfSquaresEnd,[],2);
    allTurns = [minStarts minEnds];
    %% Now I need to filter out turn arounds, annotate R and L turns and pull out time stamps
    realTurns = allTurns(minStarts~=minEnds,:);
    turnTiming = timeVect(turnEnds(minStarts~=minEnds));
    turns = zeros(size(realTurns,1),1);
    if m <= 64
        turns = (realTurns(:,1) == 1 & realTurns(:,2) == 3) | (realTurns(:,1) == 3 & realTurns(:,2) == 2) | (realTurns(:,1) == 2 & realTurns(:,2) == 1);
    elseif m >=65
        turns = (realTurns(:,1) == 1 & realTurns(:,2) == 2) | (realTurns(:,1) == 2 & realTurns(:,2) == 3) | (realTurns(:,1) == 3 & realTurns(:,2) == 1);
    end
    
    %% 
    startsAndEnds = [turnStarts(minStarts~=minEnds) turnEnds(minStarts~=minEnds)];
    %%
%     allDataStruct(m).mazeNum = labelFile.Var1(m);
%     allDataStruct(m).genotype = labelFile.Var6(m);
%     allDataStruct(m).sex = labelFile.Var7(m);
%     allDataStruct(m).turnVect = turns;
%     allDataStruct(m).turnTiming = turnTiming;
%     allDataStruct(m).xycor = data;
%     allDataStruct(m).timeStamp = timeVect;
%     allDataStruct(m).startsAndEnds = startsAndEnds;
%     allDataStruct(m).dateAndTime = [labelFile.Var2(m) labelFile.Var3(m)];
%     allDataStruct(m).boxAndTray = [labelFile.Var4(m) labelFile.Var5(m)];
%     allDataStruct(m).additionalLabels = labelFile.Var8(m);
    
allDataArray(m,:) = {labelFile.Var1(m) labelFile.Var6(m) labelFile.Var7(m) turns turnTiming data timeVect startsAndEnds [labelFile.Var2(m) labelFile.Var3(m)] labelFile.Var4(m) labelFile.Var5(m) labelFile.Var8(m)};
%    outstruct=allDataStruct;

    
end
outDataArray = allDataArray;
end