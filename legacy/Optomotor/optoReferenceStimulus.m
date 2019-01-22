function [reference,refCount]=optoReferenceStimulus(video_object,stimProps,h,mode)

vid=video_object;
stimProperties=stimProps;

% Initialize refcounter and refimage
i=0;
refCount = 1;                           % Num references
refdata=zeros(524,664,'uint8');

if mode==0;
    
while ~KbCheck

        %pause(0.0001);                                     % Pause adjusts frame rate
        tempdata = peekdata(vid,1);                        % Take one frame
        imagedata=tempdata(:,:,1);
        stimProperties.phaseLine=stimProperties.phaseLine+stimProperties.degPerFrameGabors;
        stimProperties=dispOptomotorStim(stimProperties);
        
        if mod(i,203)==0
            tempRef=imagedata;
            refdata=refdata*(1-(1/refCount))+tempRef*(1/refCount);
            set(h,'CData',refdata);
            drawnow
            refCount=refCount+1;
            
        end
        i=i+1;
end

else if mode==1
        
     while ~KbCheck

        %pause(0.0001);                                     % Pause adjusts frame rate
        tempdata = peekdata(vid,1);                        % Take one frame
        imagedata=tempdata(:,:,1);
        stimProperties=optoDispPinWheel(stimProperties);
        
        if mod(i,203)==0
            tempRef=imagedata;
            refdata=refdata*(1-(1/refCount))+tempRef*(1/refCount);
            set(h,'CData',refdata);
            drawnow
            refCount=refCount+1;
            
        end
        i=i+1;
     end 

    end
end

reference=refdata;
