function [ex obs] = flyMI(flyTracks)


for i = 1:flyTracks.nFlies
    tmp(i,:)  = flyTracks.centroid(1:50:5e3,2,i) < 120;
end

% Joint MI between flies
% mutinfo = [];
% 
% for i = 1:(flyTracks.nFlies-1)
%     for ii = i+1:flyTracks.nFlies
%         % Joint probs
%         a = mean(tmp(i,:) & tmp(ii,:)); % [1 1]
%         b = mean(tmp(i,:) & ~tmp(ii,:)); % [1 0]
%         c = mean(~tmp(i,:) & tmp(ii,:)); % [0 1]
%         d = mean(~tmp(i,:) & ~tmp(ii,:)); % [0 0]
%         % Marginals
%         e = mean(tmp(i,:));
%         f = mean(tmp(ii,:));
%         g = mean(~tmp(i,:));
%         h = mean(~tmp(ii,:));
%         
%         mutinfo = [mutinfo a * log2(a/(e*f)) + ...
%              b * log2(b/(e*h)) + ...
%              c * log2(c/(g*f)) + ...
%              d * log2(d/(g*h))];
%     end
% end

% Calculate chance MI of shuffled positions
% for k = 1:flyTracks.nFlies
%     tmp(k,:) = tmp(k,randperm(100));
% end
% 
% % Joint MI between flies
% mi = [];
% 
% for i = 1:(flyTracks.nFlies-1)
%     for ii = i+1:flyTracks.nFlies
%         % Joint probs
%         a = mean(tmp(i,:) & tmp(ii,:)); % [1 1]
%         b = mean(tmp(i,:) & ~tmp(ii,:)); % [1 0]
%         c = mean(~tmp(i,:) & tmp(ii,:)); % [0 1]
%         d = mean(~tmp(i,:) & ~tmp(ii,:)); % [0 0]
%         % Marginals
%         e = mean(tmp(i,:));
%         f = mean(tmp(ii,:));
%         g = mean(~tmp(i,:));
%         h = mean(~tmp(ii,:));
%         
%         mutinfo = [mutinfo a * log2(a/(e*f)) + ...
%              b * log2(b/(e*h)) + ...
%              c * log2(c/(g*f)) + ...
%              d * log2(d/(g*h))];
%         
%     end
% end
% 
% ex = mutinfo;


% To use MEX calculation of MI from MIToolbox
mutinfo = [];
for i = 1:(flyTracks.nFlies-1)
    for ii = i+1:flyTracks.nFlies
        mutinfo = [mutinfo mi(double(tmp(i,:))', double(tmp(ii,:))')];
    end
end

obs = mutinfo;

% Need to have a breakpoint here and load second flyTracks
for i = 1:flyTracks.nFlies
    tmp2(i,:)  = flyTracks.centroid(1:50:5e3,2,i) < 120;
end

mutinfo = [];
for i = 1:(flyTracks.nFlies-1)
    for ii = i+1:flyTracks.nFlies
        mutinfo = [mutinfo mi(double(tmp(i,:))', double(tmp2(ii,:))')];
    end
end

ex = mutinfo;

% multiHist({ex obs})

        