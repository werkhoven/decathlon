function out=dispOptomotorStim(optoProperties)

screenNumber=optoProperties.screenNumber;
window=optoProperties.window;
windowRect=optoProperties.windowRect;
gabortex=optoProperties.gabortex;
nGabors=optoProperties.nGabors;
allRects=optoProperties.allRects;
gaborAngles=optoProperties.gaborAngles;
degPerFrameGabors=optoProperties.degPerFrameGabors;
propertiesMat=optoProperties.propertiesMat;
xCenter=optoProperties.xCenter;
yCenter=optoProperties.yCenter;
black=optoProperties.black;
white=optoProperties.white;
vbl=optoProperties.vbl;
ifi=optoProperties.ifi;
waitframes=optoProperties.waitframes;
phaseLine=optoProperties.phaseLine;
threshold=optoProperties.threshold;
    
    
    % Set the right blend function for drawing the gabors
    Screen('BlendFunction', window, 'GL_ONE', 'GL_ZERO');

    % Batch draw all of the Gabors to screen
    Screen('DrawTextures', window, gabortex, [], allRects, gaborAngles,...
        [], [], [1 1 1 0.0], [], kPsychDontDoRotation, propertiesMat');

    % Change the blend function to draw an antialiased fixation point
    % in the centre of the array
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

    % Draw the fixation point
    %Screen('DrawDots', window, [xCenter; yCenter], 10, black, [], 2);


    % Flip our drawing to the screen
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    % Increment the phase of our Gabors
    %phaseLine=phaseLine+degPerFrameGabors;
    propertiesMat(:, 1) = phaseLine';
    
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

end