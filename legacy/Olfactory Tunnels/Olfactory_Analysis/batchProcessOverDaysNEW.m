function batchProcessOverDaysNEW(nGroups, nDays, refOdor, doStats)

if nargin < 4
    doStats = 1;
end


if doStats
    fid = dir('2U_*'); % runs from the working directory
    charN = 26;
    ct = 0;
    
    for i = 1:length(fid)
        
        if ct < nGroups
            ct = ct + 1;
        else
            ct = 1;
        end
        
        display(i)
        %load(fid(i).name);
        flyTracks = calculateFlyStats(fid(i).name, refOdor);
        
        for k = 1:length(flyTracks.inCorridor)
            refOdorChosen{k} = flyTracks.inCorridor(k).refOdorChosen(flyTracks.inCorridor(k).odorDecision);
        end
        
        occupancy{eval(fid(i).name(charN)),ct} = flyTracks.occupancy;
        choices{eval(fid(i).name(charN)),ct} = refOdorChosen;
        preOdorExits{eval(fid(i).name(charN)),ct} = flyTracks.preOdorExits;
        preOdorBias{eval(fid(i).name(charN)),ct} = flyTracks.preOdorBias;
        tunnelRange{eval(fid(i).name(charN)),ct} = flyTracks.tunnelRange;
        dist{eval(fid(i).name(charN)),ct} = flyTracks.dist;
        hasNaNs{eval(fid(i).name(26)),ct} = flyTracks.hasNaNs;
        
        if eval(fid(i).name(charN)) == 1
            idx{eval(fid(i).name(charN)),ct} = 1:length(choices{eval(fid(i).name(26)),ct});
        else
            idx{eval(fid(i).name(charN)),ct} = flyTracks.day1Idx;
        end
        
        refOdorChosen = {};
        
        % m(eval(fid(i).name(26)),ct) = strcmp('MCH', flyTracks.stim{4}(1)); % has MCH on side A
        
    end
    
else
    
    load combinedData
    if exist('comb', 'var'), comb = []; end % so old comb matrix doesn't interfere with below
    
end

% sameSide = find(m(1,:) - m(2,:) == 0);
% 
% choices = choices(:,sameSide);
% preOdorExits = preOdorExits(:,sameSide);
% preOdorBias = preOdorBias(:,sameSide);
% tunnelRange = tunnelRange(:,sameSide);
% dist = dist(:,sameSide);
% hasNaNs = hasNaNs(:,sameSide);
% idx = idx(:,sameSide);


% Calculate pref score and NaN any flies that don't meet inclusion criteria

nChoices = 15;

for i = 1:length(choices(:))  % over experiments
    
    for ii = 1:length(choices{i}) % over flies
        
        tmp = choices{i}{ii};
        
        % Inclusion criteria
        if length(tmp) < nChoices || preOdorExits{i}(ii) < 15 || ...
                 tunnelRange{i}(ii) < 190
                % preOdorBias{i}(ii) > 0.75 || preOdorBias{i}(ii) < 0.25 || ...
               
%         if length(tmp) < nChoices || preOdorBias{i}(ii) > 0.75 ...
%                 || preOdorBias{i}(ii) < 0.25
            out(ii) = NaN;
        else
            out(ii) = mean(tmp);
            %out(ii) = preOdorBias{i}(ii);
            %out(ii) = mean(tmp(1:nChoices)); % limit to first nChoices
            %out(ii) = occupancy{i}(ii);
        end
        
    end
    
    prefscore{i} = out;
    out = [];
    
end

prefscore = reshape(prefscore, size(idx));

comb = [prefscore{1,:}];

if nDays > 1
    
    for day = 2:size(idx,1)
        
        out = [];
        
        for i = 1:size(idx,2)
            
            tmp = NaN(1,length(prefscore{1,i}));
            
            for ii = 1:length(idx{day,i})
                tmp(idx{day,i}(ii)) = prefscore{day,i}(ii);
            end
            
            out = [out tmp];
            
        end
        
        comb(day,:) = out;
        
    end
    
end

% Exclude any flies that have NaNs in their tracks
for i  = 1:nDays
    comb(i,[hasNaNs{i,:}]) = NaN;
end

save combinedData choices idx occupancy preOdorBias preOdorExits ...
    tunnelRange dist comb hasNaNs

if nDays > 1, plotPrefCorrOverDays(comb); end

% col = {'b' 'k' 'r' 'g'};
% for i = 1:4
%     x = histc(comb(i,:), linspace(0.1,1,nSamp));
%     plot(x/sum(x),'o-', 'Color', col{i}, 'LineWidth', 2)
%     hold on
%     xlim([0 20])
%     set(gca, 'XTickLabel', 0:0.1:1)
% end
%
% figure
% [y, x] = hist(f,10);
% bar(x,y/sum(y))
% hold on
% nSamp = 21;
% p = pdf('binomial', 0:nSamp, nSamp, nanmean(f));
% plot((0:nSamp)/nSamp,p,'.-')

