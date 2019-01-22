function out=decArenaLoadRawData(pathname)
%flyYLoadData Loads label and raw data files from Arena Circling v2

wb=waitbar(0,'Parsing Labels');
periods=find(pathname=='.');
pathname=pathname(1:periods(1)-1);

labelPath=[pathname '.labels.txt'];
dataPath=[pathname '.data.txt'];
labelFID=fopen(labelPath);
labelFileString=fread(labelFID,Inf,'uint8');
labelFileString(labelFileString==9)=44;
labelFileString=char(labelFileString');

wb=waitbar(0.1, wb, 'Loading labels');
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

wb=waitbar(0.5, wb, 'Loading X,Y Data');
rawData=importdata(dataPath);

%{
textTemp='Extracting Turns (roiSize=';
wb=waitbar(0.5, wb, [textTemp num2str(roiSize) ')']);
turnData=flyY120(rawData,roiSize);


wb=waitbar(0.9, wb, 'Matching Labels and Turn Data');
allData=cell(sum(cell2mat(turnData.all(:,3))>=minTurns),size(allLabels,2)+4);
tickTemp=1;
for i=1:size(allLabels,1)
    tempData=turnData.all(i,:);
    
    if tempData{3}>=minTurns
        allData(tickTemp,:)=[allLabels(i,:) tempData{3} tempData{4} tempData{1} tempData{2}];
        tickTemp=tickTemp+1;
    end
end
%}

out.labels=allLabels;
out.data=rawData;

close(wb);
