
%% Setup the camera and video object

vid = initializeCamera('pointgrey',1,'F7_BayerRG8_664x524_Mode1');

%% Initialize the stimulus and input ROI properties

ROInum=16;
ROIsize=133;
spatialFrequency=18;
temporalFrequency=6;

stimProps=optoInitializePinWheel;

%% Create Placeholder files

% Create temp data files
t = datestr(clock,'mm-dd-yyyy_HH-MM-SS');
fpath = 'C:\Users\debivort\Documents\MATLAB\Processed Decathlon Data\Optomotor\';
cenID = [fpath t '_Centroid.dat'];            % File ID for centroid data
stimID = [fpath t '_StimStatus.dat'];         % File ID for stimulus status
oriID = [fpath t '_Orientation.dat'];           % File ID for stimulus angle

dlmwrite(cenID, [])                          % create placeholder ASCII file
dlmwrite(stimID, [])                         % create placeholder ASCII file
dlmwrite(oriID, [])                          % create placeholder ASCII file

%% Grab image for ROI detection and segment out ROIs
imagedata=peekdata(vid,1);
ROI_image=imagedata(:,:,1);

% Set image threshold from zero (black) to one (white) for ROI detection
ROI_thresh=0.15;

%Extract ROIs from thresholded image
[ROI_bounds,ROI_coords,ROI_widths,ROI_heights,binaryimage] = detect_ROIs(ROI_image,ROI_thresh);


%% Match ROI indices to gabor indices and centroids indices to ROI indices

permutation=optoMatchROIs2Gabors(binaryimage,ROI_coords);
ROI_coords=ROI_coords(permutation,:);
[xCenters,yCenters]=optoROIcenters(binaryimage,ROI_coords);
centers=[xCenters,yCenters];

%% Search for a fly-sized centroid in each ROI and take new reference for a given ROI when fly moves to new spot

Thresh=13;                                              % Set threshold for centroid extraction
refImage=ROI_image;                                     % Assign reference image
lastCentroid=NaN(size(ROI_coords,1),2);
referenceCentroids=zeros(size(ROI_coords,1),2,10);      % Create placeholder for cen. coords when references are taken
propFields={'Centroid';'Orientation';'Area'};           % Define fields for regionprops
distanceThresh=40;                                      % Distance threshold for assigning centroids to ROI
nRefs=zeros(size(ROI_coords,1),1);                      % Reference number placeholder
numbers=1:size(ROI_coords,1);                           % Numbers to display while tracking
h=imshow(refImage);
title('Check Reference and Tracking - Press any key to continue')
shg

% Turn light ON and set time(seconds) for lights to flash to get flies moving
Screen('FillRect',stimProps.window,[1 1 1],stimProps.windowRect);
Screen('Flip', stimProps.window);
lightDuration=10;
oldStamp=0;
tElapsed=0;

tic
while ~KbCheck
    
    % Display stimulus
    stimProps=optoDispPinWheel(stimProps);
    
    % Take difference image
    imagedata=peekdata(vid,1);
    imagedata=imagedata(:,:,1);
    subtractedData=refImage-imagedata;
    
    % Extract regionprops and record centroid for blobs with area > 30 pixels
    props=regionprops((subtractedData>Thresh),propFields);
    validCentroids=boolean(([props.Area]>11).*([props.Area]<30));
    cenDat=reshape([props(validCentroids).Centroid],2,length([props(validCentroids).Centroid])/2)';
    oriDat=reshape([props(validCentroids).Orientation],1,length([props(validCentroids).Orientation]))';
    [cenDat,oriDat,centerDistance]=optoMatchCentroids2ROIs(cenDat,oriDat,centers,distanceThresh);
    lastCentroid(~isnan(cenDat))=cenDat(~isnan(cenDat));    
    
    % Step through each ROI one-by-one
    for i=1:size(ROI_coords,1)
    
    % Calculate distance to previous locations where references were taken
    tCen=repmat(cenDat(i,:),size(referenceCentroids,3),1);
    d=abs(sqrt(dot((tCen-squeeze(referenceCentroids(i,:,:))'),(squeeze(referenceCentroids(i,:,:))'-tCen),2)));
    
        % Create a new reference image for the ROI if fly is greater than distance thresh
        % from previous reference locations
        if sum(d<18)==0&&sum(isnan(cenDat(i,:)))==0
            nRefs(i)=sum(sum(referenceCentroids(i,:,:)>0));
            referenceCentroids(i,:,mod(nRefs(i)+1,10))=cenDat(i,:);
            newRef=imagedata(ROI_coords(i,2):ROI_coords(i,4),ROI_coords(i,1):ROI_coords(i,3));
            oldRef=refImage(ROI_coords(i,2):ROI_coords(i,4),ROI_coords(i,1):ROI_coords(i,3));
            nRefs(i)=sum(sum(referenceCentroids(i,:,:)>0));                                         % Update num Refs
            averagedRef=newRef.*(1/nRefs(i))+oldRef.*(1-(1/nRefs(i)));               % Weight new reference by 1/nRefs
            refImage(ROI_coords(i,2):ROI_coords(i,4),ROI_coords(i,1):ROI_coords(i,3))=averagedRef;
        end
    end
    
   % Update the plot with new reference
   imshow(refImage);
   
   % Draw last known centroid and reference number indicator
   hold on
   for i=1:size(ROI_coords,1)
       color=[(1/nRefs(i)) 0 (1-1/nRefs(i))];
       color(color>1)=1;
       color(color<0)=0;
       plot(ROI_coords(i,1),ROI_coords(i,2),'o','Linew',3,'Color',color);      
       text(xCenters(i),yCenters(i),int2str(numbers(i)),'Color','m')
       text(lastCentroid(i,1),lastCentroid(i,2),int2str(numbers(i)),'Color','R')
   end
   hold off
   drawnow
   
