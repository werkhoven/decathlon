
%% Setup the camera and video object

vid = initializeCamera('pointgrey',1,'F7_BayerRG8_664x524_Mode1');

%% Initialize the stimulus and input ROI properties

ROInum=16;
ROIsize=133;
spatialFrequency=18;
temporalFrequency=6;

stimProperties=initializeOptomotorStim(ROIsize,ROInum,spatialFrequency,temporalFrequency);

%% Create Placeholder files

% Create temp data files
t = datestr(clock,'mm-dd-yyyy_HH-MM-SS');
fpath = 'C:\Users\debivort\Documents\MATLAB\Processed Decathlon Data\Optomotor';
cenID = [fpath t '_Centroid.dat'];            % File ID for centroid data
stimID = [fpath t '_StimStatus.dat'];         % File ID for stimulus status
angID = [fpath t '_StimAngle.dat'];           % File ID for stimulus angle

dlmwrite(cenID, [])                          % create placeholder ASCII file
dlmwrite(stimID, [])                         % create placeholder ASCII file
dlmwrite(angID, [])                          % create placeholder ASCII file

%% Grab reference by averaging out moving stimulus

% Get flies moving with optomotor stimulus
tic
while toc<10
    stimProperties=dispOptomotorStim(stimProperties);
    stimProperties.phaseLine=stimProperties.phaseLine+ stimProperties.degPerFrameGabors;
end
pause(2.5);

%Grab blank background
[whiteReference,h]=optoReferenceBackground(vid,stimProperties);

% Break KbCheck
while KbCheck
end
shg

% Reference the background with the moving stimulus (press keyboard to stop
% collecting references)
[stimReference,refCount]=optoReferenceStimulus(vid,stimProperties,h);

% Set thresholds
whiteThresh = 15;
stimThresh = 20;

[ROI_bounds,ROI_coords,ROI_widths,ROI_heights,binaryimage] = detect_ROIs(stimReference);

%% Continue referencing until the number of centroids equals number of flies

numROIs = size(ROI_coords,1);
numCentroids = 0;
i=0;
shg
    
while  numCentroids < numROIs-40 || i<2
    
       % Extract centroid
       [props,imagedata]=decGetCentroid2(vid,stimReference,stimThresh);
       cenDat=reshape([props(:).Centroid],2,length([props(:).Centroid])/2)';
        
       % Calculate number of flies with non-zero centroids
       numCentroids=size(props,1);
       
       % Display stimulus
       stimProperties=dispOptomotorStim(stimProperties);
       set(h,'CData',imagedata);
       drawnow

       % Open a figure that shows the referenced centroids
       if numCentroids >= numROIs-40
           set(h,'CData',imagedata);
           hold on
           plot(cenDat(:,1),cenDat(:,2),'o','Color','r')
           for i = 1:size(ROI_coords,1)
            rectangle('Position',ROI_bounds(i,:),'EdgeColor','r')
           end
           hold off          
           drawnow
       end
       i=i+1;
end

% Break KbCheck
while KbCheck
end
close


%% Match ROI indices to gabor indices and centroids indices to ROI indices

permutation=optoMatchROIs2Gabors(binaryimage,ROI_coords);
ROI_coords=ROI_coords(permutation,:);
[xCenters,yCenters]=optoROIcenters(binaryimage,ROI_coords);
centers=[xCenters,yCenters];

%% Build a lastCentroid reference for each fly

h=imshow(binaryimage);
shg
title('Check fly centroids and press ENTER to continue');
lastCentroid=NaN(numROIs,2);
lh=plot([],[]);

while sum(sum(isnan(lastCentroid)))>0 && ~KbCheck

% Extract centroid
[props,imagedata]=decGetCentroid2(vid,stimReference,stimThresh);
cenDat=reshape([props(:).Centroid],2,length([props(:).Centroid])/2)';

% Display stimulus
stimProperties.phaseLine=stimProperties.phaseLine+ stimProperties.degPerFrameGabors;
stimProperties=dispOptomotorStim(stimProperties);

% Update the display
delete(lh);
hold on
lh=plot(lastCentroid(:,1),lastCentroid(:,2),'o','Color','r');
hold off
drawnow

% Assign fly centroid to a maze
[lastCentroid]=optoUpdatePreviousCentroid(cenDat,centers,lastCentroid);
sum(sum(isnan(lastCentroid)))
end
% Break KbCheck
while KbCheck
end
    
% Sort centroid data to ROIs based on distance to ROI center and last
% centroid value
[cenDat]=optoMatchROIs2(cenDat,centers,lastCentroid);
close

