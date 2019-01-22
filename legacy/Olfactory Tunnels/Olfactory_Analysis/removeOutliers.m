function flyTracks = removeOutliers(flyTracks)

for i = 1:flyTracks.nFlies
    mu = mean(flyTracks.centroid(:,1,i),1);
    sd = std(flyTracks.centroid(:,1,i),1);
    
    outliers = find(flyTracks.centroid(:,1,i) < (mu-4*sd) | ...
        flyTracks.centroid(:,1,i) > (mu+4*sd));
    
    idx = 1:length(flyTracks.centroid(:,1,i));
    xpos = flyTracks.centroid(:,1,i);
    ypos = flyTracks.centroid(:,2,i);
    idx(outliers) = [];
    xpos(outliers) = [];
    ypos(outliers) = [];
    interpx = interp1(idx,xpos,outliers);
    interpy = interp1(idx,ypos,outliers);
    flyTracks.centroid(outliers,1,i) = interpx;
    flyTracks.centroid(outliers,2,i) = interpy;
end