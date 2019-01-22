clear
close all

%% Setup the camera and video object

vid = initializeCamera('pointgrey',1,'F7_BayerRG8_664x524_Mode1');

%% Initialize the stimulus and input ROI properties

ROInum=16;
ROIsize=133;
spatialFrequency=10;
temporalFrequency=5;

stimProperties=initializeOptomotorStim(ROIsize,ROInum,spatialFrequency,temporalFrequency);

%% Reference stimulus

% Reference the background with the moving stimulus (press keyboard to stop
% collecting references)
[stimReference,refCount]=optoReferenceStimulus(vid,stimProperties);

stimThresh = 20;
[ROI_bounds,ROI_coords,ROI_widths,ROI_heights,binaryimage] = detect_ROIs(stimReference);

%% Display subtracted image
p1=imshow(stimReference);

while ~KbCheck
    tic
       % Extract centroid
       [props,imagedata]=decGetCentroid2(vid,stimReference,stimThresh);
        
       % Calculate number of flies with non-zero centroids
       numCentroids=size(props,1);
       
       % Display stimulus
       stimProperties=dispOptomotorStim(stimProperties);
       
       cenDat=reshape([props(:).Centroid],2,length([props(:).Centroid])/2)';
       set(p1,'CData',imagedata);
       %drawnow
       
      
           hold on
           plot(cenDat(:,1),cenDat(:,2),'o','Color','r')
           drawnow
           hold off
           %{
           for i = 1:size(ROI_coords,1)
            rectangle('Position',ROI_bounds(i,:),'EdgeColor','r')
           end
           hold off          
           drawnow
           %}
       disp(1/toc)
end

sca
stop(vid);