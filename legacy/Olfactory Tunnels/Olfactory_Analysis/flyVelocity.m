function out = flyVelocity(flyTracks, doPlot)
%
%  Need to update plotting function
%
%

if nargin < 2
    doPlot = 0;
end


binSize = 0.3; %bin size in sec

pxmm = 1/flyTracks.pxRes; % convert mm/px to px/mm
times = round(100*flyTracks.relTimes)/100; %rounded frame times
blocks = min(times):binSize:max(times); %bin edges in time


for k = 1:(length(blocks)-1)
    
    for i=1:size(flyTracks.centroid,3)
        fr = find(times >= blocks(k) & times <= blocks(k+1)); %bin edges in frames
        deltaX(k,i) = abs(diff(flyTracks.centroid([min(fr) max(fr)],1,i)));
        deltaY(k,i) = abs(diff(flyTracks.centroid([min(fr) max(fr)],2,i)));
    end
end

velocity = sqrt(deltaX.^2 + deltaY.^2)/(binSize*pxmm); %convert to mm/sec
binEdges = blocks(2:end);

% Interpolate values
for i = 1:size(velocity,2)
    out(:,i) = interp1(binEdges, velocity(:,i), flyTracks.relTimes);
end

if doPlot
    plot(binEdges,smooth(mean(velocity,2),20))
    xlabel('time (sec)')
    ylabel(['mean speed (mm / sec) calculated in ' sprintf('%0.1f', binSize) 'sec bins'])
    
    yl=ylim;
    xl=[min(flyTracks.stim{2})+flyTracks.chargeTime max(flyTracks.stim{2})];
    color = [0.5 0.5 0.5];
    ptch = patch([xl(1) xl(1) xl(2) xl(2)],[yl fliplr(yl)],'k');
    set(ptch,'edgecolor','none','facecolor',color, 'faceAlpha', 0.5)
end