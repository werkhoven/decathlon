%% Define parameters - adjust parameters here to fix tracking and ROI segmentation errors
warning OFF;

% Experimental parameters
exp_duration=60;           % Duration of the experiment in minutes
referenceStackSize=5;       % Number of images to keep in rolling reference
referenceFreq=3;            % Minutes between reference images
armThresh=40;                % Minimum pixel distance to end of maze arm for turn scoring

% Tracking parameters
imageThresh=8;             % Difference image threshold for detecting centroids
distanceThresh=42;          % Maximum allowed pixel distance matching centroids to ROIs

% ROI detection parameters
ROI_thresh=0.08;            % Binary image threshold from zero (black) to one (white) for segmentation  
sigma=0.47;                 % Sigma expressed as a fraction of the image height
kernelWeight=0.30;          % Scalar weighting of kernel when applied to the image

%% Initialize the optomotor stimulus

nRow=9;
nCol=8;
rect_W=178;
rect_H=118;

%% Define filepath and create Placeholder files
[fpath] = uigetdir('C:\Users\debivort\Desktop\Decathlon Data Files','Select a save destination');

% Create temp data files for each feature to record
t = datestr(clock,'mm-dd-yyyy_HH-MM-SS');

% Define file path
cenID = [fpath t '_Centroid.dat'];            % File ID for centroid data
oriID = [fpath t '_Orientation.dat'];         % File ID for orientation angle
turnID = [fpath t '_RightTurns.dat'];         % File ID for turn data
optoID = [fpath t '_OptoChoice.dat'];         % File ID for turn data
stimID = [fpath t '_stimChange.dat'];
angID = [fpath t '_stimAngle.dat'];

dlmwrite(cenID, [])                          % create placeholder ASCII file
dlmwrite(oriID, [])                          % create placeholder ASCII file
dlmwrite(turnID, [])                         % create placeholder ASCII file
dlmwrite(optoID, [])                         % create placeholder ASCII file
dlmwrite(stimID, [])                         % create placeholder ASCII file
dlmwrite(angID, [])

%% Setup the camera and video object

% Camera mode set to 8-bit with 664x524 resolution
vid = autoTrackerInitializeCamera('pointgrey',1,'F7_BayerRG8_1328x1048_Mode0');
pause(1);

%% Grab image for ROI detection and segment out ROIs

% Take single frame
imagedata=peekdata(vid,1);
% Extract red channel
ROI_image=imagedata(:,:,1);

% Build a kernel to smooth vignetting
gaussianKernel=buildGaussianKernel(size(ROI_image,2),size(ROI_image,1),sigma,kernelWeight);
ROI_image=(uint8(double(ROI_image).*gaussianKernel));
imshow(ROI_image)

% Extract ROIs from thresholded image
[ROI_bounds,ROI_coords,ROI_widths,ROI_heights,binaryimage] = detect_ROIs(ROI_image,ROI_thresh);

% Create orientation vector for mazes (upside down Y = 0, right-side up = 1)
mazeOri=optoDetermineMazeOrientation(binaryimage,ROI_coords);
mazeOri=boolean(mazeOri);

%% Match ROI indices to gabor indices and centroids indices to ROI indices

% Define a permutation vector to sort ROIs from top-right to bottom left
[ROI_coords,mazeOri]=optoSortROIs(binaryimage,ROI_coords,mazeOri);

% Calculate coords of ROI centers
[xCenters,yCenters]=optoROIcenters(binaryimage,ROI_coords);
centers=[xCenters,yCenters];

%% Automatically average out flies from reference image

refImage=ROI_image;                                     % Assign reference image
lastCentroid=NaN(size(ROI_coords,1),2);                 % Create placeholder for most recent non-NaN centroids
referenceCentroids=zeros(size(ROI_coords,1),2,10);      % Create placeholder for cen. coords when references are taken
propFields={'Centroid';'Orientation';'Area'};           % Define fields for regionprops
nRefs=zeros(size(ROI_coords,1),1);                      % Reference number placeholder
numbers=1:size(ROI_coords,1);                           % Numbers to display while tracking
h=imshow(refImage);
title('Reference Acquisition In Progress - Press any key to continue')
shg

