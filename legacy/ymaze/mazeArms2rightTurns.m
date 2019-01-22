function rights=mazeArms2rightTurns(flyTracks);

turnArm=flyTracks.rightTurns;
rights=NaN(size(turnArm));

for i=1:size(turnArm,2)

tmpTurns=~isnan(turnArm(:,i));      % Grab the indices of turn events
tmpDat=turnArm(tmpTurns,i);           % Maze arms that the fly turned into at each valid index
tmpDiff=diff(tmpDat);               % Take difference to determine turn direction

% Score as right or left turn based on orientation of the maze
if ~flyTracks.mazeOri(i)
    tmpRight=tmpDiff==-1|tmpDiff==2;
else
    tmpRight=tmpDiff==1|tmpDiff==-2;
end

% Discard the first turn index since we don't know which arm it turned from
turnOne=find(tmpTurns,1);
tmpTurns(turnOne)=0;

% Record turn scoring for the fly
rights(tmpTurns,i)=tmpRight;
end