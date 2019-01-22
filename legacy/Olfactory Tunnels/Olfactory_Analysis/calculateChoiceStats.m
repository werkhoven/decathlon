function flyTracks = calculateChoiceStats(flyTracks, refOdor)
% To do:
%       1.  Maybe allow a params structure as input to define corridor
%           size, reference odor, and decision criteria
%       2.  Make execution modular - save processed structure with params
%           used, and then allow loading and recalculation based on new
%           params
%       3.  Option for verbose reporting and diagnostic plots (like
%           turn-triggered and corridor-triggered averaging)
%
%   Processing steps:
%   1.  The corridor area is defined for each tunnel
%   2.  Determine refOdor side (Side A/B) for each odor epoch
%
%   Iterate through flies:
%   3.  An event (inCorridor) is marked each time a fly's head enters the
%       corridor
%   4.  Events are culled if the fly has not traveled a set distance
%       (10 px) since the last entry - NEEDS SOME WORK ON ITERATIONS!
%   5.  Other features of each event are calculated (e.g. whether there was
%       a pause, cast, slow, etc.) and saved in inCorridor
%   6.  Only events that meet decision criteria are counted as decisions
%   7.  The odor choice resulting from each decision is used to calculate
%       the probability of choosing refOdor


% 1.  Determine extent of choice corridor

corridorSize = 5;                                                          % in mm
corridorPx = corridorSize/flyTracks.pxRes;                                 % distance across corridor in px
%tunnelCenter = 1 + (mean(flyTracks.tunnels(4,:))/2);
tunnelCenter = 100;

flyTracks.corridorPos = round(tunnelCenter - 0.5* corridorPx) : ...        % corridor range along y-axis, in px
    round(tunnelCenter + 0.5* corridorPx);



% 2.  Figure out which side the refOdor is on
odorIdx = [];
refOdorOnSideA = [];

for i = 1:size(flyTracks.stim,2)
    
    % 1 sec added after valve closing
    odorIdx = [odorIdx flyTracks.stim{2,i}(flyTracks.chargeTime:end) flyTracks.stim{2,i}(end) + 1];
    
    if find(strncmp(refOdor, flyTracks.stim{4,i}, 3)) == 1
        refOdorOnSideA = [refOdorOnSideA ones(1, length(flyTracks.stim{2,i}(flyTracks.chargeTime:end)) + 1)];
    else
        refOdorOnSideA = [refOdorOnSideA zeros(1, length(flyTracks.stim{2,i}(flyTracks.chargeTime:end)) + 1)];
    end
    
end



% 3.  Mark event each time the fly's head enters and exits corridor

inCorridor = zeros(size(flyTracks.headLocal,1),1,size(flyTracks.headLocal,3));

for i=1:length(flyTracks.corridorPos)
    inCorridor(round(flyTracks.headLocal(:,2,:)) == flyTracks.corridorPos(i)) = 1;
end

inCorridor = squeeze(inCorridor);
allEnters = diff(inCorridor) > 0;
allExits = diff(inCorridor) < 0;



