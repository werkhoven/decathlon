function flyTracks = findGrooming(flyTracks)

binSz = diff(flyTracks.velBins(1:2));

for k = 1:flyTracks.nFlies
    
    % find times where the fly is stopped
    flyTracks.stops(:,k) = false(size(flyTracks.majorAxisLength,1),1);
    tmp = flyTracks.velocity(:,k) < 0.1;
    s = find(tmp);
    
    idx = [];
    
    for i = 1:length(s)
        idx = [idx find(flyTracks.etimes >= (flyTracks.velBins(s(i)) - binSz) & ...
            flyTracks.etimes < (flyTracks.velBins(s(i)) + binSz))];
    end
    
    flyTracks.stops(idx,k) = 1;
    
    
    % find stops that correspond to shortened maj axis
    
    % Look at the notch missing from the higher lengths
    % grab the top 80%, compute the probability in a running window, look
    % for drops in p at different window sizes, choose best window
        
    thresh = prctile(flyTracks.majorAxisLength(:,k), 20);
    compressed = flyTracks.majorAxisLength(:,k) > thresh;
    
    p = smooth(compressed, 20);
    
    
    % Cross-correlation b/w p and velocity to ID grooming?
    % Also look for high-frequency components of orientation
    
    
    
    
%     hold on
%     plot(flyTracks.etimes,zscore(flyTracks.majorAxisLength(:,k)),'g')
%     plot(flyTracks.etimes,p)
%     plot(flyTracks.velBins,zscore(flyTracks.velocity(:,k)),'m')
%     
%     hold on
%     plot(flyTracks.etimes(compressed), flyTracks.majorAxisLength(compressed,k),'.r')
%     plot(flyTracks.etimes(~compressed), flyTracks.majorAxisLength(~compressed,k),'.g')

    
end


% z = zscore(flyTracks.majorAxisLength(:,4));
% hold on
% plot(flyTracks.etimes(~stops),z(~stops),'.g')
% plot(flyTracks.etimes(stops),z(stops),'.r')