%% Setup the camera and video object

%vid = initializeCamera('pointgrey',1,'F7_BayerRG8_664x524_Mode1');

%% Calculate cycles per degree

d=0.3;                                          % distance from screen in mm
pixPerMm=3.78;                                  % resolution of the projector in pixels per mm
mmPerDeg=d*tan(0.5)*2;                          % mm per degree of visual angle
cyclesPerDeg=0.016;                             % cycles per degree visual angle
pixPerCycle=pixPerMm*mmPerDeg/cyclesPerDeg;     % pixels per cycle for desired spatial frequency
pixPerROI=133;                                  % width of each ROI in pixels
cyclesPerROI=pixPerROI/pixPerCycle;             % num cycles displayed in ROI at any given time

%% Initialize the stimulus and input ROI properties

ROInum=16;
ROIsize=pixPerROI;
spatialFrequency=20;
temporalFrequency=5;

stim_duration=2;
blank_duration=0;
stim_status=1;
ct=0;
previous_tStamp=0;
tElapsed=0;
 
stimProperties=initializeOptomotorStim(ROIsize,ROInum,spatialFrequency,temporalFrequency);
%stimProperties.gaborAngles=0;
tic
i=1;
movingGabors=boolean(ones(stimProperties.nGabors,1));

while ~KbCheck
    
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
           stimProperties.gaborAngles=stimProperties.gaborAngles+120;
           stimProperties.gaborAngles(stimProperties.gaborAngles>360)=60;
           tElapsed=0;
           movingGabors(i)=0;
           i=i+1;
           

       elseif tElapsed>stim_duration && stim_status==1
           stim_status=0;
           tElapsed=0;
           
       end
    
       current_tStamp = toc;
       tElapsed=tElapsed+current_tStamp-previous_tStamp;
       previous_tStamp=current_tStamp;
       ct=ct+1;
       
       % Increment the phase of our Gabors
       stimProperties.phaseLine(movingGabors)=stimProperties.phaseLine(movingGabors)+stimProperties.degPerFrameGabors(movingGabors);
       
end
 
sca 

  