%  Calculate stats, one fly at a time
for k = 1:size(allEnters,2)
    
    %  Compile indices of all frames with exits for each fly
    flyTracks.inCorridor(k).enterFr = find(allEnters(:,k));
    flyTracks.inCorridor(k).exitFr = find(allExits(:,k));
    
    
    %  Get rid of frames with no corresponding enter/exit
    if ~isempty(flyTracks.inCorridor(k).exitFr)
        
        if flyTracks.inCorridor(k).exitFr(1) < flyTracks.inCorridor(k).enterFr(1)
            flyTracks.inCorridor(k).exitFr(1) = [];
        end
        
        if flyTracks.inCorridor(k).enterFr(end) > flyTracks.inCorridor(k).exitFr(end)
            flyTracks.inCorridor(k).enterFr(end) = [];
        end                
        
    else   % give NaNs to flies w/out any exits
        refOdorChosen{k} = NaN;
        preOdorExits(k) = NaN;
        preOdorBias(k) =  NaN;
        tunnelRange(k) = range(flyTracks.centroid(:,2,k));
        dist(k) = sum(abs(diff(flyTracks.centroid(:,2,k)))*flyTracks.pxRes);
        continue   % Move along to next fly
    end
    
    
    % 4.  Remove doublets - centroid must move by at least 10 px
    tmpcut = [];
    
    for ii = 2:length(flyTracks.inCorridor(k).enterFr)
        clip = flyTracks.centroidLocal(flyTracks.inCorridor(k).enterFr(ii-1):flyTracks.inCorridor(k).enterFr(ii),2,k);
        extrema = [min(clip) max(clip)];
        
        if sum(abs(flyTracks.centroidLocal(flyTracks.inCorridor(k).enterFr(ii),2,k) - ...
                extrema) < 10) == 2,
            tmpcut(ii) = 1;
        else
            tmpcut(ii) = 0;
        end
        
    end
    
    flyTracks.inCorridor(k).enterFr(logical(tmpcut)) = [];
    flyTracks.inCorridor(k).exitFr(logical([tmpcut(2:end) 0])) = [];
    
    % flyTracks.inCorridor(k).enterFr(ii) = [];
    % flyTracks.inCorridor(k).exitFr(ii-1) = [];
    

    % 2.4.  For each exit, mark as 'No odor', 'Ref Odor SideA', or 'Ref Odor Side B'
    flyTracks.inCorridor(k).odorSideA = zeros(1,length(flyTracks.inCorridor(k).exitFr));
    
    for ii = 1:length(flyTracks.inCorridor(k).odorSideA)
        
        t = flyTracks.relTimes(flyTracks.inCorridor(k).exitFr(ii));  % the time of this exit
        
        if any(round(t) == odorIdx) % if exit occurs during odor block
            
            if refOdorOnSideA(floor(t) == odorIdx)  
                flyTracks.inCorridor(k).odorSideA(ii) = 1;  % if exit occurs when Ref odor is on Side A
            else
                flyTracks.inCorridor(k).odorSideA(ii) = -1; % if exit occurs when Ref odor is on Side B
            end
            
        end
        
    end
    
    
    % 2.5.  Mark each exit as containing pause or slow-down
	flyTracks.inCorridor(k).pause = zeros(1,length(flyTracks.inCorridor(k).exitFr));

    for ii = 1:(length(flyTracks.inCorridor(k).exitFr))
        
        if any(flyTracks.pauses(flyTracks.inCorridor(k).enterFr(ii):flyTracks.inCorridor(k).exitFr(ii),k));
            flyTracks.inCorridor(k).pause(ii) = 1;
        end
        
    end
    
    
    flyTracks.inCorridor(k).slowdown = zeros(1,length(flyTracks.inCorridor(k).exitFr));

    for ii = 1:(length(flyTracks.inCorridor(k).exitFr))
        
        if any(flyTracks.slow(flyTracks.inCorridor(k).enterFr(ii):flyTracks.inCorridor(k).exitFr(ii),k))...
                & ~flyTracks.inCorridor(k).pause(ii)
            flyTracks.inCorridor(k).slowdown(ii) = 1;
        end
        
    end
    
    % 2.6.  Mark each exit as containing a cast
    flyTracks.inCorridor(k).cast = zeros(1,length(flyTracks.inCorridor(k).exitFr));
    
    % Calculate the total displacement for each corridor period
    for ii = 1:length(flyTracks.inCorridor(k).exitFr)
        oritmp = flyTracks.orientation(flyTracks.inCorridor(k).enterFr(ii):flyTracks.inCorridor(k).exitFr(ii),k);
        dt = abs(diff(oritmp));
        flyTracks.inCorridor(k).cast(ii) = sum(dt) > 90; % Total angular displacement > 90 deg while in corridor
        
        % Try range instead of sum?
        
    end

    
    % 2.7.  Determine from which side fly exited - mark as odor choice (Side A == 1)
    exitPos = flyTracks.headLocal(flyTracks.inCorridor(k).exitFr,2,k)';
    enterPos = flyTracks.headLocal(flyTracks.inCorridor(k).enterFr,2,k)';

    flyTracks.inCorridor(k).reversal = abs(enterPos - exitPos) < 10;
    
    flyTracks.inCorridor(k).time = flyTracks.relTimes(flyTracks.inCorridor(k).exitFr) ...
        - flyTracks.relTimes(flyTracks.inCorridor(k).enterFr);
    
    flyTracks.inCorridor(k).sideAexit = exitPos > 100;
    
    
    % 2.8.  Detect decision:
    % logical check of each period against all stats to determine choices

                            %%%%%% Make this a case-switch block, save all
                            %%%%%% inCorridor elements in flyTracks %%%%%%%

