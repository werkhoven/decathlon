% Clear the workspace
close all;
clear all;

% Displays information about the available screens in the command window
sca;

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Pass the 'Screens' parameter to the Screen function so that
% we can save the screen numbers in an array called "screens"
screens = Screen('Screens');

% Draw to the external screen if avaliable. The max function will return
% the highest value in the screens array we just defined. By default, an
% external monitor will be the highest value. If it's not available, it
% will return your primary monitor. We then define a variable screenNumber
% to save the maximum screen number available.
screenNumber = max(screens);

% We define the colors white and black be querying the screen we just defined above.
% We need to do this because color display properties can vary from monitor
% to monitor. So we're just defining what values correspond to true white
% or black for this monitor.
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

%{
Open an on screen window. Opens a stimulus display window on the screen
we defined above and sets that color to black. 
The syntax [window, windowRect] just allows us to define two variables at
the same time. By default, the PsychImaging function can have a variable
number of outputs. If we tell it equal to two variables (eg. window and
windowRect), it will save the window number to "window" and will save the
coordinates for the top-left and bottom-right corners of the screen to
"windowRect"
%}

[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Make a base Rect of the length of the screen by 20 pixels
baseRect = [0 0 screenXpixels 20];

% Create the color arrays for red stripe appearing or magenta stripe
red_first_colors = [1 1 ; 0 0 ; 0 1 ];
red_first_colors = repmat(red_first_colors,1,21);
magenta_first_colors = [1 1 ; 0 0 ; 1 0];
magenta_first_colors = repmat(magenta_first_colors,1,21);
current_colors = [];

time = 0;

% Sync us and get a time stamp
vbl = Screen('Flip', window);
waitframes = 1;

% Maximum priority level
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

% Establish the counter to track the loop
counter = 0;

% Loop the animation until a key is pressed
while ~KbCheck

    %Update the yCoordinate
    counter = counter + 1;
    
    % Populate y-centroid values for all rectangles
    yPos = rem(counter,20) - 10;
    yPos = yPos:20:screenYpixels;
    
    
    % Make our rectangle coordinates
    allRects = nan(4, length(yPos));
    for i = 1:length(yPos)
        allRects(:, i) = CenterRectOnPointd(baseRect, xCenter, yPos(i));
    end
    
    for i = 1:length(yPos)
        
        if allRects(2,i) < 0
            allRects(2,i) = 0;
        else if allRects(4,i) > 768
            allRects(4,i) = 768;
            end
        end
    end
    
    
    % Alternate starting color every 20 pixels
        color_checker = rem(counter,40);
    if (0 <= color_checker) && (color_checker <= 19)
        current_colors = red_first_colors(:,1:length(allRects));
        color = 'red';
    else if (20 <= color_checker) && (color_checker <= 40)
        current_colors = magenta_first_colors(:,1:length(allRects));
        color = 'magenta';

        end 
    end

    % Draw the rect to the screen
    Screen('FillRect', window, current_colors, allRects);

    % Flip to the screen
    vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

    % Increment the time
    time = time + ifi;

end

% Clear the screen
sca;
close all;