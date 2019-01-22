function out=initializeOptomotorStim(ROIsize,ROInum,spatial_frequency,temporal_frequency)

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
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);
Screen('Flip', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Maximum priority level
topPriorityLevel = MaxPriority(window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

%--------------------
% Gabor information
%--------------------

% Dimensions
gaborDimPix = ROIsize;

% Sigma of Gaussian
sigma = gaborDimPix / 1.1;

% Obvious Parameters
orientation = 90;
contrast = 40;
aspectRatio = 0.5;

% Spatial Frequency (Cycles Per Pixel)
% One Cycle = Grey-Black-Grey-White-Grey i.e. One Black and One White Lobe
numCycles = spatial_frequency;
freq = numCycles / gaborDimPix;

% Build a procedural gabor texture
gabortex = CreateProceduralGabor(window, gaborDimPix, gaborDimPix,...
    1, [0 0 0 0], 1, 0.5);

% Positions of the Gabors
dim = sqrt(ROInum);
[x, y] = meshgrid(-dim:dim, -dim:dim);

% Calculate the distance in "Gabor numbers" of each gabor from the center
% of the array
dist = sqrt(x.^2 + y.^2);

% Cut out an inner annulus
%innerDist = 0;
%x(dist <= innerDist) = nan;
%y(dist <= innerDist) = nan;

% Cut out an outer annulus
%outerDist = 1000;
%x(dist >= outerDist) = nan;
%y(dist >= outerDist) = nan;

% Select only the finite values
x = x(isfinite(x));
y = y(isfinite(y));

% Center the annulus coordinates in the centre of the screen
xPos = x .* gaborDimPix + xCenter;
yPos = y .* gaborDimPix*0.885 + yCenter;
xPos = xPos-80;
yPos=yPos+25;

% Count how many Gabors there are
nGabors = numel(xPos);

% Make the destination rectangles for all the Gabors in the array
baseRect = [0 0 gaborDimPix gaborDimPix*0.885];
allRects = nan(4, nGabors);
for i = 1:nGabors
    allRects(:, i) = CenterRectOnPointd(baseRect, xPos(i), yPos(i));
end

% Drift speed for the 2D global motion
degPerSec = 360 * temporal_frequency;
degPerFrame =  degPerSec * ifi;

% Randomise the Gabor orientations and determine the drift speeds of each gabor.
% This is given by multiplying the global motion speed by the cosine
% difference between the global motion direction and the global motion.
% Here the global motion direction is 0. So it is just the cosine of the
% angle we use. We re-orientate the array when drawing
gaborAngles = zeros(1,nGabors);
degPerFrameGabors = cosd(gaborAngles) .* degPerFrame;

% Randomise the phase of the Gabors and make a properties matrix. We could
% if we want have each Gabor with different properties in all dimensions.
% Not just orientation and drift rate as we are doing here.
% This is the power of using procedural textures
phaseLine = rand(1, nGabors) .* 360;
propertiesMat = repmat([NaN, freq, sigma, contrast, aspectRatio, 0, 0, 0],...
    nGabors, 1);
propertiesMat(:, 1) = phaseLine';

% Perform initial flip to gray background and sync us to the retrace:
vbl = Screen('Flip', window);

% Numer of frames to wait before re-drawing
waitframes = 1;

%define threshold
threshold = 0.0001;

out.screenNumber = screenNumber;
out.window = window;
out.windowRect = windowRect;
out.gabortex = gabortex;
out.nGabors = nGabors;
out.allRects = allRects;
out.gaborAngles = gaborAngles;
out.degPerFrameGabors=degPerFrameGabors;
out.propertiesMat = propertiesMat;
out.xCenter = xCenter;
out.yCenter = yCenter;
out.black = black;
out.white = white;
out.vbl = vbl;
out.ifi=ifi;
out.waitframes = waitframes;
out.phaseLine = phaseLine;
out.threshold = threshold;


