function moveStim=optoUpdateMovingStim(centerDistance,movingStatus)

% If the stimulus is not moving, and the fly approaches the center after
% making a decision, set movingStatus to 1

movingStatus(boolean((centerDistance<4).*~movingStatus))=1;