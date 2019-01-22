function flyTracks = MbockPlot2013(flyTracks, doPlot, refOdor)
%
% To do:
% 1.  Fix NaN interpolation and smoothing correction for high freq exits
% 2.  Correct occupancy calculations
% 3.  Make sure it handles multiple stim blocks correctly
% 4.  Slim back to plotting fcn


if nargin < 3
    refOdor = flyTracks.stim{4,1}(1); % calculate scores in reference to Odor A of the first presentation
end

if nargin < 2
    doPlot = 1;
end


% Pre-process data
%flyTracks = removeOutliers(flyTracks);  % interpolate missing data

% Smooth data (improves quality of velocity estimate)
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %
winSz = 4;                % 125ms - assuming an average frame rate of 32fps

% Identify flies with missing data
hasNaNs = logical(sum(isnan(squeeze(flyTracks.orientation))));

for i = find(~hasNaNs)            % skip flies that have NaNs in the tracks
    flyTracks.centroid(:,1,i) = smooth(flyTracks.centroid(:,1,i),winSz);
    flyTracks.centroid(:,2,i) = smooth(flyTracks.centroid(:,2,i),winSz);
    flyTracks.orientation(:,i) = smooth(flyTracks.orientation(:,i),winSz);    
end
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %



% Calculate timestamps relative to experiment start
for i = 1:length(flyTracks.times)
    flyTracks.etimes(i) = etime(datevec(flyTracks.times(i)), datevec(flyTracks.times(1)));
end


nFrames = size(flyTracks.centroid,1);
flyTracks.rate = nFrames/flyTracks.duration; % average video rate in fps


% 1. Calculate fly positions relative to tunnels
activeTunnels = find(flyTracks.tunnelActive);

for i = 1:length(activeTunnels)
    tun = flyTracks.tunnels(:,activeTunnels(i));
    flyTracks.centroidLocal(:,:,i) = [(flyTracks.centroid(:,1,i) - tun(1)), ...
        (flyTracks.centroid(:,2,i) - tun(2))];
end


% 2. Determine choice corridors (maybe expand region slightly)

corridorSize = 10; % in mm (formerly 8mm)
corridorPx = corridorSize/flyTracks.pxRes; % distance across corridor in px
tunnelCenter = mean(flyTracks.tunnels(4,:)) / 2;

corridorPos = [round(tunnelCenter - 0.5* corridorPx) : ...
    round(tunnelCenter + 0.5* corridorPx)]; % along y-axis


% 3. Mark event each time the fly (only head?) enters and exits corridor

inCorridor = zeros(size(flyTracks.centroidLocal,1),1,size(flyTracks.centroidLocal,3));

for i=1:length(corridorPos)
    inCorridor(round(flyTracks.centroidLocal(:,2,:)) == corridorPos(i)) = 1;
end

inCorridor = squeeze(inCorridor);
allEnters = diff(inCorridor) > 0;
allExits = diff(inCorridor) < 0;


% 4. Figure out which side the refOdor is on
odorIdx = [];
refOdorOnSideA = [];

for i = 1:size(flyTracks.stim,2)
    
    odorIdx = [odorIdx flyTracks.stim{2,i}(flyTracks.chargeTime:end) flyTracks.stim{2,i}(end) + 1];
    
    if find(strncmp(refOdor, flyTracks.stim{4,i}, 3)) == 1
        refOdorOnSideA = [refOdorOnSideA ones(1, length(flyTracks.stim{2,i}(flyTracks.chargeTime:end)) + 1)];
    else
        refOdorOnSideA = [refOdorOnSideA zeros(1, length(flyTracks.stim{2,i}(flyTracks.chargeTime:end)) + 1)];
    end
    
end



% Begin terrible, slow hack...
for k = 1:size(allEnters,2)
    enterInd = find(allEnters(:,k));
    exitInd = find(allExits(:,k));
    
    if isempty(exitInd) % give NaNs to flies w/out exits during odor period
       refOdorChosen{k} = NaN;
       preOdorExits(k) = NaN;
       preOdorBias(k) =  NaN;
       tunnelRange(k) = range(flyTracks.centroid(:,2,k));
       dist(k) = sum(abs(diff(flyTracks.centroid(:,2,k)))*flyTracks.pxRes);
       continue
    end
    
    
    for ii = 2:length(enterInd)
        clip = flyTracks.centroidLocal(enterInd(ii-1):enterInd(ii),2,k);
        extrema = [min(clip) max(clip)];
        
        if sum(abs(flyTracks.centroidLocal(enterInd(ii),2,k) - ...
                extrema) < 10) == 2,
            allEnters(enterInd(ii),k) = 0;
            
            % if an exit has no corresponding entrance, delete the previous
            % exit
            allExits(exitInd(ii-1),k) = 0;
        end
    end
    
    % Update idices
    enterInd = find(allEnters(:,k));
    exitInd = find(allExits(:,k));
    
    % 4. Determine from which side fly exited - mark as odor choice (Side A == 1)
    
    exitPos = flyTracks.centroidLocal(logical([0; allExits(:,k)]),2,k);
    sideAexit{k} = exitPos > 100;
    
    
    % 5. Map choices back to odor periods, translate into odor choice
    
    ExitDuringOdorPeriod{k} = zeros(1,length(exitInd));
    RefAidx = zeros(1,length(exitInd));
    
    

    for ii = 1:length(ExitDuringOdorPeriod{k})
        t = flyTracks.etimes(exitInd(ii));  % the time of this exit
        
        if sum(floor(t) == odorIdx) % if exit occurs during odor block
            ExitDuringOdorPeriod{k}(ii) = 1;
            RefAidx(ii) = refOdorOnSideA(find(floor(t) == odorIdx)); % same size as ExitDuringOdorPeriod
        end
        
    end
    
    
