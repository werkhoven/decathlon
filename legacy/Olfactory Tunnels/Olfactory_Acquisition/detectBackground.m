function out = detectBackground
%DETECTBACKGROUND Detect individual tunnels and flies.
%   OUT = DETECTBACKGROUND detects tunnels and flies, crops the camera ROI
%   to increase acquisition speed, creates a background image for
%   realtime subtraction, and calculates pixel resolution.  Data are
%   contained in structure OUT.
%
%   Revised November 14, 2013
%   Kyle Honegger, Harvard & CSHL


global vid;

if isempty(vid)
    initializeCamera1(0)
end

if isrunning(vid)
    stop(vid)
end

vid.ROIPosition = [0 0 640 480];
triggerconfig(vid,'manual');
start(vid);
pause(2)

try
    load('C:\Users\khonegger\Documents\MATLAB\TunnelData\blankBg.mat')
catch
    warning('There was an error loading the background image file blankBg.mat')
    blankBg = uint8(zeros(480,640));
end

ct = 0;

timeout = 300;  % 5 min timeout period
props = {'Area', 'BoundingBox', 'MajorAxisLength', 'MinorAxisLength'};

tic
while toc < timeout
    ct = ct + 1;  % on ct = 1, I reset vid ROI, so DO NOT index by ct
    fr = blankBg - uint8(mean(peekdata(vid,3),3));
    
    % 1. Identify contiguous areas of bright space (tunnels)
    clf
    %clear p l idx tun
    
    if ct == 1
        % This doesn't work too well - distributions are not well-fit by
        % gaussians