tic
while toc<80
    
    % Take difference image
    imagedata=peekdata(vid,1);
    imagedata=imagedata(:,:,1);
    subtractedData=refImage-imagedata;
    
    % Extract regionprops and record centroid for blobs with (11 > area > 30) pixels
    props=regionprops((subtractedData>imageThresh),propFields);
    validCentroids=boolean(([props.Area]>7).*([props.Area]<500));
    cenDat=reshape([props(validCentroids).Centroid],2,length([props(validCentroids).Centroid])/2)';
    oriDat=reshape([props(validCentroids).Orientation],1,length([props(validCentroids).Orientation]))';
    
    % Match centroids to ROIs by finding nearest ROI center
    [cenDat,oriDat,centerDistance]=optoMatchCentroids2ROIs(cenDat,oriDat,centers,distanceThresh);
    lastCentroid(~isnan(cenDat))=cenDat(~isnan(cenDat));    
    
    % Step through each ROI one-by-one
    for i=1:size(ROI_coords,1)
    
    % Calculate distance to previous locations where references were taken
    tCen=repmat(cenDat(i,:),size(referenceCentroids,3),1);
    d=abs(sqrt(dot((tCen-squeeze(referenceCentroids(i,:,:))'),(squeeze(referenceCentroids(i,:,:))'-tCen),2)));
    
        % Create a new reference image for the ROI if fly is greater than distance thresh
        % from previous reference locations
        if sum(d<10)==0&&sum(isnan(cenDat(i,:)))==0
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
   imshow(subtractedData>imageThresh);
   
   % Draw last known centroid for each ROI and update ref. number indicator
   hold on
   for i=1:size(ROI_coords,1)
       color=[(1/nRefs(i)) 0 (1-1/nRefs(i))];
       color(color>1)=1;
       color(color<0)=0;
       plot(ROI_coords(i,1),ROI_coords(i,2),'o','Linew',3,'Color',color);      
       text(ROI_coords(i,1),ROI_coords(i,2)+15,int2str(numbers(i)),'Color','m')
       text(lastCentroid(i,1),lastCentroid(i,2),int2str(numbers(i)),'Color','R')
   end
   hold off
   drawnow
   
end

%{
% Break KbCheck
while KbCheck
end
%}
close

%% Display tracking to screen for tracking errors

h=imshow(imagedata);
shg
title('Displaying Tracking for 30s - Please check tracking and ROIs')
tic   
while  toc<10
    
       
       % Define previous position
       lastCentroid=cenDat;
       
       % Get centroids and sort to ROIs
       imagedata=peekdata(vid,1);
       imagedata=refImage-imagedata(:,:,1);
       
       % Extract regionprops and record centroid for blobs with (11 > area > 30) pixels
       props=regionprops((imagedata>imageThresh),propFields);
       validCentroids=boolean(([props.Area]>7).*([props.Area]<500));
       cenDat=reshape([props(validCentroids).Centroid],2,length([props(validCentroids).Centroid])/2)';
       oriDat=reshape([props(validCentroids).Orientation],1,length([props(validCentroids).Orientation]))';
       
       % Match centroids to ROIs by finding nearest ROI center
       [cenDat,oriDat,centerDistance]=optoMatchCentroids2ROIs(cenDat,oriDat,centers,distanceThresh);
       lastCentroid(~isnan(cenDat))=cenDat(~isnan(cenDat));       

       %Update display
       imshow(imagedata);
       
       hold on
       % Mark centroids
       plot(cenDat(:,1),cenDat(:,2),'o','Color','r');
       % Draw rectangles to indicate ROI bounds
       for i = 1:size(ROI_coords,1)
        rectangle('Position',ROI_bounds(i,:),'EdgeColor','r')
       end
       hold off
       drawnow

end

%{
% Break KbCheck
while KbCheck
end
%}


%% Calculate coordinates of end of each maze arm

arm_coords=zeros(size(ROI_coords,1),2,3);

% Coords 1-3 are for right-side down mazes
arm_coords(:,:,1)=[ROI_coords(:,1)+7 ROI_coords(:,4)-7];
arm_coords(:,:,2)=[xCenters ROI_coords(:,2)+7];
arm_coords(:,:,3)=[ROI_coords(:,3)-7 ROI_coords(:,4)-7];

