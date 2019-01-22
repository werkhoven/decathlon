function out = flyY120LoadData( pathname )
%flyYLoadData Loads label and raw data files from Y120 maze runs, cleans up
% hash-tagged labels, analyzes the raw x-y data by calling flyY120.m, then
%reconciles them in a single output cell array.

wb=waitbar(0,'Parsing Labels');

roiSize=30;
minTurns=50;

labelPath=[pathname '.labels.txt'];
dataPath=[pathname '.data.txt'];

labelFID=fopen(labelPath);
labelFileString=fread(labelFID,Inf,'uint8');
labelFileString(labelFileString==9)=44;
labelFileString=char(labelFileString');

labels=textscan(labelFileString,'%u %s %s %u %u %s %s %s %u %u', 'Delimiter' , ',');

numLabels=size(labels,2);
numROIs=size(labels{1},1);
allLabels=cell(numROIs,numLabels+1);
for i=1:numLabels
    allLabels(:,1)={pathname};
    if numROIs>1
        allLabels(:,i+1)=num2cell(labels{i});
    else
        allLabels(:,i+1)=labels(i);
    end
end

allLabels([allLabels{:,2}]==0,:)=[];

for i=1:size(allLabels,1)
    note=cell2mat(allLabels{i,9});
    poundPosition=strfind(note,'#');
    if poundPosition>0
        newStrain=note(poundPosition+1:end);
        newNote=note;
        newNote(poundPosition:end)=[];
        allLabels{i,7}=newStrain;
        allLabels{i,9}=newNote;
        if isempty(allLabels{i,9})
            allLabels{i,9}={''};
        end
    end
end

wb=waitbar(0.1, wb, 'Loading X,Y Data');
rawData=importdata(dataPath);

textTemp='Extracting Turns (roiSize=';
wb=waitbar(0.5, wb, [textTemp num2str(roiSize) ')']);
turnData=flyY120(rawData,roiSize);

wb=waitbar(0.9, wb, 'Matching Labels and Turn Data');
allData=cell(size(turnData.all(:,3),1),size(allLabels,2)+4);
tickTemp=1;
numFlies=0;
tLabels=labels{8};
for i=1:size(tLabels,1)
    if sum(cell2mat(tLabels(i)))>0
        numFlies=numFlies+1;
    end
end


for i=1:numFlies
    tempData=turnData.all(i,:);
    
        allData(tickTemp,:)=[allLabels(i,:) tempData{3} tempData{4} tempData{1} tempData{2}];
        tickTemp=tickTemp+1;
end

out=allData;

close(wb);

end