%     flyTracks.inCorridor(k).decision = ...
%         ones(1, length(flyTracks.inCorridor(k).pause));                    % All exits

%     flyTracks.inCorridor(k).decision = flyTracks.inCorridor(k).reversal;   % Only reversals

%     flyTracks.inCorridor(k).decision = flyTracks.inCorridor(k).pause;      % Includes a pause
    
%     flyTracks.inCorridor(k).decision = flyTracks.inCorridor(k).cast;       % Includes a cast

%     flyTracks.inCorridor(k).decision = flyTracks.inCorridor(k).pause ...   % Includes a pause
%         & flyTracks.inCorridor(k).cast;                                    % and a cast
 
%     flyTracks.inCorridor(k).decision = flyTracks.inCorridor(k).pause ...   % Includes a pause
%         & flyTracks.inCorridor(k).time < 1.75;                             % and time spent in corridor is < 1.75s

%     flyTracks.inCorridor(k).decision = ...
%         flyTracks.inCorridor(k).reversal ...                               % Either a reversal
%         | (~flyTracks.inCorridor(k).reversal ...                           % or a traversal
%         & flyTracks.inCorridor(k).slowdown);                               % w/a slow-down

    flyTracks.inCorridor(k).decision = flyTracks.inCorridor(k).reversal ...% Either a reversal
        | (~flyTracks.inCorridor(k).reversal ...                           % or a traversal
        & ~flyTracks.inCorridor(k).pause);                                 % w/out a pause

    flyTracks.inCorridor(k).odorDecision = flyTracks.inCorridor(k).decision ...
        & flyTracks.inCorridor(k).odorSideA;
        
    % Test whether odor decision was towards ref odor
    flyTracks.inCorridor(k).refOdorChosen = flyTracks.inCorridor(k).odorDecision & ...
        ((flyTracks.inCorridor(k).sideAexit == flyTracks.inCorridor(k).odorSideA) | ...
        ((flyTracks.inCorridor(k).odorSideA == -1) & (flyTracks.inCorridor(k).sideAexit == 0)));
    

    % 3.1.  Map choices back to odor periods, translate into odor choice
    if  any(flyTracks.inCorridor(k).odorDecision)
        preOdorExits(k) = find(flyTracks.inCorridor(k).odorDecision, 1, 'first') - 1;  % number of pre-odor choices
        
        % Calculate pre-odor bias using the same 'decision' criteria as
        % odor period
        preOdorBias(k) =  sum(flyTracks.inCorridor(k).decision(1:preOdorExits(k)) & ...
            flyTracks.inCorridor(k).sideAexit(1:preOdorExits(k))) / ...
            sum(flyTracks.inCorridor(k).decision(1:preOdorExits(k)));
        %preOdorBias(k) =  nanmean(flyTracks.inCorridor(k).sideAexit(1:preOdorExits(k)));
    else
        preOdorExits(k) = NaN;
        preOdorBias(k) =  NaN;
    end
    
    tunnelRange(k) = range(flyTracks.headLocal(:,2,k));
    
end



for i = 1:length(flyTracks.inCorridor)
    flyTracks.probA(i) = nanmean(flyTracks.inCorridor(i).refOdorChosen(flyTracks.inCorridor(i).odorDecision)); % prop. total choices made towards refOdor
end



% 6. Format output
flyTracks.corridorSize = corridorSize;
flyTracks.preOdorExits = preOdorExits;
flyTracks.preOdorBias = preOdorBias;
flyTracks.tunnelRange = tunnelRange;
flyTracks.hasNaNs = logical(sum(isnan(squeeze(flyTracks.centroid(:,2,:)))));
flyTracks.refOdor = refOdor;


%flyTracks.dtmubaseline = dtmubaseline;
%find the 90th percentil of pre-odor displacements
%flyTracks.orithresh = prctile(dtmubaseline,90);