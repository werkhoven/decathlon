
%% Setup the camera and video object

vid = initializeCamera('pointgrey',1,'F7_BayerRG8_664x524_Mode1');

%% Initialize the stimulus and input ROI properties

ROInum=1;
ROIsize=1600;
spatialFrequency=38;
temporalFrequency=6;

stimProperties=initializeOptomotorStim(ROIsize,ROInum,spatialFrequency,temporalFrequency);

%% Create Placeholder files

% Create temp data files
t = datestr(clock,'mm-dd-yyyy_HH-MM-SS');
fpath = 'C:\Users\debivort\Documents\MATLAB\Processed Decathlon Data\';
cenID = [fpath t '_Centroid.dat'];          % File ID for centroid data
oriID = [fpath t '_Orientation.dat'];       % File ID for orientation
stimID = [fpath t '_StimStatus.dat'];         % File ID for stimulus status
angID = [fpath t '_StimAngle.dat'];         % File ID for stimulus angle

dlmwrite(cenID, [])                         % create placeholder ASCII file
dlmwrite(oriID, [])                         % create placeholder ASCII file
dlmwrite(stimID, [])                         % create placeholder ASCII file

%% Grab reference by averaging out moving stimulus

tic
while toc<10
    stimProperties=dispOptomotorStim(stimProperties);
end

pause(0.5);

%Grab blank background
whiteReference=optoReferenceBackground(vid,stimProperties);

while KbCheck
end

% Reference the background with the moving stimulus (press keyboard to stop
% collecting references)
[stimReference,refCount]=optoReferenceStimulus(vid,stimProperties);

% Set thresholds
whiteThresh = 15;
stimThresh = 22;

[ROI_bounds,ROI_coords,ROI_widths,ROI_heights,binaryimage] = detect_ROIs(stimReference);

%% Continue referencing until the number of centroids equals number of flies

numROIs = size(ROI_coords,1);
numCentroids = 0;
    
while  numCentroids < numROIs-20
    
       % Extract centroid
       [props,imagedata]=decGetCentroid2(vid,stimReference,stimThresh);
        
       % Calculate number of flies with non-zero centroids
       numCentroids=size(props,1);
       
       % Display stimulus
       stimProperties=dispOptomotorStim(stimProperties);
       imshow(imagedata)

       % Open a figure that shows the referenced centroids
       if numCentroids == numROIs
           cenDat=reshape([props(:).Centroid],2,length([props(:).Centroid])/2)';
           imshow(imagedata)
           hold on
           plot(cenDat(:,1),cenDat(:,2),'o','Color','r')

           for i = 1:size(ROI_coords,1)
            rectangle('Position',ROI_bounds(i,:),'EdgeColor','r')
           end
           
           hold off          
           drawnow
       end
end

disp('Check fly centroids and press ENTER to continue')

while KbCheck
end

%% Match ROI indices to gabor indices and centroids indices to ROI indices

