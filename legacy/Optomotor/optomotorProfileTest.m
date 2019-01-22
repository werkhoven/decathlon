%% Profile test

%% Set stimulus block


exp_duration = 180;
stim_duration = 60;
blank_duration = 30;
stim_status = 0;
current_Reference = whiteReference;
current_Thresh = whiteThresh;
ct=1;
tempCount=1;
previous_tStamp=0;
tElapsed=0;

stimProperties.gaborAngles(:)=0;
display=boolean(1);
previous_arm=zeros(numROIs,1);
mazes=1:numROIs;
lastCentroid=cenDat;
movingGabors=zeros(size(stimProperties.phaseLine));
tempCenDat=NaN(100000,2,size(ROI_coords,1));
tempAngDat=NaN(100000,length(stimProperties.gaborAngles));
tempStimDat=NaN(100000,1);
tempOptoDat=NaN(100000,size(ROI_coords,1));
tempHandDat=NaN(100000,size(ROI_coords,1));
%%
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
        optoDetectArmChange(cenDat,arm_coords,previous_arm,stimProperties,movingGabors);

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
        tempOptoDat(tempCount,:) = optoChoice;
        tempHandDat(tempCount,:) = handedness;
        
        if write
        dlmwrite(cenID, tempCenDat(1:tempCount,:), '-append');
        dlmwrite(stimID, tempStimDat(1:tempCount), '-append');
        dlmwrite(angID, tempAngDat(1:tempCount,:), '-append');
        dlmwrite(optoID, tempOptoDat(1:tempCount,:), '-append');
        dlmwrite(handID, tempHandDat(1:tempCount,:), '-append');
        tempCenDat=NaN(100000,2,size(ROI_coords,1));
        tempAngDat=NaN(100000,length(stimProperties.gaborAngles));
        tempStimDat=NaN(100000,1);
        tempOptoDat=NaN(100000,size(ROI_coords,1));
        tempHandDat=NaN(100000,size(ROI_coords,1));
        write=boolean(0);
        disp('YEA BUDDY')
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