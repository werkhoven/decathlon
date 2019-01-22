function out = detectBackground
%
% Detect individual tunnels and flies, create a background image for
% realtime subtraction, and calculate pixel resolution
%
%
% To do:
% 1. Crop camera ROI

global vid;

if isempty(vid)
    initializeCamera(0)
end

if isrunning(vid)
    stop(vid)
end

triggerconfig(vid,'manual');
start(vid)
pause(2)

bg = uint8(peekdata(vid,1));

try
    load('C:\Documents and Settings\fly\My Documents\MATLAB\TunnelData\blankBg.mat')
catch
    error('There was an error loading the background image file blankBg.mat')
end

ct = 0;

timeout = 300;  % 5 min timeout period

tic
while toc < timeout
    ct = ct+1;
    fr = blankBg - uint8(peekdata(vid,1));
    
    % 1. Identify contiguous areas of bright space (tunnels)
    clf
    clear p l idx tun
    
    props = {'Area', 'BoundingBox'};
    p = regionprops(logical(fr < 30), props);
    
    for i = 1:length(p)
        tun(i) = p(i).Area > 3400 && p(i).Area < 4200;
    end
    
    imshow(fr)
    hold on
    idx = find(tun > 0);
    
    for i = 1:length(idx)
        b = p(idx(i)).BoundingBox;
        rectangle('Position', b, 'EdgeColor', 'r')
        tunnel(i).ROI = imcrop(fr, b);
        tunnel(i).globalLocation = b;
    end
    
    % 2. Identify and count flies within tunnels
    for i = 1:length(tunnel)
        
        % Assume values greater than 150 are flies
        p = regionprops(logical(tunnel(i).ROI > 150), ...
            'Area', 'Centroid', 'BoundingBox', 'PixelList');
        
        for ii = 1:length(p)
            
            if p(ii).Area > 3  % Flies must have area greater than 3
                tunnel(i).fly.Centroid = p(ii).Centroid;
                tunnel(i).fly.Box = p(ii).BoundingBox;
                tunnel(i).fly.PixelList = p(ii).PixelList;
            end
            
        end
        
    end
    
    hasFlies = ~cellfun('isempty',{tunnel.fly});
    
    
    % Display detection image
    for i = find(hasFlies)
        plot(tunnel(i).fly.Centroid(1) + tunnel(i).globalLocation(1), ...
            tunnel(i).fly.Centroid(2) + tunnel(i).globalLocation(2), '*g')
    end
    
    title(['Segmenting background - ' sprintf('%d', length(idx)) ' tunnels and ' sprintf('%d', ...
        sum(hasFlies)) ' flies detected'])
    
    pause(0.001)
    
    % 3. Run background acquisition based on fly positions
    
    % 3.1 Keep the smallest bounding box for each tunnel (largest x and y,
    % smallest length and width)
    for i = 1:length(tunnel)
        bb(ct,:,i) = tunnel(i).globalLocation; % bounding box of tunnels
    end
    
    % 3.2 Run until centroid reaches some distance from start pos
    if ct == 1
        
        for i = find(hasFlies)
            pcen(i).initial = tunnel(i).fly.Centroid;
            pbound(i).initial = tunnel(i).fly.Box + ...
                [tunnel(i).globalLocation(1)-4 ...
                tunnel(i).globalLocation(2)-4 8 8]; %expand the fly box by 4px around
            rectangle('Position', pbound(i).initial, 'EdgeColor', 'g')
        end
        
        toUpdate = find(hasFlies);
        
    else
        
        for i = toUpdate
            current = tunnel(i).fly.Centroid;
            
            if pdist([current; pcen(i).initial]) > 20 % current fly centroid > 20 pixels away from original
                % 3.3 When pixel idx no longer overlaps with original idx,
                % collect that info piecewise and merge to obtain full bg image
                
                [clip idx] = imcrop(blankBg - fr, pbound(i).initial); % revert clip to original reference intensity
                
                bg(idx(2):(idx(2)+idx(4)), idx(1):(idx(1)+idx(3))) = clip;
                
                toUpdate(toUpdate == i) = []; % delete fly index from remaining
            end
            
        end
        
    end
    
    if isempty(toUpdate)
        break % terminate loop once bg image is fully updated
    end
    
end

if toc > timeout
    error('Timeout period reached: at least one fly has not moved')
end

% 4. Format outputs
out.bg = bg;  %background image
out.tunnelActive = hasFlies;  %whether each tunnel contains a fly
out.tunnels = [squeeze(max(bb(:,[1 2],:),[],1)); ...
    squeeze(min(bb(:,[3 4],:),[],1))];  %tunnel boundaries
out.pxRes = 50/mean(out.tunnels(4,:));  %pixel resolution (mm/pixel)


% Global centroids of final fly positions
ct = 0;
for i = find(hasFlies)
    ct = ct + 1;
    
    % convert fly idx to global coordinates
    b = tunnel(i).globalLocation;
    globSub = round([tunnel(i).fly.PixelList(:,2) + b(2), ...
        tunnel(i).fly.PixelList(:,1) + b(1)]);
    
    % add to tunnel offset, convert back to ind
    out.lastPxIdx{ct} = sub2ind(size(bg), globSub(:,1), globSub(:,2));

end


% 5. Set image crop based on extended boundaries of active tunnels
% bigROI = [];
% vid.ROIPosition = bigROI;


% Display final bg image and tunnels
clf
imshow(bg)
hold on

for i=1:length(tunnel)
    rectangle('Position', out.tunnels(:,i), 'EdgeColor', 'r')
end
