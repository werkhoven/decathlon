function [stimCoords,activeStim,stim_tStamps]=getStimTargets(arm_coords,choiceArm,changedArm,activeStim,occupyingLitArm,tElapsed)

% Update which flies are receiving a stimulus
activeStim(~occupyingLitArm)=0;
activeStim(occupyingLitArm)=1;

% Grab timestamp for flies with a newly changed stimulus
stim_tStamps(occupyingLitArm&changedArm)=tElapsed;

% Grab coordinates for subset of actively stimulated flies
tmpArm_coords=arm_coords(activeStim,:,:);
tmpCurrent_arm=choiceArm(activeStim);

% Convert matrix sub-indeces to linear indices
i1=reshape(repmat(1:sum(activeStim),2,1),numel(repmat(1:sum(activeStim),1,2)),1);  % Rows
i2=repmat((1:2)',size(i1,1)/2,1);                                                  % Columns
i3=reshape(repmat(tmpCurrent_arm,1,2)',numel(repmat(tmpCurrent_arm,1,2)),1);       % Pages
linInd=sub2ind(size(tmpArm_coords),i1,i2,i3);                                      % Linear indices

% Extract stimCoords with linear indices
stimCoords=tmpArm_coords(linInd);
stimCoords=reshape(stimCoords,2,numel(stimCoords)/2)';


