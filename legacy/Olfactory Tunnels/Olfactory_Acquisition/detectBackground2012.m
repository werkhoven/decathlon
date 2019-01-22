function P = detectBackgroundOLD(i)
% The idea is to:
% 1. Automatically detect the individual tunnels (adaptive thresh, size exclusion, bounding box of labeled obj - k, )
% 2. Profile the pixel intensity distributions to identify the tunnels
% which contain a fly (compare kurtosis values or subsample to get confidence estimate of dist skew)
% 3. Limit ROI, calculate the offset angle across the tunnels (and correct
% for this tilt if possible)
% 4. Continue to take a running average in each of the tunnels until k < n

% INCLUDE calculation of pixel = mm scaling
% FIX error abort in main code

dim = size(i);


% First detect uneven illumination, which will cause problems
% detect outliers in average tunnel intensity

if 0
    display('Warning: Uneven illumination detected.  This could cause problems.')
    i = adapthisteq(uint8(i),'clipLimit',0.015,'Distribution','rayleigh');
end

I = double(i);
I(I<5) = NaN;

% 1.  Detect tunnels

%thresh = opthr(I);

nGm = 3;
gm=gmdistribution.fit(I(:),nGm,'Replicates',5);
id = find(gm.mu == min(gm.mu));

idx=cluster(gm,I(:));
mask = reshape(idx,dim) == id;

out = regionprops(mask,'boundingbox','area');


%[B,L] = bwboundaries(i>thresh,'noholes');
%out = regionprops(i>thresh,'boundingbox','area');

imshow(i,[])
hold all

ct = 0;
tunnelIdx = [];
flyIdx = [];
for k=1:length(out)
    if out(k).Area > 0.01*prod(dim)
        tunnelIdx = [tunnelIdx k];
        h(k) = rectangle('Position',out(k).BoundingBox,'EdgeColor','g');
        bb = floor(out(k).BoundingBox);
        bb(bb==0) = 1;
        
        clip(k).binarypx = double(mask(bb(2):(bb(2)+bb(4)),bb(1):(bb(1)+bb(3))));
        clip(k).px = double(I(bb(2):(bb(2)+bb(4)),bb(1):(bb(1)+bb(3))));
        %stats = regionprops(~clip(k).binarypx,'Centroid','Eccentricity','Area','MajorAxisLength','PixelIdxList');
        stats = regionprops(~clip(k).binarypx,'PixelIdxList');
        
        %thresh = 25;
        %stats = regionprops(clip(k).px < thresh,'Centroid','Eccentricity');
        
        %reject small obj and those larger than 10% of the total tunnel area
        %tmp = find([stats.Area]>10 & [stats.Area] < 0.1*(bb(2)*bb(4)));
        
        
        % Heavy smoothing and then find min pixel value in each tunnel
        im=clip(k).px;
        im=imopen(im,strel('disk',4));
        mn = min(im(:));
        minPx = find(im(:)==mn);
        [x y] = ind2sub(size(im),minPx);
        clip(k).fly = [y(1) x(1)];
        %clip(k).fly = stats(tmp(1)).Centroid;
        
        %if there is an object containing the min point, plot that as fly
        flyIdx = [flyIdx k];
        for q = 1:length(stats)
            if sum(stats(q).PixelIdxList == minPx(1))
                [x y] = ind2sub(size(im),minPx);
                clip(k).fly = [y(1) x(1)];
                plot(clip(k).fly(1)+bb(1),clip(k).fly(2)+bb(2),'.r')
                ct = ct+1;
                tunnelMasks(:,:,ct) = zeros(dim);
                tunnelMasks(bb(2):(bb(2)+bb(4)),bb(1):(bb(1)+bb(3)),ct) = 1;
            end
        end
    end
end

% 2.  Determine which tunnels have flies

% for q=1:length(clip)
%     if isfield(clip(q),'fly')
%     end
% end


title(['Detected ' sprintf('%i',length(tunnelIdx)) ' tunnels and ' ...
    sprintf('%i',length(flyIdx)) ' flies'])


% 3.  Reset ROI to include active tunnels


% 4.  Calculate background for each tunnel

% bgout = tunnel masks (3D matrix), full bg of new ROI, 


BW = edge(i>thresh,'sobel');
se = strel('disk',1);
BW = imdilate(BW,se);


[H,theta,rho] = hough(BW);
P = houghpeaks(H,20,'threshold',ceil(0.3*max(H(:))));
lines = houghlines(BW,theta,rho,P,'FillGap',15,'MinLength',3);


figure;imshow(BW);hold on
for k = 1:length(lines)
    xy = [lines(k).point1; lines(k).point2];
    
    % Reject vertical lines < 80% or > 99% height of image
    len(k) = norm(lines(k).point1 - lines(k).point2);
    %if len(k) >= 0.8*dim(1) & len(k) < 0.99*dim(1)
    if len(k) > 0.05*dim(2) && len(k) < 0.1*dim(2)
        plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
        plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
        plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
    end
end