%     preOdorExits(k) = length(ExitDuringOdorPeriod);
%     preOdorBias(k) =  nanmean(sideAexit{k}(1:length(ExitDuringOdorPeriod)));
    
if  any(ExitDuringOdorPeriod{k})
    preOdorExits(k) = find(ExitDuringOdorPeriod{k}, 1, 'first') - 1;  % number of pre-odor choices
    preOdorBias(k) =  nanmean(sideAexit{k}(1:preOdorExits(k)));
else
    preOdorExits(k) = NaN;
    preOdorBias(k) =  NaN;
end
    
    tunnelRange(k) = range(flyTracks.centroid(:,2,k));
    dist(k) = sum(abs(diff(flyTracks.centroid(:,2,k)))*flyTracks.pxRes);
    
    
    refOdorChosen{k} = [];
    
    for i = find(ExitDuringOdorPeriod{k}) % for every choice during odor block
        
        if sideAexit{k}(i) == RefAidx(i) % test whether the exit was towards refOdor
            refOdorChosen{k} = [refOdorChosen{k} 1];
            
        else
            refOdorChosen{k} = [refOdorChosen{k} 0]; % or away from refOdor
        end
        
    end
    
end

% 
% firstOdorFrame = find(floor(flyTracks.etimes) == odorIdx(1), 1, 'first');
% 
% onSideAatOdorOnset = squeeze(flyTracks.centroidLocal(firstOdorFrame, 2, :) > 100);
% 
% for k = 1:length(sideAexit)
%     choseSideAfirst(k) = sideAexit{k}(preOdorExits(k) + 1);
% end
% 
% out = [onSideAatOdorOnset' ; choseSideAfirst];

%prop flies initially choosing the side they were on when odor started
%out = sum(~abs(onSideAatOdorOnset' - choseSideAfirst))/length(tmp) 


% 6. Format output
flyTracks.refOdorChosen = refOdorChosen;
flyTracks.preOdorExits = preOdorExits;
flyTracks.preOdorBias = preOdorBias;
flyTracks.tunnelRange = tunnelRange;
flyTracks.dist = dist;
flyTracks.hasNaNs = logical(sum(isnan(squeeze(flyTracks.centroid(:,2,:)))));



% 7. Do plotting, if requested
if doPlot
    
    figure;
    
    byChoice = NaN(size(refOdorChosen,2), max(cellfun(@length, refOdorChosen)));
    
    for i = 1:flyTracks.nFlies
        probA(i) = nanmean(refOdorChosen{i}); % prop. total choices made towards refOdor
    end
    
    for i = 1:size(byChoice,1)
        byChoice(i,1:length(refOdorChosen{i})) = refOdorChosen{i};
    end
    
    plot(nanmean(byChoice), '.-')
    ylim([0 1])
    
    figure
    tunnelLength = 200; % size(flyTracks.bg,1);
    nBins = 20;
    edges = linspace(0,tunnelLength,nBins);
    %edges = 0:tunnelLength/nBins:tunnelLength;
    
    
    subplot('Position',[0.05 0.05 .75 0.9])
    ct = 0;
    for i=1:size(flyTracks.centroid,3)
        ct = ct + 1;
        plot(flyTracks.centroid(:,2,i)+(250*ct),flyTracks.etimes,'k')
        hold on
        plot(repmat(max(flyTracks.centroid(:,2,i)+(250*ct)),nFrames,1),flyTracks.etimes,'--b')
        plot(repmat(min(flyTracks.centroid(:,2,i)+(250*ct)),nFrames,1),flyTracks.etimes,'--b')
        
        
        % plot the exit points, colored by toward or away from ref odor
        tmp = find(allExits(:,i));
        
        if strcmp(refOdor, flyTracks.stim{4,1}(1))
            plot(flyTracks.centroid(tmp(sideAexit{i}),2,i)+(250*ct), flyTracks.etimes(tmp(sideAexit{i})), '*g')
            plot(flyTracks.centroid(tmp(~sideAexit{i}),2,i)+(250*ct), flyTracks.etimes(tmp(~sideAexit{i})), '*m')
        else
            plot(flyTracks.centroid(tmp(sideAexit{i}),2,i)+(250*ct), flyTracks.etimes(tmp(sideAexit{i})), '*m')
            plot(flyTracks.centroid(tmp(~sideAexit{i}),2,i)+(250*ct), flyTracks.etimes(tmp(~sideAexit{i})), '*g')
        end
        
        % Label each track with p(choosing refOdor) and total n choices
        % during odor period
        text(250*ct + 70, -5, [sprintf('%0.2f', probA(i)) ' (' sprintf('%2.0f', length(refOdorChosen{i})) ')'])
    
    end
    
    hold on
    ct=0;
    
    temp={};
    ctr=0;
    
    for q=1:size(flyTracks.stim,2)
        tmp=flyTracks.stim{2,q};
        
        for qq=1:size(tmp,1)
            ctr = ctr+1;
            mins(ctr) = min(tmp(qq,:));
            temp{1,ctr} = flyTracks.stim{1,q};
            temp{2,ctr} = tmp(qq,:);
        end
    end
    
    [~, idx]=sort(mins);
    
    
    flyTracks.stim = temp;
    
    for i=idx %1:length(flyTracks.stim)
        
        eventTimes = flyTracks.stim{2,i}(flyTracks.chargeTime:end);
        eventLabels{i} = flyTracks.stim{1,i};
        
        for ii=1:size(eventTimes,1)
            
            ct = ct+1;
            
            eventOn = min(eventTimes(ii,:));
            eventOff = max(eventTimes(ii,:));
            
            eventOnFrame = find(round(flyTracks.etimes) == eventOn, 1);
            eventOffFrame = find(round(flyTracks.etimes) == eventOff, 1);
            
            subplot('Position',[0.05 0.05 .75 0.9])
            
            %color=[0.6,0.6,1]; %light blue
            color=[0.5,0.5,0.5]; %gray
            
            ptch=patch([1, 4000, 4000, 1],...
                [eventOn,eventOn,eventOff,eventOff], 0);
            set(ptch,'edgecolor','none','facecolor',color, 'faceAlpha', 0.5)
            
            
            %plot(repmat(eventOn,4000,1),'r')
            %plot(repmat(eventOff,4000,1),'r')
            
            subplot('Position',[0.85 0.05 .1 0.9])
            
            for k=1:size(flyTracks.centroidLocal,3)
                flyTracks.occ(k,:)=histc(flyTracks.centroidLocal(...
                    eventOnFrame:eventOffFrame,2,k),edges)/length(...
                    flyTracks.centroidLocal(eventOnFrame:eventOffFrame));
                
                flyTracks.PI(k)=sum(flyTracks.occ(k,1:nBins/2))-sum(...
                    flyTracks.occ(k,(nBins/2+1):nBins));
                
                flyTracks.indPIs(k,ct) = flyTracks.PI(k);
                
                %        %flyTracks.dTraveled(k)=sum(abs(diff(flyTracks.centroid(:,2,k))))/(235/77); %Distance traveled in cm
                %        %flyTracks.velocity=abs(diff(baselineFixed.centroid(:,2,k)));
            end
            
            
            mu=squeeze(mean(flyTracks.occ,1));
            
            muPI=mean(flyTracks.PI,1);
            sdPI=std(flyTracks.PI,1);
            
            left=sum(mu(1:10));
            right=sum(mu(11:20));
            barData(ct,:) = [left right];
            
            eventPI(ct) = left-right;
            eventSD(ct) = mean(sdPI);
            
            eventLabel{ct} = eventLabels{i};
            eventMids(ct) = mean([eventOnFrame eventOffFrame]);
            
        end
        
    end
    
    subplot('Position',[0.05 0.05 .75 0.9])
    set(gca,'ydir','rev')
    %set(gca,'YTick',1:60:flyTracks.duration+1)
    %set(gca,'YTickLabel',0:60:flyTracks.duration)
    axis([200 4000 1 flyTracks.duration+1])
    box off
    
    subplot('Position',[0.85 0.05 .1 0.9])
    colormap winter
    h=barh(barData,'stacked');
    set(h,'XData',eventMids)
    set(gca,'YTick',sort(round(eventMids),'ascend'))
    set(gca,'YTickLabel',eventLabel)
    axis([0 1 1 nFrames+1])
    hold on
    plot(repmat(0.5,nFrames,1),flyTracks.etimes,'k')
    
    for i=1:length(eventPI)
        %eventLabel = ['Mean PI: ' sprintf('%5.2f',eventPI(i)) ' (' sprintf('%5.2f',eventSD(i)) ')'];
        %text(0, eventMids(i), eventLabel, 'FontName', 'Arial', 'FontSize', 14,
        %'FontWeight', 'bold', 'color', 'white');
        eventLabel = [sprintf('%5.2f',eventPI(i)) ' (' sprintf('%5.2f',eventSD(i)) ')'];
        text(1, eventMids(i), eventLabel, 'FontName', 'Arial', 'FontSize', 14, 'FontWeight', 'bold', 'color', 'white');
    end
    
    set(gca,'ydir','rev')
    box off
    
    
end

%title(['Mean PI: ' sprintf('%5.2f',muPI) ' ± ' sprintf('%5.2f',sdPI)]);
%axis([0 nBins+1 0 0.5])


