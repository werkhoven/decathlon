function flyTracks = MbockPlot2014(flyTracks)
%
% To do:
% 1.  Fix NaN interpolation and smoothing correction for high freq exits
% 3.  Make sure it handles multiple stim blocks correctly

% KH - Revised Jan 1, 2014


figure

f = axes('Position',[0 0 1 1]);

axis off

apos = generatePositionMatrix(0.02, 0.98, 0.02, 0.95, .01, -.05, 16);


for k = 1:flyTracks.nFlies
    
    odorDecision = flyTracks.inCorridor(k).odorDecision;
    refOdorChosen = flyTracks.inCorridor(k).refOdorChosen;
    odor = flyTracks.inCorridor(k).odorSideA;
    exitIdx = flyTracks.inCorridor(k).exitFr;
    
    if isfield(flyTracks, 'day1Idx')
        axes('Position',apos(flyTracks.day1Idx(k),:))
    else
        axes('Position',apos(k,:))
    end
    
    [ptch1, ptch2] = makePatches(flyTracks,k,flyTracks.corridorPos);
    
    hold on
    
    plot(flyTracks.headLocal(:,2,k),flyTracks.relTimes,'k')
    
    plot([0 0], [0 max(flyTracks.relTimes)], '--b')
    plot([flyTracks.tunnels(4,k) flyTracks.tunnels(4,k)], [0 max(flyTracks.relTimes)], '--b')
    
    % plot the exit points, colored by toward or away from ref odor
    if strcmp(flyTracks.refOdor, flyTracks.stim{4,1}(1))
        set(ptch1,'edgecolor','none','facecolor', [0.7 1 0.7])
        set(ptch2,'edgecolor','none','facecolor', [1 0.7 1])
        plot(flyTracks.headLocal(exitIdx(odorDecision & refOdorChosen),2,k), flyTracks.relTimes(exitIdx(odorDecision & refOdorChosen)), '*g')
        plot(flyTracks.headLocal(exitIdx(odorDecision & ~refOdorChosen),2,k), flyTracks.relTimes(exitIdx(odorDecision & ~refOdorChosen)), '*m')
    else
        set(ptch1,'edgecolor','none','facecolor', [1 0.7 1])
        set(ptch2,'edgecolor','none','facecolor', [0.7 1 0.7])
        plot(flyTracks.headLocal(exitIdx(odorDecision & refOdorChosen),2,k), flyTracks.relTimes(exitIdx(odorDecision & refOdorChosen)), '*m')
        plot(flyTracks.headLocal(exitIdx(odorDecision & ~refOdorChosen),2,k), flyTracks.relTimes(exitIdx(odorDecision & ~refOdorChosen)), '*g')
    end
    
    % Label each track with p(choosing refOdor) and total n choices
    % during odor period
    text(flyTracks.tunnels(4,k)/2, -5, [ ...
        sprintf('%0.2f', flyTracks.probA(k)) ' (' ...
        sprintf('%2.0f', sum(flyTracks.inCorridor(k).odorDecision)) ')'], ...
        'HorizontalAlignment', 'center')
    
    set(gca,'ydir','rev')
    axis off
    xlim([-1 flyTracks.tunnels(4,k)+1])
    
end

set(gcf, 'Color', 'w')

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ptch1, ptch2] = makePatches(flyTracks, k, corridorPos)

ct=0;

temp={};
ctr=0;

for q=1:size(flyTracks.stim,2)
    tmp = flyTracks.stim{2,q};
    
    for qq = 1:size(tmp,1)
        ctr = ctr+1;
        mins(ctr) = min(tmp(qq,:));
        temp{1,ctr} = flyTracks.stim{1,q};
        temp{2,ctr} = tmp(qq,:);
    end
end

[~, idx] = sort(mins);


flyTracks.stim = temp;

for i = idx
    
    eventTimes = flyTracks.stim{2,i}(flyTracks.chargeTime:end);
    eventLabels{i} = flyTracks.stim{1,i};
    
    for ii=1:size(eventTimes,1)
        
        ct = ct+1;
        
        eventOn = min(eventTimes(ii,:));
        eventOff = max(eventTimes(ii,:)) + 1;  % Added 1 sec to analysis
        
        eventOnFrame = find(round(flyTracks.relTimes) == eventOn, 1);
        eventOffFrame = find(round(flyTracks.relTimes) == eventOff, 1);
        
        %subplot('Position',[0.05 0.05 .75 0.9])
        
        % color = [0.6,0.6,1]; %light blue
        % color=[0.5,0.5,0.5]; %gray
        
        ptch1=patch([0, corridorPos(1), corridorPos(1), 0],...
            [eventOn,eventOn,eventOff,eventOff], 0);
        set(ptch1,'edgecolor','none','facecolor', [1 0.7 1])
        
        ptch2=patch([corridorPos(end), flyTracks.tunnels(4,k), flyTracks.tunnels(4,k), corridorPos(end)],...
            [eventOn,eventOn,eventOff,eventOff], 0);
        set(ptch2,'edgecolor','none','facecolor',[0.7 1 0.7])
        
    end
end

end