%props=reshape(props',1,2,size(props,1));
permutation=optoMatchROIs2Gabors(binaryimage,ROI_coords);
ROI_coords=ROI_coords(permutation,:);
[xCenters,yCenters]=optoROIcenters(binaryimage,ROI_coords);
centers=[xCenters,yCenters];
[loc]=optoMatchROIs2(cenDat,centers);
cenDat=cenDat(loc,:);
%[permu,xCenters,yCenters]=optoMatchROIs(ROI_coords,cenDat,numROIs,binaryimage,0);
%centers=[xCenters yCenters];
%props=props(permu);

%% Display tracking to screen for tracking errors

disp('Check tracking and press ENTER to continue')

% Preallocate segmented tunnel images
    tunnel_images = zeros(max(ROI_heights)+1,max(ROI_widths)+1,length(ROI_bounds));
    t=0;
    j=1;
    
while  ~KbCheck
    
       tic
       
       % Extract centroid
       [props,imagedata]=decGetCentroid2(vid,stimReference,ROI_coords,stimThresh);
       cenDat=reshape([props(:).Centroid],2,length([props(:).Centroid])/2)';
       
       % Display stimulus
       stimProperties=dispOptomotorStim(stimProperties);

       %Update the tracking display every 2s
       if t>0.3
           
           imshow(imagedata)

           hold on

           plot(cenDat(:,1),cenDat(:,2),'o','Color','r')

           for i = 1:size(ROI_coords,1)
            rectangle('Position',ROI_bounds(i,:),'EdgeColor','r')
           end
           hold off
           j=j+1;
           drawnow
           t=0;
       end

       t=t+toc;

end

%% Record coordinates of maze arms

arm_coords=zeros(size(ROI_coords,1),2,3);
arm_coords(:,:,1)=[ROI_coords(:,1) ROI_coords(:,4)];
arm_coords(:,:,2)=[xCenters ROI_coords(:,2)];
arm_coords(:,:,3)=[ROI_coords(:,3) ROI_coords(:,4)];

%% Set stimulus block

exp_duration = 180;
stim_duration = 30;
blank_duration = 15;
stim_status = 0;
current_Reference = whiteReference;
current_Thresh = whiteThresh;

while KbCheck
end
%{
for i=1:length(props)
flyTracks.lastCentroid{i}=props(i,:)';
end
%}
tic
ct=1;
previous_tStamp=0;
tElapsed=0;
stimProperties.gaborAngles(:)=0;
display=boolean(1);
mazes=1:numROIs;

while toc < exp_duration

    % Extract centroid
    [props,imagedata]=decGetCentroid2(vid,current_Reference,ROI_coords,current_Thresh);
    cenDat=[props(:).Centroid];
    cenDat=reshape(cenDat,2,length(cenDat)/2)';
    
    % Detect maze arms returns a permutation vector where the index is the
    % ROI number and the element is the corresponding centroid number
    [loc]=optoDetectMazeArms(cenDat,binaryimage,centers);
    
    % Find the props elements corresponding to previous flies
    flyTracks.centroid = NaN(numROIs,2);
    flyTracks.centroid = cenDat(loc,:);
    
    % Determine check to see if fly has changed to a new arm
    [current_arm,changStim]=optoDetectArmChange(flyTracks.centroid,arm_coords,previous_arm);
    
    %flyTracks.orientation = NaN(1,numROIs);
    %{
        for i = 1:size(props,1)
            % calculate the distance (in px) between previous fly positions and
            % newly detected objects, identify matches.
            oldCoords=[flyTracks.lastCentroid{:}]';
            newFlyCoords = repmat(props(i).Centroid,size(oldCoords,1),1);
            d=sqrt(dot((oldCoords-newFlyCoords),(newFlyCoords-oldCoords),2));
            d=abs(d);

            % a props element corresponds to a fly when the centroid distance
            % is < 18 px since last frame
            flyIdx = find(d < 14);
            % Take the lowest distance if more than one is under threshold
            if length(flyIdx>1)
            flyIdx=find(d==min(d(flyIdx)));
                if length(flyIdx>1)
                    dX=abs(newFlyCoords(1,1)-xCenters(flyIdx));
                    dY=abs(newFlyCoords(1,2)-yCenters(flyIdx));
                    d=dX+dY;
                    flyIdx=flyIdx(find(d==min(d)));
                end
            end
            
            

            if flyIdx
                flyTracks.centroid(flyIdx,:) = single(props(i).Centroid);
                flyTracks.orientation(flyIdx) = single(props(i).Orientation);
                flyTracks.lastCentroid{flyIdx} = single(props(i).Centroid)';
            end

        end
    %}
        % write data to temp file
        dlmwrite(cenID, flyTracks.centroid, '-append')
        %dlmwrite(oriID, flyTracks.orientation, '-append')
        dlmwrite(stimID, stim_status, '-append')
        dlmwrite(angID, stimProperties.gaborAngles(1), '-append')
       
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
           stimProperties.gaborAngles(:)=stimProperties.gaborAngles+120;
           stimProperties.gaborAngles(stimProperties.gaborAngles>360)=90;
           tElapsed=0;

       elseif tElapsed>stim_duration && stim_status==1
           stim_status=0;
           current_Reference = whiteReference;
           current_Thresh = whiteThresh;
           tElapsed=0;
       end
       
       if mod(ct,110)==0 && display
           imshow(imagedata)
           hold on
           plot(flyTracks.centroid(:,1),flyTracks.centroid(:,2),'o','Color','r')
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
       previous_arm=current_arm;
       ct=ct+1;

end

stop(vid);
sca

%% Pull in ASCII data, format into matrices
flyTracks.nFlies = numROIs;
flyTracks.orientation = dlmread(oriID);
flyTracks.stimulusAngle = dlmread(angID);
flyTracks.stimulusStatus = dlmread(stimID);

tmp = dlmread(cenID);
for i = 1:ct
    
    for k = 1:flyTracks.nFlies
        flyTracks.centroid(i, :, k) = tmp(((i - 1) * flyTracks.nFlies) ...
            + k, :);
    end
    
end

%% Plot traces

%optoPlotTraces(flyTracks)

%% Use arena circling processing to calculate speed, direction, and position
%tempdata=flyTracks.centroid(:);
%tempdata=reshape(tempdata,ct,flyTracks.nFlies*2);

% Match flies to ROIs
[perm,xCenters,yCenters,meanX,meanY]=optoMatchROIs(ROI_coords,flyTracks.centroid,flyTracks.nFlies,binaryimage,1);

% Sort data
ROI_coords=ROI_coords(perm,:);
xCenters=xCenters(perm);
yCenters=yCenters(perm);

% Pad first two columns with zeros to simulate arena data format
pad=zeros(ct,2);
tempdata=flyTracks.centroid(:);
tempdata=reshape(tempdata,ct,flyTracks.nFlies*2);
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
%{
for i=1:flyTracks.nFlies
    hold on
    text(meanX(i),meanY(i),int2str(numbers(i)),'Color','R')
    hold off
end
%}

for i=1:1:size(ROI_coords,1)
    hold on
    text(fliesPos(i,1),fliesPos(i,2),int2str(numbers(i)),'Color','R')
    hold off
end

%clearvars -except flyTracks