%{
% Coords 4-6 are for right-side up mazes
arm_coords(:,:,4)=[ROI_coords(:,1)+7 ROI_coords(:,2)+7];
arm_coords(:,:,5)=[xCenters ROI_coords(:,2)+7];
arm_coords(:,:,6)=[ROI_coords(:,3)-7 ROI_coords(:,2)+7];
%}
%% Set experiment parameters

% Initialize the stimulus
stimProps=optoInitializeBlackWhiteStim(nRow,nCol,rect_W,rect_H);

exp_duration = exp_duration*60;                     % Convert duration from min. to seconds
stim_duration = 60;
blank_duration = 15;
stim_status = 1;
referenceFreq = referenceFreq*60;                   % Convert ref. freq. from min to seconds
refStack=repmat(refImage,1,1,referenceStackSize);   % Create placeholder for 5-image rolling reference.
refCount=0;
ct=1;                                               % Frame counter
lastCentroid=cenDat;                                % Define previous centroids
propFields={'Centroid';'Orientation';'Area'};       % Features to record
tempCount=1;
previous_tStamp=0;
tElapsed=0;
write=boolean(0);                                   % Data written to hard drive when true
stimOFF=boolean(zeros(size(ROI_coords,1),1));

display=boolean(1);                                 % Updates display every 2s when true
mazes=1:size(ROI_coords,1);
previous_arm=zeros(size(ROI_coords,1),1);

