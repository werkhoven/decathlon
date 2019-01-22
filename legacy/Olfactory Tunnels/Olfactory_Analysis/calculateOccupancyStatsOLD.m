function flyTracks = calculateOccupancyStats(flyTracks, refOdor)
% Calculate occupancy times for flyTracks

%%%%%%%%%%%%%%%%%% Doesn't work for multiple odor pulses!!! %%%%%%%%%%%%%%%%%
firstOdorFrame = find(floor(flyTracks.relTimes) == (flyTracks.stim{2}(1) + flyTracks.chargeTime),1);
lastOdorFrame = find(ceil(flyTracks.relTimes) == flyTracks.stim{2}(end),1,'last');

for k = 1:flyTracks.nFlies
    a = sum(flyTracks.headLocal(firstOdorFrame:lastOdorFrame,2,k) < flyTracks.corridorPos(1));
    b = sum(flyTracks.headLocal(firstOdorFrame:lastOdorFrame,2,k) >= flyTracks.corridorPos(end));
    flyTracks.occupancy(k) = a / (a+b); 
end