%% Display tracking to screen for tracking errors

t=0;
j=1;
h=imshow(imagedata);
title('Check tracking and press ENTER to continue')
hold on
lh=plot(cenDat(:,1),cenDat(:,2),'o','Color','r');
for i = 1:size(ROI_coords,1)
rectangle('Position',ROI_bounds(i,:),'EdgeColor','r')
end
hold off
    
while  ~KbCheck
    
       tic
       lastCentroid=cenDat;
       
       % Extract centroid
       [props,imagedata]=decGetCentroid2(vid,stimReference,stimThresh);
       cenDat=reshape([props(:).Centroid],2,length([props(:).Centroid])/2)';
       [cenDat]=optoMatchROIs2(cenDat,centers,lastCentroid);
       
       % Display stimulus
       stimProperties=dispOptomotorStim(stimProperties);

       %Update the tracking display every 2s
       if t>0.3
           shg
           delete(lh);
           set(h,'CData',imagedata);
           hold on
           lh=plot(cenDat(:,1),cenDat(:,2),'o','Color','r');
           hold off
           j=j+1;
           drawnow
           t=0;
       end

       t=t+toc;

end

% Re-sort centroid data
[cenDat]=optoMatchROIs2(cenDat,centers,lastCentroid);

% Break KbCheck
while KbCheck
end


%% Record coordinates of maze arms

arm_coords=zeros(size(ROI_coords,1),2,3);
arm_coords(:,:,1)=[ROI_coords(:,1)+7 ROI_coords(:,4)-7];
arm_coords(:,:,2)=[xCenters ROI_coords(:,2)+7];
arm_coords(:,:,3)=[ROI_coords(:,3)-7 ROI_coords(:,4)-7];

%% Set stimulus block


exp_duration = 600;
stim_duration = 60;
blank_duration = 30;
stim_status = 0;
current_Reference = whiteReference;
current_Thresh = whiteThresh;
ct=1;
tempCount=1;
previous_tStamp=0;
tElapsed=0;
write=boolean(0);

stimProperties.gaborAngles(:)=0;
display=boolean(1);
previous_arm=zeros(numROIs,1);
mazes=1:numROIs;
lastCentroid=cenDat;
movingGabors=zeros(size(stimProperties.phaseLine));
tempCenDat=NaN(100000,2,size(ROI_coords,1));
tempAngDat=NaN(100000,length(stimProperties.gaborAngles));
tempStimDat=NaN(100000,1);
optoPos=zeros(size(ROI_coords,1),1);
optoNeg=zeros(size(ROI_coords,1),1);
handR=zeros(size(ROI_coords,1),1);
handL=zeros(size(ROI_coords,1),1);

