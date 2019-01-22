function stimProps=optoInitializeCheckerStim(nRow,nCol,rect_W,rect_H)

% Clear the workspace
sca;

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Seed the random number generator. Here we use the an older way to be
% compatible with older systems. Newer syntax would be rng('shuffle'). Look
% at the help function of rand "help rand" for more information
rand('seed', sum(100 * clock));

% Screen Number
screenNumber = max(Screen('Screens'));
%screenNumber = 1;

% Define black, white and grey
white = WhiteIndex(screenNumber);
grey = white / 2;
black = BlackIndex(screenNumber);

% Open the screen
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
Screen('Flip', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Maximum priority level
topPriorityLevel = MaxPriority(window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Create stimulus texture
stimW = ceil(rect_W * sqrt(2));
stimH = ceil(rect_H * sqrt(2));

% Define stimulus screen positions
[x,y]=meshgrid(1:nCol,1:nRow);
[s1, s2] = size(x);
x=x.*rect_W;
y=y.*rect_H;
x=x(:);
y=y(:);
x=x-rect_W/2;
y=y-rect_H/2;

% Make stimulus rectangles
baseRect=[0 0 rect_W rect_H];
dstRects=zeros(4,size(x,1));
for i=1:size(x,1)
    dstRects(:,i)=CenterRectOnPointd(baseRect, x(i), y(i));
end

xOffset=0;
yOffset=0;
dstRects([1 3],:)=dstRects([1 3],:)+xOffset;
dstRects([2 4],:)=dstRects([2 4],:)+yOffset;

% Set the colors to Red, Green and Blue
color = zeros(size(dstRects,2),3);

% Draw the rect to the screen
Screen('FillRect', window, color', dstRects);

% Perform initial flip to gray background and sync us to the retrace:
vbl = Screen('Flip', window);

% Numer of frames to wait before re-drawing
waitframes = 1;

% Now we create a window through which we will view our texture. This is
% the same size as our destination rectangles. But we shift it in X and Y
% by a value of dim2 - dim. This makes sure our window is centered on the
% middle of the enlarged texture we made for internal texture rotation.
srcRect = baseRect;
srcRect([1 3])= srcRect([1 3]) + (stimW - rect_W)/2;
srcRect([2 4])= srcRect([2 4]) + (stimH - rect_H)/2;


% Find centroid of ROI triangle
stimProps.stimOffset=(0.66*rect_H)-rect_H;
%srcRect([1 3])= srcRect([1 3])-0.5*(centerY-rect_H);
srcRect=repmat(srcRect',1,size(dstRects,2));

% Set priority level
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

% Translate requested speed of the grating (in cycles per second) into
% a shift value in "pixels per frame"
waitDuration = waitframes * ifi;

angle=zeros(size(dstRects,2),1);
color=zeros(length(angle),3)';

stimProps.angle=angle;
stimProps.baseRect=baseRect;
stimProps.black=black;
stimProps.blankTex=blankTex;
stimProps.color=color;
stimProps.dsRects=dstRects;
stimProps.grey=grey;
stimProps.ifi=ifi;
stimProps.Ltex=Ltex;
stimProps.Rtex=Rtex;
stimProps.screenNumber=screenNumber;
stimProps.srcRect=srcRect;
stimProps.white=white;
stimProps.window=window;
stimProps.windowRect=windowRect;
stimProps.xCenter=xCenter;
stimProps.yCenter=yCenter;
stimProps.waitframes=waitframes;
stimProps.ifi=ifi;
    
end
    
    
    
    
    
    
    
    
    
