function [turnData]=optoCountTurns(flyTracks,ROI_coords,mazeOri,xCenters,yCenters)
%% Create an ROI for the center of each maze

nROIs=length(ROI_coords);
cROIs=zeros(nROIs,4);
xCenters=round(xCenters);
yCenters=round(yCenters);
%xCenters=ceil((ROI_coords(:,3)+ROI_coords(:,1))./2);
%yCenters=ceil((ROI_coords(:,4)+ROI_coords(:,2))./2);

for i=1:nROIs
    cROIs(i,1)=xCenters(i)-10;
    cROIs(i,2)=yCenters(i)-10;
    cROIs(i,3)=xCenters(i)+10;
    cROIs(i,4)=yCenters(i)+10;
end

%% Detect events entering and exiting the center ROI

for i=1:flyTracks.nFlies
    tempData=flyTracks.centroid(:,:,i);
    x1=tempData(:,1)>cROIs(i,1);
    x2=tempData(:,1)<cROIs(i,3);
    y1=tempData(:,2)>cROIs(i,2);
    y2=tempData(:,2)<cROIs(i,4);
    validDataPoints=x1.*x2.*y1.*y2;
    runs=diff([0;validDataPoints]);
    enters=boolean(runs==1);
    exits=boolean(runs==-1);
    
    % If fly finishes experiment in the choice point without exiting,
    % remove the last trial
    if sum(enters)>sum(exits)
        indices=find(enters==1);
        enters(indices(end))=0;
    end  
    
    % Determine closest arm at entrance and exit
    if mazeOri(i)==1
        arm1=repmat([cROIs(i,1),cROIs(i,2)],sum(enters),1);
        arm2=repmat([xCenters(i),cROIs(i,4)],sum(enters),1);
        arm3=repmat([cROIs(i,3),cROIs(i,2)],sum(enters),1);
    elseif mazeOri(i)==0
        arm1=repmat([cROIs(i,1),cROIs(i,4)],sum(enters),1);
        arm2=repmat([xCenters(i),cROIs(i,2)],sum(enters),1);
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
    
    allturns=enterArms-exitArms;
    validturns=allturns(allturns~=0);
    
    if mazeOri(i)==1
        % 0 for right turn, 1 for left
        validturns(validturns==-1)=0;
        validturns(validturns==2)=0;
        validturns(validturns==1)=1;
        validturns(validturns==-2)=1;
    elseif mazeOri(i)==0
        validturns(validturns==1)=0;
        validturns(validturns==-1)=1;
        validturns(validturns==2)=1;
        validturns(validturns==-2)=0;
    end
    
    turnData(i).turns=allturns;
    turnData(i).enterArms=enterArms;
    turnData(i).exitArms=exitArms;
    turnData(i).bias=sum(validturns)/length(validturns);
    turnData(i).enters=enters;
    turnData(i).exits=exits;
    turnData(i).orientation=mazeOri(i);
    turnData(i).cROI=cROIs(i,:);
    
end
    