%% Run Experiment
shg
tic
while toc < exp_duration

    % Take difference image
    imagedata=peekdata(vid,1);
    imagedata=imagedata(:,:,1);
    subtractedData=refImage-imagedata;
    
    % Extract regionprops and record centroid for blobs with (11 > area > 30) pixels
    props=regionprops((subtractedData>imageThresh),propFields);
    validCentroids=boolean(([props.Area]>7).*([props.Area]<500));
    cenDat=reshape([props(validCentroids).Centroid],2,length([props(validCentroids).Centroid])/2)';
    oriDat=reshape([props(validCentroids).Orientation],1,length([props(validCentroids).Orientation]))';
    
    % Match centroids to ROIs by finding nearest ROI center
    [cenDat,oriDat,centerDistance]=optoMatchCentroids2ROIs(cenDat,oriDat,centers,distanceThresh);
    lastCentroid(~isnan(cenDat))=cenDat(~isnan(cenDat));   
    
    % Find flies that enter the center of the ROI
    inCenter=centerDistance<8;
    stimOFF=stimOFF|inCenter;
    
    % Determine if fly has changed to a new arm
    [current_arm,previous_arm,stimProps,changedArm,optoChoice,rightTurns,stimOFF]=...
    optoDetectArmChange(cenDat,arm_coords,previous_arm,stimProps,stim_status,stimOFF,mazeOri,armThresh);

    % Update the stimuli
    stimProps=optoDispBlackWhiteStim(stimProps,stimOFF);
    
    % Record the angle for stimuli that are currently ON
    tmpAng=NaN(size(stimProps.angle,1),1);
    tmpAng(~boolean(stimOFF))=stimProps.angle(~boolean(stimOFF));    
    
    % Write data to the hard drive
    dlmwrite(cenID, cenDat', '-append');
    dlmwrite(oriID, [tElapsed oriDat'], '-append');
    dlmwrite(turnID, rightTurns', '-append');
    dlmwrite(optoID, optoChoice', '-append');
    dlmwrite(stimID, stimOFF', '-append');
    dlmwrite(angID, tmpAng', '-append');
    
    %{
    % Switch between blank and stimulus at appropriate times
           % Switch between optomotor stimulus and blank screen
       if tElapsed>blank_duration && stim_status==0
           stim_status=1;
           current_Reference = refImage;
           current_Thresh = imageThresh;
           tElapsed=0;
           Screen('FillRect',stimProps.window,[0 0 0],stimProps.windowRect);

       elseif tElapsed>stim_duration && stim_status==1
           stim_status=0;
           write=boolean(1);
           current_Reference = refImage;
           current_Thresh = imageThresh;
           tElapsed=0;
       end
    %}
    % Update the display every 120 frames
    if mod(ct,10)==0 && display
       imshow(imagedata(:,:,1))
       hold on
       plot(cenDat(:,1),cenDat(:,2),'o','Color','r')
       hold off
       drawnow
    end
    
    % Disable the display by pressing a key to increase frame rate
    
    if KbCheck
       display=boolean(0);
    end
    
    
    % Print time remaining every 2 minutes and update reference image
    if mod(toc,referenceFreq)<0.02
       tRemaining=ceil((exp_duration-toc)/60);
       disp(strcat(int2str(tRemaining),' minutes remaining'))
       refCount=refCount+1;
       refStack(:,:,mod(size(refStack,3),refCount)+1)=imagedata(:,:,1);
       refImage=uint8(mean(refStack,3));
    end 
    
    % Grab new time stamp
    current_tStamp = toc;
    tElapsed=tElapsed+current_tStamp-previous_tStamp;
    %frameRate=1/(current_tStamp-previous_tStamp)
    previous_tStamp=current_tStamp;
    ct=ct+1;
    tempCount=tempCount+1;

end

stop(vid);
sca

%% Pull in ASCII data, format into matrices
disp('Experiment Complete')
disp('Importing Data - may take a few minutes...')
flyTracks.nFlies = size(ROI_coords,1);
tmpOri = dlmread(oriID);
flyTracks.tStamps=tmpOri(:,1);
flyTracks.optoSeq=dlmread(optoID);
flyTracks.turnSeq=dlmread(turnID);
flyTracks.orientation=tmpOri(:,2:end);
flyTracks.mazeOri=mazeOri;

tmp = dlmread(cenID);
for i = 1:size(tmp,1)/2
    for k = 1:flyTracks.nFlies
        flyTracks.centroid(i, :, k) = tmp(i*2-1:i*2, k)';
    end
end

%% Calculate turn bias and optomotor bias

flyTracks.optoProb=nanmean(flyTracks.optoSeq,1);
flyTracks.rightProb=nanmean(flyTracks.turnSeq,1);

%% Analyze orientation in frames following stim change

flyTracks.dOri=diff(flyTracks.orientation);

flyTracks.stimBounds=dlmread(stimID);
stimBounds=diff(flyTracks.stimBounds)==1;
flyTracks.ang=dlmread(angID);
windowSize=80;
flyTracks.oriTrace=NaN(windowSize,flyTracks.nFlies);

for i=1:flyTracks.nFlies
    tmpOriTrace=NaN(windowSize,sum(stimBounds(:,i)));
    tmpBounds=find(stimBounds(:,i)==1);
    tmpBounds=tmpBounds-1;
    i
    if size(tmpOriTrace,2)>0
    for j=1:size(tmpOriTrace,2)
        if tmpBounds(j)<(size(flyTracks.orientation,1)-windowSize)&&tmpBounds(j)>0
            tmpOriTrace(:,j)=flyTracks.orientation(tmpBounds(j):tmpBounds(j)+windowSize-1,i);
            tmpOriTrace(:,j)=tmpOriTrace(:,j)-tmpOriTrace(1,j);
            flyTracks.ang(tmpBounds(j))
            if flyTracks.ang(tmpBounds(j))==0||flyTracks.ang(tmpBounds(j))==120||flyTracks.ang(tmpBounds(j))==240
                tmpOriTrace(:,j)=tmpOriTrace(:,j).*-1;
            elseif flyTracks.ang(tmpBounds(j))==60||flyTracks.ang(tmpBounds(j))==180||flyTracks.ang(tmpBounds(j))==300
                tmpOriTrace(:,j)=tmpOriTrace(:,j).*1;
            end
            
        end
    end
    flyTracks.oriTrace(:,i)=nanmean(tmpOriTrace,2);
    else
    flyTracks.oriTrace(:,i)=NaN(windowSize,1);    
    end
end

for i=30:35
    figure();
    plot(flyTracks.oriTrace(:,i))
end

% Clean up the workspace
close all
clearvars -except flyTracks