%% Run Experiment
shg
tic
while toc < exp_duration

    % Extract centroid
    [props,imagedata]=decGetCentroid2(vid,current_Reference,current_Thresh);
    cenDat=[props(:).Centroid];
    cenDat=reshape(cenDat,2,length(cenDat)/2)';
    [cenDat,centerDistance]=optoMatchCentroids2ROIs(cenDat,centers);
    
    
    % Find the props elements corresponding to previous flies
    tempCenDat(tempCount,:,:) = cenDat';
    lastCentroid=cenDat;
    
    % Determine if fly has changed to a new arm
    [current_arm,previous_arm,stimProperties,movingGabors,changeStim,optoChoice,handedness]=...
        optoDetectArmChange(cenDat,arm_coords,previous_arm,stimProperties,movingGabors,stim_status);

    % Update list of mazes with moving stimulus
    movingGabors(boolean((centerDistance<5).*~movingGabors'))=1;
    tempGabors=zeros(size(stimProperties.phaseLine));
    tempGabors(1:size(ROI_coords,1))=movingGabors;
    tempGabors=boolean(tempGabors);
    
    movingGabors=tempGabors;
    stimProperties.phaseLine(movingGabors)=...
        stimProperties.phaseLine(movingGabors)+stimProperties.degPerFrameGabors(movingGabors);
    
        % write data to temp file
        tempAngDat(tempCount,:) = stimProperties.gaborAngles;
        tempStimDat(tempCount) = stim_status;
        optoPos = optoPos+(optoChoice==1);
        optoNeg = optoNeg+(optoChoice==0);
        handR = handR+(handedness==1);
        handL = handL+(handedness==0);
        
        % Write tempdata to hard drive while stimulus is OFF
        if write
        dlmwrite(cenID, tempCenDat(1:tempCount,:,:), '-append');
        dlmwrite(stimID, tempStimDat(1:tempCount), '-append');
        dlmwrite(angID, tempAngDat(1:tempCount,:), '-append');
        tempCenDat=NaN(100000,2,size(ROI_coords,1));
        tempAngDat=NaN(100000,length(stimProperties.gaborAngles));
        tempStimDat=NaN(100000,1);
        write=boolean(0);
        end
       
       if stim_status == 0
           % Show blank white screen in between stim blocks
           stimProperties=dispBlank(stimProperties);
       else
           % Display stimulus
           stimProperties=dispOptomotorStim(stimProperties);
       end
       
       % Switch between optomotor stimulus and blank screen
       if tElapsed>blank_duration && stim_status==0
           stim_status=1;
           current_Reference = stimReference;
           current_Thresh = stimThresh;
           tElapsed=0;

       elseif tElapsed>stim_duration && stim_status==1
           stim_status=0;
           write=boolean(1);
           current_Reference = whiteReference;
           current_Thresh = whiteThresh;
           tElapsed=0;
           tempCount=0;
       end
       
       if mod(ct,110)==0 && display
           imshow(imagedata)
           hold on
           plot(cenDat(:,1),cenDat(:,2),'o','Color','r')
           hold off
           drawnow
       end
       
       if KbCheck
           display=boolean(0);
       end
       
       if mod(toc,120)<0.02
           tRemaining=ceil((exp_duration-toc)/60);
           disp(strcat(int2str(tRemaining),' minutes remaining'))
       end 
       
       current_tStamp = toc;
       tElapsed=tElapsed+current_tStamp-previous_tStamp;
       previous_tStamp=current_tStamp;
       ct=ct+1;
       tempCount=tempCount+1;

end

stop(vid);
sca

%% Pull in ASCII data, format into matrices
flyTracks.nFlies = numROIs;
flyTracks.stimulusAngle = dlmread(angID);
flyTracks.stimulusAngle=flyTracks.stimulusAngle(:,1:flyTracks.nFlies);
flyTracks.stimulusStatus = dlmread(stimID);
flyTracks.optomotorBias = optoPos./(optoPos+optoNeg);
flyTracks.handedness = handR./(handR+handL);

tmp = dlmread(cenID);
for i = 1:ct-1
    for k = 1:flyTracks.nFlies
        i
        k
        flyTracks.centroid(i, :, k) = tmp(((i - 1) * flyTracks.nFlies) ...
            + k, :);
    end
end

%% Plot traces

%optoPlotTraces(flyTracks)

%% Use arena circling processing to calculate speed, direction, and position

% Pad first two columns with zeros to simulate arena data format
pad=zeros(ct-1,2);
tempdata=flyTracks.centroid(:);
tempdata=reshape(tempdata,ct-1,flyTracks.nFlies*2);
tempdata=[pad tempdata];

% Calculate centroid position relative to ROI
for i=1:flyTracks.nFlies
    tempX = ROI_coords((i),1);
    tempY = ROI_coords((i),2);
    tempdata(:,i*2+1)=tempdata(:,i*2+1)-tempX;
    tempdata(:,i*2+2)=tempdata(:,i*2+2)-tempY;
end

pData = flyBurHandData(tempdata,flyTracks.nFlies,140);

%% Create a histogram plot for each stimulus condition for each fly

flyTracks.xCenters=xCenters;
flyTracks.yCenters=yCenters;
flyTracks.ROI_coords=ROI_coords;
tempTheta=[pData(:).theta];
flyTracks.theta=tempTheta;
flyTracks.r=[pData(:).r];
flyTracks.speed=[pData(:).speed];
flyTracks.binaryimage=binaryimage;
flyTracks.mazeOri=optoDetermineMazeOrientation(binaryimage,ROI_coords);
flyTracks.turnData=optoCountTurns(flyTracks,ROI_coords,flyTracks.mazeOri,xCenters,yCenters);
flyTracks=optoAnalyzeFieldBias(flyTracks);

%% Show ROIs, choice ROIs, and ROI numbers

figure()
imshow(binaryimage)
numbers=1:size(ROI_coords,1);

for i=1:size(ROI_coords,1)
    hold on
    text(xCenters(i),yCenters(i),int2str(numbers(i)),'Color','m')
    hold off
end


for i=1:1:size(ROI_coords,1)
    hold on
    text(cenDat(i,1),cenDat(i,2),int2str(numbers(i)),'Color','R')
    hold off
end

%clearvars -except flyTracks