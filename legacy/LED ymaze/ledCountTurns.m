function [turnData]=ledCountTurns(cenDat,ledDat,mazeOri)
%% Create an ROI for the center of each maze

ROIsize=40;
centerRadius=18;
nROIs=(size(cenDat,2)-1)/2;
cROIs=zeros(nROIs,4);
center=ROIsize/2;

for i=1:nROIs
    cROIs(i,1)=center-centerRadius;
    cROIs(i,2)=center-centerRadius;
    cROIs(i,3)=center+centerRadius;
    cROIs(i,4)=center+centerRadius;
end

%% Detect events entering and exiting the center ROI

for i=1:nROIs
    tempData=cenDat(:,i*2:i*2+1);
    x1=tempData(:,1)>cROIs(i,1);
    x2=tempData(:,1)<cROIs(i,3);
    y1=tempData(:,2)>cROIs(i,2);
    y2=tempData(:,2)<cROIs(i,4);
    validDataPoints=x1.*x2.*y1.*y2;
    runs=diff([0;validDataPoints]);
    enters=boolean(runs==1);
    exits=boolean(runs==-1);
    
    % Remove trials at the beginning or end of the experiment where data is
    % not recorded for a full choice
    enterIndex=find(enters==1);
    exitIndex=find(exits==1);
    
    if exitIndex(1)<enterIndex(1)
        exits(exitIndex(1))=0;
    end
    if enterIndex(end)>exitIndex(end)
        enters(enterIndex(end))=0;
    end
    
    % Determine closest arm at entrance and exit
    if mazeOri(i)==1
        arm1=repmat([cROIs(i,1),cROIs(i,2)],sum(enters),1);
        arm2=repmat([center,cROIs(i,4)],sum(enters),1);
        arm3=repmat([cROIs(i,3),cROIs(i,2)],sum(enters),1);
    elseif mazeOri(i)==0
        arm1=repmat([cROIs(i,1),cROIs(i,4)],sum(enters),1);
        arm2=repmat([center,cROIs(i,2)],sum(enters),1);
        arm3=repmat([cROIs(i,3),cROIs(i,4)],sum(enters),1);   
    end
        
    % Determine which arm they were closest to upon entering
    enterCoords=tempData(enters,:);
    d=zeros(length(enterCoords),3);
    d(:,1)=sqrt(dot((enterCoords-arm1),(arm1-enterCoords),2));
    d(:,2)=sqrt(dot((enterCoords-arm2),(arm2-enterCoords),2));
    d(:,3)=sqrt(dot((enterCoords-arm3),(arm3-enterCoords),2));
    d=abs(d);
    [v,enterArms]=min(d');
    
    exitCoords=tempData(exits,:);
    d=zeros(length(enterCoords),3);
    d(:,1)=sqrt(dot((exitCoords-arm1),(arm1-exitCoords),2));
    d(:,2)=sqrt(dot((exitCoords-arm2),(arm2-exitCoords),2));
    d(:,3)=sqrt(dot((exitCoords-arm3),(arm3-exitCoords),2));
    d=abs(d);
    [v,exitArms]=min(d');
    
    % Discard turns where they went back down the same arm
    validTurns=enterArms~=exitArms;
    enterIndex=find(enters==1);
    exitIndex=find(exits==1);
    validTimePoints=exitIndex(validTurns);
    enterArms=enterArms(validTurns);
    exitArms=exitArms(validTurns);
    
    % Get LED status when fly exited the center ROI
    tempLED=ledDat(:,i*3-1:i*3+1);
    stimStat=sum(tempLED(validTimePoints,:),2);
    singleLED=stimStat==1;
    [V,lightONarm]=max(tempLED(validTimePoints(singleLED),:)');
    singleLEDexitArms=exitArms(singleLED);
    lightPreference=sum(singleLEDexitArms==lightONarm)/length(lightONarm);
    
    allTurns=exitArms-enterArms;
    
    if mazeOri(i)==1
        % 0 for right turn, 1 for left
        allTurns(allTurns==-1)=0;
        allTurns(allTurns==2)=0;
        allTurns(allTurns==1)=1;
        allTurns(allTurns==-2)=1;
    elseif mazeOri(i)==0
        allTurns(allTurns==1)=0;
        allTurns(allTurns==-1)=1;
        allTurns(allTurns==2)=1;
        allTurns(allTurns==-2)=0;
    end
    
    turnData(i).turns=allTurns;
    turnData(i).enterArms=enterArms;
    turnData(i).exitArms=exitArms;
    turnData(i).lightPreference=lightPreference;
    turnData(i).bias=sum(allTurns)/length(allTurns);
    turnData(i).enters=enters;
    turnData(i).exits=exits;
    turnData(i).orientation=mazeOri(i);
    turnData(i).cROI=cROIs(i,:);
    
end
    