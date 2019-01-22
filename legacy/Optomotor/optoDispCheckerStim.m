function [pulseON,stim_tStamps]=optoDispCheckerStim(stimProps,stimCoords,pulseON,activeStim,stim_tStamps,stimFreq,tElapsed)

% Check to see if stimulus is in ON or OFF part of part of pulse
dt=tElapsed-stim_tStamps;                               % Time elapsed since stim last changed
pulseChange=dt>(1/(stimFreq*2));                        % Will be true where time elapsed > 0.5*period
pulseChange(~activeStim)=0;                             % Prevent pulse change for nonactive stimuli
stim_tStamps(pulseChange)=tElapsed;                     % Record new time stamp for stimuli that will change

% Pulse ON if it was already on and didn't change, OR if it wasn't on and
% did change
pulseON=(pulseON&~pulseChange)|(~pulseON&pulseChange);

% Generate rectangle colors
colors=zeros(sum(activeStim),3);
red=pulseON(activeStim);
colors(red,1)=1;

baseRect=[0 0 20 20];
dstRects=NaN(4,size(stimCoords,1));
for i=1:size(stimCoords,1)
    dstRects(:,i)=CenterRectOnPointd(baseRect, stimCoords(i,1), stimCoords(i,2));
end

% Draw the rect to the screen
Screen('FillRect', stimProps.window, colors', dstRects);

% Flip to the screen
Screen('Flip', stimProps.window);
    
% Flip our drawing to the screen
stimProps.vbl = Screen('Flip', stimProps.window, stimProps.vbl + (stimProps.waitframes - 0.5) * stimProps.ifi);
    
end