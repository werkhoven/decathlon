function flyTracks = calculateOccupancyStats(flyTracks, refOdor)
% Calculate occupancy times for flyTracks
%
% Modified Aug 6, 2014 - KH


%%%%%%%%%%%%%%%%%% Doesn't work for multiple odor pulses!!! %%%%%%%%%%%%%%%%%
firstOdorFrame = find(floor(flyTracks.relTimes) == (flyTracks.stim{2}(1) + flyTracks.chargeTime),1);
lastOdorFrame = find(ceil(flyTracks.relTimes) == flyTracks.stim{2}(end),1,'last');

% 1 sec added after valve closing

% odorIdx = [];
% refOdorOnSideA = [];
% 
% for i = 1:size(flyTracks.stim,2)
% 
%     odorIdx = [odorIdx flyTracks.stim{2,i}(flyTracks.chargeTime:end) flyTracks.stim{2,i}(end) + 1];
% 
%     if find(strncmp(refOdor, flyTracks.stim{4,i}, 3)) == 1
%         refOdorOnSideA = [refOdorOnSideA ones(1, length(flyTracks.stim{2,i}(flyTracks.chargeTime:end)) + 1)];
%     else
%         refOdorOnSideA = [refOdorOnSideA zeros(1, length(flyTracks.stim{2,i}(flyTracks.chargeTime:end)) + 1)];
%     end
% 
% end

refOdorOnSideA = find(strncmp(refOdor, flyTracks.stim{4,1}, 3)) == 1;

for k = 1:flyTracks.nFlies
    a = sum(flyTracks.headLocal(firstOdorFrame:lastOdorFrame,2,k) > flyTracks.corridorPos(end));
    b = sum(flyTracks.headLocal(firstOdorFrame:lastOdorFrame,2,k) < flyTracks.corridorPos(1));
    
    if refOdorOnSideA
        flyTracks.occupancy(k) = a / (a+b);
    else
        flyTracks.occupancy(k) = b / (a+b);
    end

end

for k = 1:flyTracks.nFlies
    a = sum(flyTracks.headLocal(1:(firstOdorFrame-1),2,k) > flyTracks.corridorPos(end));
    b = sum(flyTracks.headLocal(1:(firstOdorFrame-1),2,k) < flyTracks.corridorPos(1));
  
    if refOdorOnSideA
        flyTracks.preOdorOccupancy(k) = a / (a+b);
    else
        flyTracks.preOdorOccupancy(k) = b / (a+b);
    end
    
end