function flyTracks = smoothTrax(flyTracks)

winSz = 4;             % 125ms - assuming an average frame rate of 32fps

% for i = 1:size(flyTracks.centroid,3)
%     flyTracks.centroid(:,1,i) = smooth(flyTracks.centroid(:,1,i),winSz);
%     flyTracks.centroid(:,2,i) = smooth(flyTracks.centroid(:,2,i),winSz);
% end

for i = 1:flyTracks.nFlies
    
    xnan = find(isnan(squeeze(flyTracks.centroid(:,1,i))));
    ynan = find(isnan(squeeze(flyTracks.centroid(:,2,i))));
    onan = find(isnan(squeeze(flyTracks.orientation(:,i))));
    
    flyTracks.centroid(:,1,i) = smooth(flyTracks.centroid(:,1,i),winSz);
    flyTracks.centroid(:,2,i) = smooth(flyTracks.centroid(:,2,i),winSz);
    flyTracks.orientation(:,i) = smooth(flyTracks.orientation(:,i),winSz);
    
    % Replace meaningless interpolated NaN values with NaNs
    flyTracks.centroid(xnan,1,i) = NaN;
    flyTracks.centroid(ynan,2,i) = NaN;
    flyTracks.orientation(onan,i) = NaN;
    
end