end

% Reset background to black
Screen('FillRect',stimProps.window,[0 0 0],stimProps.windowRect);
Screen('Flip', stimProps.window);
    
% Break KbCheck
while KbCheck
end
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
       [props,imagedata]=decGetCentroid2(vid,refImage,Thresh,propFields);
       cenDat=reshape([props(:).Centroid],2,length([props(:).Centroid])/2)';
       [cenDat]=optoMatchROIs2(cenDat,centers,lastCentroid);
       
       % Display stimulus
       stimProps=optoDispPinWheel(stimProps);

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

exp_duration = 60;
stim_duration = 15;
blank_duration = 5;
stim_status = 0;
current_Reference = refImage;
current_Thresh = Thresh;
ct=1;
tempCount=1;
previous_tStamp=0;
tElapsed=0;
write=boolean(0);
movingStim=boolean(zeros(size(ROI_coords,1),1));
stim_DispTime=zeros(size(movingStim));
distanceThresh=45;

display=boolean(1);
mazes=1:size(ROI_coords,1);
lastCentroid=cenDat;
tempCenDat=NaN(10000,2,size(ROI_coords,1));
tempOriDat=NaN(10000,1,size(ROI_coords,1));
tempStimDat=NaN(10000,1,size(ROI_coords,1));
propFields={'Centroid';'Orientation'};

%% Run Experiment
shg
tic
while toc < exp_duration

    % Extract centroid
    [props,imagedata]=decGetCentroid2(vid,current_Reference,current_Thresh,propFields);
    cenDat=[props(:).Centroid];
    oriDat=[props(:).Orientation];
    cenDat=reshape(cenDat,2,length(cenDat)/2)';
    oriDat=reshape(oriDat,1,length(oriDat))';
    [cenDat,oriDat,centerDistance]=optoMatchCentroids2ROIs(cenDat,oriDat,centers,distanceThresh);
    
    
    % Find the props elements corresponding to previous flies
    tempCenDat(tempCount,:,:) = cenDat';
    lastCentroid=cenDat;

    % Update list of mazes with moving stimulus
    stim_DispTime(boolean((centerDistance<5)))=0;
    movingStim(boolean((centerDistance<5).*~movingStim))=1;
    movingStim(stim_DispTime>3)=0;
    tempGabors=zeros(size(stimProps.angle));
    tempGabors(1:size(ROI_coords,1))=movingStim;
    tempGabors=boolean(tempGabors);
    stimProps.active=tempGabors;
    
        % write data to temp file
        tempOriDat(tempCount,:,:) = oriDat;
        tempStimDat(tempCount,:,:) = stim_status.*movingStim;
        
        % Write tempdata to hard drive while stimulus is OFF
        if write
        dlmwrite(cenID, tempCenDat(1:tempCount,:,:), '-append');
        dlmwrite(stimID, tempStimDat(1:tempCount,:), '-append');
        dlmwrite(oriID, tempOriDat(1:tempCount,:), '-append');
        tempCenDat=NaN(10000,2,size(ROI_coords,1));
        tempOriDat=NaN(10000,1,size(ROI_coords,1));
        tempStimDat=NaN(10000,1,size(ROI_coords,1));
        write=boolean(0);
        tempCount=0;
        end
       
       if stim_status == 0
           % Show blank white screen in between stim blocks
           dispBlank(stimProps);
       else
           % Display stimulus
           stimProps=optoDispPinWheel(stimProps);
       end
       
       % Switch between optomotor stimulus and blank screen
       if tElapsed>blank_duration && stim_status==0
           stim_status=1;
           current_Reference = refImage;
           current_Thresh = Thresh;
           tElapsed=0;
           Screen('FillRect',stimProps.window,[0 0 0],stimProps.windowRect);

       elseif tElapsed>stim_duration && stim_status==1
           stim_status=0;
           write=boolean(1);
           current_Reference = refImage;
           current_Thresh = Thresh;
           tElapsed=0;
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
       stim_DispTime=stim_DispTime+current_tStamp-previous_tStamp;
       tElapsed=tElapsed+current_tStamp-previous_tStamp;
       previous_tStamp=current_tStamp;
       ct=ct+1;
       tempCount=tempCount+1;

end

stop(vid);
sca

%% Pull in ASCII data, format into matrices
flyTracks.nFlies = size(ROI_coords,1);
flyTracks.stimulusAngle = dlmread(oriID);
flyTracks.stimulusAngle=flyTracks.stimulusAngle(:,1:flyTracks.nFlies);
flyTracks.stimulusStatus = dlmread(stimID);

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



%clearvars -except flyTracks