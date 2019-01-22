function out=dispBlank(optoProperties)

screenNumber=optoProperties.screenNumber;
window=optoProperties.window;
windowRect=optoProperties.windowRect;


    % Draw blank white screen
    Screen('FillRect',window,[1 1 1],windowRect);

    % Flip to the screen
    Screen('Flip', window);
    
