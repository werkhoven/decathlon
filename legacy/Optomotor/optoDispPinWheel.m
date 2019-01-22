function stimProps=optoDispPinWheel(stimProps)

active=stimProps.active;
angle=stimProps.angle;
angleInc=stimProps.angleInc;
baseRect=stimProps.baseRect;
black=stimProps.black;
contrast=stimProps.contrast;
dstRects=stimProps.dsRects;
frameCounter=stimProps.frameCounter;
grey=stimProps.grey;
ifi=stimProps.ifi;
inc=stimProps.inc;
mask=stimProps.mask;
maskTexture=stimProps.maskTexture;
mode=stimProps.mode;
ndimx=stimProps.ndimx;
ndimy=stimProps.ndimy;
screenNumber=stimProps.screenNumber;
screenXpixels=stimProps.screenXpixels;
screenYpixels=stimProps.screenYpixels;
srcRect=stimProps.srcRect;
wheel=stimProps.wheel;
wheelTexture=stimProps.wheelTexture;
white=stimProps.white;
window=stimProps.window;
windowRect=stimProps.windowRect;


%% Batch Draw all of the texures to screen
     
    % Now increment the frame counter for the next loop
    frameCounter = frameCounter + 1;

    % Define our source rectangle for grating sampling
    %srcRect = [xoffset yoffset xoffset+ndimx yoffset+ndimy];
    %srcRect

    % Batch Draw all of the texures to screen
    Screen('DrawTextures', window, maskTexture, srcRect, dstRects, angle,...
        [], [], [],[], kPsychUseTextureMatrixForRotation);

    % Flip to the screen
    Screen('Flip', window);

    % Increment the angle
    angle(active) = angle(active) + angleInc;
    
%% Reassign to output struct

stimProps.active=active;
stimProps.angle=angle;
stimProps.angleInc=angleInc;
stimProps.baseRect=baseRect;
stimProps.black=black;
stimProps.contrast=contrast;
stimProps.dsRects=dstRects;
stimProps.frameCounter=frameCounter;
stimProps.grey=grey;
stimProps.ifi=ifi;
stimProps.inc=inc;
stimProps.mask=mask;
stimProps.maskTexture=maskTexture;
stimProps.mode=mode;
stimProps.ndimx=ndimx;
stimProps.ndimy=ndimy;
stimProps.screenNumber=screenNumber;
stimProps.screenXpixels=screenXpixels;
stimProps.screenYpixels=screenYpixels;
stimProps.srcRect=srcRect;
stimProps.wheel=wheel;
stimProps.wheelTexture=wheelTexture;
stimProps.white=white;
stimProps.window=window;
stimProps.windowRect=windowRect;