%         I = double(fr);
%         I(I<5) = NaN;
%         display('Fitting Distribution')
%         hist(log(I(:)),30)
%         nGm = 3;
%         gm = gmdistribution.fit(I(:),nGm,'Replicates',1);
%         display('Finished fitting!')
%         id = find(gm.mu == min(gm.mu));
%         idx = cluster(gm,I(:));
%         thresh = max(I(idx==id));
        
        % thresh = 35; %25
        
        % p = regionprops(logical(fr < thresh), props);
        
        % Best results from setting an upper and lower bound on tunnel
        % intensity
        lb = 15; %30; % tunnel area lower bound
        ub = 27; %62; % tunnel area upper bound
        l = imdilate(logical(fr < ub & fr > lb), [1; 1; 1; 1; 1; 1; 1]);
        p = regionprops(l, props);
        
        for i = 1:length(p)
            tun(i) = p(i).Area >= 2500 & p(i).MajorAxisLength < 230; % a tunnel must be >= 200px long
            %tun(i) = p(i).MajorAxisLength >= 230 & p(i).BoundingBox(2) >= 110; % a tunnel must be >= 200px long
        end
        
    else
        % l = imdilate(logical(fr < thresh), [1 1 1; 1 1 1]);
        l = imdilate(logical(fr < ub & fr > lb), [1; 1; 1; 1; 1; 1; 1; 1]);
        p = regionprops(l, props);
        
        for i = 1:length(p)
            tun(i) = p(i).Area >= 2500;
            %tun(i) = p(i).MajorAxisLength >= 220;% & p(i).BoundingBox(2) >= 2; % a tunnel must be >= 200px long
        end
        
    end
    %{
    if ct == 1 && sum(tun) < 15
        ct = 0;
        continue % force initial detection of 15 tunnels
    end
%     if sum(tun) < 15
%         display('stop')
%     end
    %}
    
    imshow(fr)
    hold on
    
    idx = find(tun > 0);
    
    for i = 1:length(idx)
        b = p(idx(i)).BoundingBox;
        rectangle('Position', b, 'EdgeColor', 'r')
        tunnel(i).ROI = imcrop(fr, b);
        tunnel(i).globalLocation = b;
    end
    
    roiIntensity = [];
    
    for i = 1:length(tunnel)
        roiIntensity = [roiIntensity; tunnel(i).ROI(:)];
    end
    
    % Assume values in the upper 0.5% of tunnel intensities are flies
    flyThresh = prctile(roiIntensity,99.3);
    
    % 2. Identify and count flies within tunnels
        for i = 1:length(tunnel)
        
        p = regionprops(logical(tunnel(i).ROI >= flyThresh), ...
            'Area', 'Centroid', 'BoundingBox');
        
        for ii = 1:length(p)
            
            if p(ii).Area > 3  % Flies must have area greater than 3
                tunnel(i).fly.Centroid = p(ii).Centroid;
                tunnel(i).fly.Box = p(ii).BoundingBox;
            end
            
        end
        
    end
    
    hasFlies = ~cellfun('isempty',{tunnel.fly});
    
    % get 'global bounding box', set camera ROI
    if ct == 1
        bigBounds = [find(hasFlies,1,'first') find(hasFlies,1,'last')];
        
        bigROI = [(tunnel(bigBounds(1)).globalLocation(1) - 15), ...
            (tunnel(bigBounds(1)).globalLocation(2) - 15), ...
            ((tunnel(bigBounds(2)).globalLocation(1)  +    ...
            tunnel(bigBounds(2)).globalLocation(3)) -    ...
            tunnel(bigBounds(1)).globalLocation(1) + 30), ...
            (tunnel(bigBounds(1)).globalLocation(4) + 30)];
        
        stop(vid)
        vid.ROIPosition = round(bigROI);
        start(vid)
        pause(1)
        
        bg = uint8(peekdata(vid,1));
        
        %bg = imcrop(bg, round(bigROI)-1); % this correction works, but isn't correct
        blankBg = imcrop(blankBg, round(bigROI)-1);
        
        clear tunnel
        
        continue
    end
    
    
    % Display detection image
    if exist('toUpdate', 'var')
        % Plot segmented flies in green, unsegmented flies in red
        for i = toUpdate
            plot(tunnel(i).fly.Centroid(1) + tunnel(i).globalLocation(1), ...
                tunnel(i).fly.Centroid(2) + tunnel(i).globalLocation(2), '*r')
        end
        
        for i = setdiff(find(hasFlies),toUpdate)
            plot(tunnel(i).fly.Centroid(1) + tunnel(i).globalLocation(1), ...
                tunnel(i).fly.Centroid(2) + tunnel(i).globalLocation(2), '*g')
        end
    else
        for i = find(hasFlies)
            plot(tunnel(i).fly.Centroid(1) + tunnel(i).globalLocation(1), ...
                tunnel(i).fly.Centroid(2) + tunnel(i).globalLocation(2), '*r')
        end
    end
    
    title(['Segmenting background - ' sprintf('%d', length(idx)) ' tunnels and ' sprintf('%d', ...
        sum(hasFlies)) ' flies detected'])
    
    pause(0.001)
    
    % 3. Run background acquisition based on fly positions
    
    % 3.1 Keep the smallest bounding box for each tunnel (largest x and y,
    % smallest length and width)
    for i = 1:length(tunnel)
        bb(ct-1,:,i) = tunnel(i).globalLocation; % bounding box of tunnels
    end
    
    % 3.2 Run until centroid reaches some distance from start pos
    if ct == 2
        
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
    squeeze(max(bb(:,[3 4],:),[],1))];  %tunnel boundaries
out.pxRes = 50/mean(out.tunnels(4,:));  %pixel resolution (mm/pixel)


% Global centroids of final fly positions
ct = 0;
for i = find(hasFlies)
    ct = ct + 1;
    
    b = tunnel(i).globalLocation;
    out.lastCentroid{ct} = [tunnel(i).fly.Centroid(1) + b(1), ...
        tunnel(i).fly.Centroid(2) + b(2)]';
end


% Display final bg image and tunnels
clf
imshow(bg)
hold on

for i=1:length(tunnel)
    rectangle('Position', out.tunnels(:,i), 'EdgeColor', 'r')
end
