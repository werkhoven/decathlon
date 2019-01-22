
%% Define parameters - adjust parameters here to fix tracking and ROI segmentation errors

% Experimental parameters
exp_duration=handles.expDuration*60;           % Duration of the experiment in minutes
referenceStackSize=handles.refStack;        % Number of images to keep in rolling reference
referenceFreq=handles.refTime;              % Seconds between reference images
armThresh=7;                                % Minimum pixel distance to end of maze arm for turn scoring
referenceTime = 600;                        % Seconds over which intial reference images are taken
% Tracking parameters
imageThresh=get(handles.slider2,'value');                             % Difference image threshold for detecting centroids
distanceThresh=20;                          % Maximum allowed pixel distance matching centroids to ROIs
speedThresh=20;                              % Maximum allow pixel speed (px/s);

% ROI detection parameters
ROI_thresh=get(handles.slider1,'value');    % Binary image threshold from zero (black) to one (white) for segmentation  
sigma=0.47;                                 % Sigma expressed as a fraction of the image height
kernelWeight=0.34;                          % Scalar weighting of kernel when applied to the image

%% Save labels and create placeholder files for data

t = datestr(clock,'mm-dd-yyyy_HH-MM-SS');
labelID = [handles.fpath '\' t '_labels.dat'];     % File ID for label data
labels = cell2table(labelMaker(handles.labels),'VariableNames',{'Strain' 'Sex' 'Treatment'});
writetable(labels, labelID);

% Create placeholder files

 cenID = [handles.fpath '\' t '_Centroid.dat'];            % File ID for centroid data
 oriID = [handles.fpath '\' t '_Orientation.dat'];         % File ID for orientation angle
 turnID = [handles.fpath '\' t '_RightTurns.dat'];         % File ID for turn data
 
dlmwrite(cenID, []);                          % create placeholder ASCII file
dlmwrite(oriID, []);                          % create placeholder ASCII file
dlmwrite(turnID, []);                         % create placeholder ASCII file

%% Initialize Serial COM for teensy

s = serial('COM1');             % Create Serial Object
set(s,'BaudRate',9600);         % Set baud rate
fopen(s);                       % Open the port

% Read and write from/to the teensy with fread(data)/fwrite(data) 

%% Setup the camera and video object
imaqreset
pause(0.5);
% Camera mode set to 8-bit with 664x524 resolution
vid = initializeCamera('pointgrey',1,'F7_BayerRG8_664x524_Mode1');
pause(0.5);

%% Grab image for ROI detection and segment out ROIs
stop=get(handles.togglebutton10,'value');

while stop~=1;
tic
stop=get(handles.togglebutton10,'value');

% Take single frame
imagedata=peekdata(vid,1);
% Extract red channel
ROI_image=imagedata(:,:,1);

% Update threshold value
ROI_thresh=get(handles.slider1,'value');

% Build a kernel to smooth vignetting
gaussianKernel=buildGaussianKernel(size(ROI_image,2),size(ROI_image,1),sigma,kernelWeight);
ROI_image=(uint8(double(ROI_image).*gaussianKernel));

% Extract ROIs from thresholded image
[ROI_bounds,ROI_coords,ROI_widths,ROI_heights,binaryimage] = detect_ROIs(ROI_image,ROI_thresh);

% Create orientation vector for mazes (upside down Y = 0, right-side up = 1)
mazeOri=optoDetermineMazeOrientation(binaryimage,ROI_coords);
mazeOri=boolean(mazeOri);

% Define a permutation vector to sort ROIs from top-right to bottom left
[ROI_coords,mazeOri]=optoSortROIs(binaryimage,ROI_coords,mazeOri);

% Calculate coords of ROI centers
[xCenters,yCenters]=optoROIcenters(binaryimage,ROI_coords);
centers=[xCenters,yCenters];

set(handles.edit7,'String',num2str(size(ROI_bounds,1)));

if get(handles.togglebutton7,'value')==1
    imshow(binaryimage);
    hold on
    for i = 1:size(ROI_bounds,1)
        rectangle('Position',ROI_bounds(i,:),'EdgeColor','r')
        if mazeOri(i)
            text(centers(i,1)-5,centers(i,2),int2str(i),'Color','m')
        else
            text(centers(i,1)-5,centers(i,2),int2str(i),'Color','b')
        end
    end
    hold off
    drawnow
end

    
set(handles.edit8,'String',num2str(round(1/toc)));
end


%% Automatically average out flies from reference image

refImage=imagedata(:,:,1);                                     % Assign reference image
lastCentroid=centers;                 % Create placeholder for most recent non-NaN centroids
referenceCentroids=zeros(size(ROI_coords,1),2,10);      % Create placeholder for cen. coords when references are taken
propFields={'Centroid';'Orientation';'Area'};           % Define fields for regionprops
nRefs=zeros(size(ROI_coords,1),1);                      % Reference number placeholder
numbers=1:size(ROI_coords,1);                           % Numbers to display while tracking
centStamp=zeros(size(ROI_coords,1),1);
imshow(refImage);

%title('Reference Acquisition In Progress - Press any key to continue')
shg

tElapsed=0;
tic
previous_tStamp=toc;
current_tStamp=0;

while toc<referenceTime&&get(handles.togglebutton11,'value')~=1
    
    % Update image threshold value from GUI
    imageThresh=get(handles.slider2,'value');
    
    % Update tStamps
    current_tStamp=toc;
    set(handles.edit8,'String',num2str(round(1/(current_tStamp-previous_tStamp))));
    tElapsed=tElapsed+current_tStamp-previous_tStamp;
    previous_tStamp=current_tStamp;
    
        timeRemaining = round(referenceTime - toc);
        if timeRemaining < 60; 
            set(handles.edit6, 'String', ['00:00:' sprintf('%0.2d',timeRemaining)]);
            set(handles.edit6, 'BackgroundColor', [1 0.4 0.4]);
        elseif (3600 > timeRemaining) && (timeRemaining > 60);
            min = floor(timeRemaining/60);
            sec = rem(timeRemaining, 60);
            set(handles.edit6, 'String', ['00:' sprintf('%0.2d',min) ':' sprintf('%0.2d',sec)]);
            set(handles.edit6, 'BackgroundColor', [1 1 1]);
        elseif timeRemaining > 3600;
            hr = floor(timeRemaining/3600);
            min = floor(rem(timeRemaining, 3600)/60);
            sec = timeRemaining - hr*3600 - min*60;
            set(handles.edit6, 'String', [sprintf('%0.2d', hr) ':' sprintf('%0.2d',min) ':' sprintf('%0.2d',sec)]);
            set(handles.edit6, 'BackgroundColor', [1 1 1]);
        end
        
        % Take difference image
        imagedata=peekdata(vid,1);
        imagedata=imagedata(:,:,1);
        subtractedData=refImage-imagedata;

        % Extract regionprops and record centroid for blobs with (11 > area > 30) pixels
        props=regionprops((subtractedData>imageThresh),propFields);
        validCentroids=([props.Area]>4&[props.Area]<120);
        cenDat=reshape([props(validCentroids).Centroid],2,length([props(validCentroids).Centroid])/2)';
        oriDat=reshape([props(validCentroids).Orientation],1,length([props(validCentroids).Orientation]))';

        % Match centroids to ROIs by finding nearest ROI center
        [lastCentroid,centStamp,tOriDat]=...
            optoMatchCentroids2ROIs(cenDat,oriDat,centers,speedThresh,distanceThresh,lastCentroid,centStamp,tElapsed);
        % Step through each ROI one-by-one
        for i=1:size(ROI_coords,1)

        % Calculate distance to previous locations where references were taken
        tCen=repmat(lastCentroid(i,:),size(referenceCentroids,3),1);
        d=abs(sqrt(dot((tCen-squeeze(referenceCentroids(i,:,:))'),(squeeze(referenceCentroids(i,:,:))'-tCen),2)));

            % Create a new reference image for the ROI if fly is greater than distance thresh
            % from previous reference locations
            if sum(d<10)==0&&sum(isnan(lastCentroid(i,:)))==0
                nRefs(i)=sum(sum(referenceCentroids(i,:,:)>0));
                referenceCentroids(i,:,mod(nRefs(i)+1,10))=lastCentroid(i,:);
                newRef=imagedata(ROI_coords(i,2):ROI_coords(i,4),ROI_coords(i,1):ROI_coords(i,3));
                oldRef=refImage(ROI_coords(i,2):ROI_coords(i,4),ROI_coords(i,1):ROI_coords(i,3));
                nRefs(i)=sum(sum(referenceCentroids(i,:,:)>0));                                         % Update num Refs
                averagedRef=newRef.*(1/nRefs(i))+oldRef.*(1-(1/nRefs(i)));               % Weight new reference by 1/nRefs
                refImage(ROI_coords(i,2):ROI_coords(i,4),ROI_coords(i,1):ROI_coords(i,3))=averagedRef;
            end
        end
        
        
       if get(handles.togglebutton7,'value')==1
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
       
    if get(handles.togglebutton9, 'Value') == 1;
        waitfor(handles.togglebutton9, 'Value', 0)
    end

end

%% Display tracking to screen for tracking errors


ct=1;    
imshow(imagedata);
pixDistSize=100;                    % Num values to record in p
pixelDist=NaN(pixDistSize,1);       % Distribution of total number of pixels above image threshold
tElapsed=0;
shg
%title('Displaying Tracking for 120s - Please check tracking and ROIs')
tic   

while  toc<referenceTime && get(handles.togglebutton12,'value')~=1 || ct<pixDistSize;
            
imageThresh=get(handles.slider2,'value');

        % Update time stamps
        current_tStamp=toc;
        tElapsed=tElapsed+current_tStamp-previous_tStamp;
        set(handles.edit8,'String',num2str(round(1/(current_tStamp-previous_tStamp))));
        previous_tStamp=current_tStamp;

            timeRemaining = round(referenceTime - toc);
                if timeRemaining < 60; 
                    set(handles.edit6, 'String', ['00:00:' sprintf('%0.2d',timeRemaining)]);
                    set(handles.edit6, 'BackgroundColor', [1 0.4 0.4]);
                elseif (3600 > timeRemaining) && (timeRemaining > 60);
                    min = floor(timeRemaining/60);
                    sec = rem(timeRemaining, 60);
                    set(handles.edit6, 'String', ['00:' sprintf('%0.2d',min) ':' sprintf('%0.2d',sec)]);
                    set(handles.edit6, 'BackgroundColor', [1 1 1]);
                elseif timeRemaining > 3600;
                    hr = floor(timeRemaining/3600);
                    min = floor(rem(timeRemaining, 3600)/60);
                    sec = timeRemaining - hr*3600 - min*60;
                    set(handles.edit6, 'String', [sprintf('%0.2d', hr) ':' sprintf('%0.2d',min) ':' sprintf('%0.2d',sec)]);
                    set(handles.edit6, 'BackgroundColor', [1 1 1]);
                end

               % Get centroids and sort to ROIs
               imagedata=peekdata(vid,1);
               imagedata=refImage-imagedata(:,:,1);
               props=regionprops((imagedata>imageThresh),propFields);

               % Match centroids to ROIs by finding nearest ROI center
               validCentroids=([props.Area]>4&[props.Area]<120);
               cenDat=reshape([props(validCentroids).Centroid],2,length([props(validCentroids).Centroid])/2)';
               oriDat=reshape([props(validCentroids).Orientation],1,length([props(validCentroids).Orientation]))';
               [lastCentroid,centStamp,tOriDat]=...
                    optoMatchCentroids2ROIs(cenDat,oriDat,centers,speedThresh,distanceThresh,lastCentroid,centStamp,tElapsed);
               %Update display if display tracking is ON
               if get(handles.togglebutton7,'Value') == 1;
                   imshow(imagedata>imageThresh);
                   hold on
                   % Mark centroids
                   plot(lastCentroid(:,1),lastCentroid(:,2),'o','Color','r');
                   % Draw rectangles to indicate ROI bounds
                   %{
                   for i = 1:size(ROI_coords,1)
                    rectangle('Position',ROI_bounds(i,:),'EdgeColor','r')
                   end
                   %}
               hold off
               drawnow
               end
               
               pixelDist(mod(ct,pixDistSize)+1)=sum(sum(imagedata>imageThresh));
               mod(ct,pixDistSize)+1
               ct=ct+1;
   
   % Pause the script if the pause button is hit
   if get(handles.togglebutton9, 'Value') == 1;
      waitfor(handles.togglebutton9, 'Value', 0)    
   end

end
   
pixStd=std(pixelDist);      % Std deviation of pixels above threshold when the reference is good
pixMean=nanmean(pixelDist);

%% Calculate coordinates of end of each maze arm

arm_coords=zeros(size(ROI_coords,1),2,6);
w=ROI_bounds(:,3);
h=ROI_bounds(:,4);
xShift=w.*0.15;
yShift=w.*0.15;

% Coords 1-3 are for right-side down mazes
arm_coords(:,:,1)=[ROI_coords(:,1)+xShift ROI_coords(:,4)-yShift];
arm_coords(:,:,2)=[xCenters ROI_coords(:,2)+yShift];
arm_coords(:,:,3)=[ROI_coords(:,3)-xShift ROI_coords(:,4)-yShift];

% Coords 4-6 are for right-side up mazes
arm_coords(:,:,4)=[ROI_coords(:,1)+xShift ROI_coords(:,2)+yShift];
arm_coords(:,:,5)=[xCenters ROI_coords(:,4)-yShift];
arm_coords(:,:,6)=[ROI_coords(:,3)-xShift ROI_coords(:,2)+yShift];

%% Set experiment parameters

referenceFreq = referenceFreq;                   
refStack=repmat(refImage,1,1,referenceStackSize);   % Create placeholder for 5-image rolling reference.
refCount=0;
aboveThresh=ones(10,1)*pixMean;                      % Num pixels above threshold last 5 frames
pixDev=ones(10,1);                                   % Num Std. of aboveThresh from mean
noiseCt=1;
ct=1;                                               % Frame counter
tempCount=1;
previous_tStamp=0;
tElapsed=0;
centStamp=zeros(size(ROI_coords,1),1);
turntStamp=zeros(size(ROI_coords,1),1);

previous_refUpdater=0;                          % Compared to current_refUpdater to update the reference at correct freq.
write=boolean(0);                               % Data written to hard drive when true

display=boolean(1);                             % Updates display every 2s when true
mazes=1:size(ROI_coords,1);
previous_arm=zeros(size(ROI_coords,1),1);

%% Set the LED status and permutation vector

permuteLEDs = [1 24 2 23 3 22 4 21 5 20 6 ...
               19 7 18 8 17 9 16 34 48 35 ...
               47 36 46 37 45 38 44 39 43 ...
               40 42 41 13 12 14 11 15 10 ...
               82 33 83 32 84 31 85 30 86 ...
               29 87 28 88 27 89 26 90 25 ...
               91 96 92 95 93 94 49 72 50  ...
               71 51 70 52 69 53 68 54 67 ...
               55 66 56 81 115 80 116 79  ...
               117 78 118 77 119 76 120 75 ...
               73 74 64 63 65 62 139 61   ...
               140 60 141 59 142 58 143 57 ...
               144 114 100 113 101 112 102 ...
               111 103 110 104 109 105 108 ...
               106 107 130 129 131 128 132 ...
               127 133 126 134 125 135 124 ...
               136 123 137 122 138 121 160 ...
               99 161 98 162 97 163 168  ...
               164 167 165 166 191 190 192 ...
               189 169 188 170 187 171 159 ...
               211 158 212 157 213 156 214 ...
               155 215 154 216 153 145 152 ...
               146 151 147 150 148 149 179 ...
               178 180 177 181 176 182 175 ...
               183 174 184 173 185 172 186 ...
               210 193 209 194 208 195 207 ...
               196 206 197 205 198 204 199 ...
               203  200  202  201];  
LEDs = boolean(zeros(size(ROI_coords,1),3));
targetPWM=1500;                                     % Sets the max PWM for LEDs

%% Run Experiment
shg
tic
while toc < exp_duration
    
        % Grab new time stamp
        current_tStamp = toc;
        tElapsed=tElapsed+current_tStamp-previous_tStamp;
        set(handles.edit8,'String',num2str(round(1/(current_tStamp-previous_tStamp))));
        previous_tStamp=current_tStamp;
        ct=ct+1;
        tempCount=tempCount+1;

        % Get framerate delay to slow acquisition
        delay=str2double(get(handles.edit9,'String'));
        delay=delay/1000;
        pause(delay);
    
        % Update clock in the GUI
        timeRemaining = round(exp_duration - toc);
        if timeRemaining < 60; 
            set(handles.edit6, 'String', ['00:00:' sprintf('%0.2d',timeRemaining)]);
            set(handles.edit6, 'BackgroundColor', [1 0.4 0.4]);
        elseif (3600 > timeRemaining) && (timeRemaining > 60);
            min = floor(timeRemaining/60);
            sec = rem(timeRemaining, 60);
            set(handles.edit6, 'String', ['00:' sprintf('%0.2d',min) ':' sprintf('%0.2d',sec)]);
            set(handles.edit6, 'BackgroundColor', [1 1 1]);
        elseif timeRemaining > 3600;
            hr = floor(timeRemaining/3600);
            min = floor(rem(timeRemaining, 3600)/60);
            sec = timeRemaining - hr*3600 - min*60;
            set(handles.edit6, 'String', [sprintf('%0.2d', hr) ':' sprintf('%0.2d',min) ':' sprintf('%0.2d',sec)]);
            set(handles.edit6, 'BackgroundColor', [1 1 1]);
        end
        
        % Capture frame and extract centroid
        imagedata=peekdata(vid,1);
        diffImage=refImage-imagedata(:,:,1);
        props=regionprops((diffImage>imageThresh),propFields);
        
        % update reference image and ROI_positions at the reference frequency and print time remaining 
        current_refUpdater=mod(toc,referenceFreq);
        aboveThresh(mod(ct,10)+1)=sum(sum(diffImage>imageThresh));
        pixDev(mod(ct,10)+1)=(nanmean(aboveThresh)-pixMean)/pixStd;
        
        % Only gather centroids and record turns if noise is below
        % threshold
        if pixDev(mod(ct,10)+1)<8

            % Match centroids to ROIs by finding nearest ROI center
            validCentroids=([props.Area]>4&[props.Area]<120);
            cenDat=reshape([props(validCentroids).Centroid],2,length([props(validCentroids).Centroid])/2)';
            oriDat=reshape([props(validCentroids).Orientation],1,length([props(validCentroids).Orientation]))';
            [lastCentroid,centStamp,tOriDat]=...
                optoMatchCentroids2ROIs(cenDat,oriDat,centers,speedThresh,distanceThresh,lastCentroid,centStamp,tElapsed);

            % Determine if fly has changed to a new arm
            [current_arm,previous_arm,changedArm,rightTurns,turntStamp]=...
                detectArmChange(lastCentroid,arm_coords,previous_arm,mazeOri,armThresh,turntStamp,tElapsed);
            
            % Determine if new arm is LED ON or LED OFF
            

            %Displays the turn scores of maze 13 in real time as a sanity check
            %{
             if changedArm(86)
                    disp(rightTurns(86))
             end
            %}

            turnArm=NaN(size(ROI_coords,1),1);
            turnArm(changedArm)=current_arm(changedArm);
            
            % Detect choice with respect to the light
            lightChoice=decDetectLightChoice(changedArm,currentArm,LEDs);
            
            % Choose a new LED for flies that just made a turn
            LEDs = decUpdateLEDs(changedArm,turnArm,LEDs,permuteLEDs);
            
            % Write new LED values to teensy
            decWriteLEDs(LEDs,targetPWM,s);
            
            
            % Write data to the hard drive
            dlmwrite(cenID, lastCentroid', '-append');
            dlmwrite(oriID, [tElapsed oriDat'], '-append');
            dlmwrite(turnID, turnArm', '-append');
        end

        % Update the display every 30 frames
        if mod(ct,30)==0 && get(handles.togglebutton7,'value')==1
           %imagedata(:,:,1)=uint8((diffImage>imageThresh).*255);
           imshow(imagedata(:,:,1))
           hold on
           plot(lastCentroid(:,1),lastCentroid(:,2),'o','Color','r')
           hold off
           drawnow
        end

        % Display current noise level once/sec
        if mod(ct,round(60/delay))==0
            currentDev=mean(pixDev)
        end
        
        % If noise in the image goes more than 6 std above mean, wipe the
        % old references and create new ones            

        if current_refUpdater<previous_refUpdater||mean(pixDev)>8
            
            % If noise is above threshold: reset reference stack,
            % aboveThresh, and pixDev
            % Otherwise, just update the stack with a new reference
            if mean(pixDev)>10
               refStack=repmat(imagedata(:,:,1),1,1,size(refStack,3));
               refImage=uint8(mean(refStack,3));
               aboveThresh=ones(10,1)*pixMean;
               pixDev=ones(10,1);
               disp('NOISE THRESHOLD REACHED, REFERENCES RESET')
            else
               % Update reference
               refCount=refCount+1;
               refStack(:,:,mod(size(refStack,3),refCount)+1)=imagedata(:,:,1);
               refImage=uint8(mean(refStack,3));
            end
           
           % Update ROI threshold value
            ROI_thresh=get(handles.slider1,'value');
            ROI_image=(uint8(double(imagedata(:,:,1)).*gaussianKernel));
            % Extract ROIs from thresholded image
            [ROI_bounds,ROI_coords,ROI_widths,ROI_heights,binaryimage] = detect_ROIs(ROI_image,ROI_thresh);
            % Create orientation vector for mazes (upside down Y = 0, right-side up = 1)
            mazeOri=optoDetermineMazeOrientation(binaryimage,ROI_coords);
            mazeOri=boolean(mazeOri);
            % Define a permutation vector to sort ROIs from top-right to bottom left
            [ROI_coords,mazeOri]=optoSortROIs(binaryimage,ROI_coords,mazeOri);
            % Calculate coords of ROI centers
            [xCenters,yCenters]=optoROIcenters(binaryimage,ROI_coords);
            centers=[xCenters,yCenters];
           
        end 
        previous_refUpdater=current_refUpdater;
   
   if get(handles.togglebutton9, 'Value') == 1;
      waitfor(handles.togglebutton9, 'Value', 0)   
   end
end

%% Disconnect the teensy

fclose(s);       % Close the COM port
delete(s);       % Delete Serial Object

%% Pull in ASCII data, format into matrices

disp('Experiment Complete')
disp('Importing Data - may take a few minutes...')
flyTracks=[];
flyTracks.nFlies = size(ROI_coords,1);
tmpOri = dlmread(oriID);
flyTracks.tStamps=tmpOri(:,1);
flyTracks.orientation=tmpOri(:,2:end);
flyTracks.rightTurns=dlmread(turnID);
flyTracks.mazeOri=mazeOri;
flyTracks.labels = readtable(labelID);

tmp = dlmread(cenID);
centroid=NaN(size(tmp,1)/2,2,flyTracks.nFlies);
xCen=mod(1:size(tmp,1),2)==1;
yCen=mod(1:size(tmp,1),2)==0;

for k = 1:flyTracks.nFlies
    k
    centroid(:, 1, k) = tmp(xCen, k)';
    centroid(:, 2, k) = tmp(yCen, k)';
end

flyTracks.centroid=centroid;

%% Discard the first turn in every maze
turns=flyTracks.rightTurns;
[r,c]=find(~isnan(turns));
c=[0;c];
t1rows=r(find(diff(c)));
c(1)=[];
t1cols=unique(c);
for i=1:length(t1cols)
    turns(t1rows(i),t1cols(i))=NaN;
end
flyTracks.rightTurns=turns;

% Calculate turn probability
numTurns=sum(~isnan(turns));
flyTracks.numTurns=numTurns;
flyTracks.tSeq=NaN(max(flyTracks.numTurns),flyTracks.nFlies);

for i=1:flyTracks.nFlies
    tSeq=flyTracks.rightTurns(~isnan(flyTracks.rightTurns(:,i)),i);
    tSeq=diff(tSeq);
    if flyTracks.mazeOri(i)
        flyTracks.tSeq(1:length(tSeq),i)=tSeq==1|tSeq==-2;
    elseif ~flyTracks.mazeOri(i)
        flyTracks.tSeq(1:length(tSeq),i)=tSeq==-1|tSeq==2;
    end
end
flyTracks.rBias=nansum(flyTracks.tSeq)./nansum(~isnan(flyTracks.tSeq));
%[nansum(flyTracks.tSeq)' nansum(~isnan(flyTracks.tSeq))' ...
%(nansum(flyTracks.tSeq)./nansum(~isnan(flyTracks.tSeq)))']
bins=0:0.05:1;
c=histc(flyTracks.rBias(~isnan(flyTracks.rBias)),bins);
mad(flyTracks.rBias(~isnan(flyTracks.rBias)))
c=c./(sum(c));
plot(c);
set(gca,'Xtick',(1:2:21),'XtickLabel',0:0.1:1);
axis([0 length(bins) 0 max(c)+0.05]);
shg

% Clean up the workspace
save(strcat('flyTracks',t,'.mat'),'flyTracks');


