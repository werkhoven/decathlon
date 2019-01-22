    
% Clear the workspace
close all;
clear all;
sca;

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);
pause(0.5);
Screen('Preference', 'SkipSyncTests', 1);

% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if avaliable
screenNumber = max(screens);
%screenNumber = 1;


% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;
inc = white - grey;

% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%% Define Stimulus Parameters

% Dimension of our texure (it will be this value +1 pixel
xdim = 200;
ydim = 200;

% Make a second dimension value which is increased by a factor of the
% squareroot of 2. We need to do this because in this demo we will be using
% internal texture rotation. We round this to the nearest pixel.
cyclesPerSecond=0.5;
pixPerCycle=100;
xdim2 = ceil(xdim * sqrt(2));
ydim2 = ceil(ydim * sqrt(2));


% Contrast for our contrast modulation mask: 0 = mask has no effect, 1 = mask
% will at its strongest part be completely opaque i.e. 0 and 100% contrast
% respectively
contrast = 1;

% Define the stimulus texture
[x, y] = meshgrid(-xdim2:1:xdim2, -ydim2:1:ydim2);
[th, r] = cart2pol(x, y);
grey=white/2;
inc=white-grey;
wheel = grey + inc .* cos(7.7*pi * th);
wheel(wheel>0.5)=1;
wheel(wheel<=0.5)=0;
%wheel=wheel./max(max(wheel));
wheelTexture = Screen('MakeTexture', window, wheel);

[s1, s2] = size(x);
mask = ones(s1, s2, 1) .* white;
mask= wheel .* contrast;

% Black out the center of the pinwheel
r=size(mask,1)*0.03;
center=round([size(mask,2)/2 size(mask,1)/2]);
x=1:size(mask,2);
y=1:size(mask,1);
a=repmat(x,length(y),1);
a=a(:);
b=repmat(y,1,length(x));
d=sqrt((center(1)-a).^2+(center(2)-b').^2);
d_mask=d<=r;
mask(d_mask)=0;

% Make our sprial  into a screen texture for drawing
maskTexture = Screen('MakeTexture', window, mask);

%%

% We are going to draw four textures to show how a black and white texture
% can be color modulated upon drawing
xPos=round(screenXpixels/2);
yPos=round(screenYpixels/2);

xOffset=0;
yOffset=0;
xPos=xPos+xOffset;
yPos=yPos+yOffset;

% Define the destination rectangles for our spiral textures. For this demo
% these will be the same size as out actualy texture, but this doesn't have
% to be the case. See: ScaleSpiralTextureDemo and CheckerboardTextureDemo.
ndimx = xdim * 2 + 1;
ndimy = ydim * 2 + 1;
baseRect = [0 0 50 50];
dstRects = nan(4, length(xPos)*length(yPos));

numROIsX=length(xPos);
numROIsY=length(yPos);
k=1;
for i = 1:numROIsX
    for j=1:numROIsY
    dstRects(:, k) = CenterRectOnPointd(baseRect, xPos(i), yPos(j));
    k=k+1;
    end
end

% Now we create a window through which we will view our texture. This is
% the same size as our destination rectangles. But we shift it in X and Y
% by a value of dim2 - dim. This makes sure our window is centered on the
% middle of the enlarged texture we made for internal texture rotation.
baseRect=[0 0 xdim xdim];
srcRect=baseRect;
src_w = sqrt((((baseRect(3)-baseRect(1))/2)/2).^2);
src_h = sqrt((((baseRect(4)-baseRect(2))/2)/2).^2);
srcRect(1)= (size(mask,2))/2 - src_w/2;
srcRect(3)= (size(mask,2))/2 + src_w/2;
srcRect(2)= (size(mask,1))/2 - src_h/2;
srcRect(4)= (size(mask,1))/2 + src_h/2;

% Color Modulation
colorMod = [1 1 1; 1 0 0; 0 1 0; 0 0 1]';

% Switch filter mode to simple nearest neighbour
filterMode = 0;

% Set the inital rotation angle randomly and in increment per frame to 3
% degrees
angle = 0;
angleInc = 2;
degPerFrame = 1;

% Sync us and get a time stamp
vbl = Screen('Flip', window);
waitframes = 1;

% Maximum priority level
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

% Translate requested speed of the grating (in cycles per second) into
% a shift value in "pixels per frame"
waitDuration = waitframes * ifi;
shiftPerFrame = cyclesPerSecond * pixPerCycle * waitDuration;

% Set the frame counter to zero, we need this to 'drift' our grating
frameCounter = 0;
mode=0;
angle=zeros(size(dstRects,2),1);
active=boolean(ones(size(angle)));
ct=0;
x_cyc=srcRect(3)-srcRect(1);
baseSrc=srcRect;
%imr=(size(mask,1)/2)/sqrt(2);
warning off
angle=0;
while ~KbCheck

    %{
    ct=ct+inc;
    if ct>20
        inc=-inc;
    elseif ct<-20
            inc=-inc;
    end
    imr = mod(1:40,21) - 10;
    angle=angle+1;
    rotim=imrotate(mask,angle);
    center=size(rotim)./2;
    range=srcRect;
    centerim=rotim(center(1)+ct:center(1)+ct+20,center(2)+ct:center(2)+ct+20);
    wheelTex = Screen('MakeTexture', window, centerim);
    newSrcRect=[0 0 size(centerim,2) size(centerim,1)];
    %}
    
    % Batch Draw all of the texures to screen
    Screen('DrawTextures', window, maskTexture, srcRect, dstRects, angle,...
        [], [], [],[], kPsychUseTextureMatrixForRotation);

    % Flip to the screen
    Screen('Flip', window);

    % Increment the angle
    angle(active) = angle(active) + angleInc;
    %}

end