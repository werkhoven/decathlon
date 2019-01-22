function headpos = findHead(flyTracks)
% This works like it should, but it's a terrible hack...


for k = 1:flyTracks.nFlies
    
    %%%%%%% vectorize this whole block %%%%%
    for i = 1:size(flyTracks.centroid,1)
        
        r = flyTracks.majorAxisLength(i,k)/2;
        
        x = r* cos(flyTracks.orientation(i,k)*(pi/180));
        y = r* sin(flyTracks.orientation(i,k)*(pi/180));
        
        % x-values of endpts
        lx(i,:) = [flyTracks.centroid(i,1,k)+x flyTracks.centroid(i,1,k)-x];
        
        % y-values of endpts
        ly(i,:) = [flyTracks.centroid(i,2,k)-y flyTracks.centroid(i,2,k)+y];
        
    end 
    
    
    % keep track of the same endpoint over the experiment length (index
    % position flips back and forth, depending on orientation)
    
    idx = 1;
    
    for i = 2:size(flyTracks.centroid,1)
        
        
        da = sqrt((lx(i-1,1) - lx(i,1))^2 + (ly(i-1,1) - ly(i,1))^2);
        db = sqrt((lx(i-1,1) - lx(i,2))^2 + (ly(i-1,1) - ly(i,2))^2);
        
        idx(i) = (db < da) + 1; % which endpt is closer to the last set of endpts?
        
        if  idx(i) > 1          % for switches invert the endpt coordinates
            lx(i,:) = [lx(i,2) lx(i,1)];
            ly(i,:) = [ly(i,2) ly(i,1)];
        end
        
    end
    
    idx = [];
    
    % euclidean distance b/w current endpts and next centroid position
    %     decrease in dist == head
    
    c = flyTracks.centroid(:,:,k);
    
    for i = 2:size(flyTracks.centroid,1)
        da = sqrt((lx(i-1,1) - c(i,1))^2 + (ly(i-1,1) - c(i,2))^2);
        db = sqrt((lx(i-1,2) - c(i,1))^2 + (ly(i-1,2) - c(i,2))^2);
        idx(i-1) = (db < da) + 1; % which endpt is in the direction of travel? 
    end
    
    
    % find the endpt in the direction of motion a majority (>51%) of time
    if mean(idx) < 1.49
        headpos(:,:,k) = [lx(:,1) ly(:,1)];
    elseif mean(idx) > 1.51
        headpos(:,:,k) = [lx(:,2) ly(:,2)];
    else
        headpos(:,:,k) = NaN(size(lx,1),2);
    end
    
    idx = [];
    
end