function simulateBinomialDistribution(comb, choices)

day = 1; % does not work for day > 1 b/c missing flies are skipped in the loop below
ct = 0;

% get the number of choices made by each fly
% for day = 1:2
    for i = 1:length(choices)
        for ii = 1:length(choices{day,i})
            ct = ct + 1;
%             n(day,ct) = length(choices{day,i}{ii});
            n(ct) = length(choices{day,i}{ii});
        end
     end
%    ct = 0;
% end

combclean = comb;
combclean(:,find(isnan(comb(day,:)))) = [];
n(find(isnan(comb(day,:)))) = [];

% Exclude flies w/NaN on either day
% (gives same n flies as plotPrefCorrOverDays)
% combclean(:,find(sum(isnan(comb) > 0))) = [];
% n(find(sum(isnan(comb) > 0))) = [];

nSamp = 21;
edgs = linspace(0,1,nSamp);

% iteratively make a binomial sample w/ matched number of choices
for k = 1:1e3
    tmp(k,:) = random('bino', n, mean(combclean(day,:))) ./ n;
    out(k,:) = histc(tmp(k,:), edgs);
end

% compute mean count and 95% CI for each hist bin
p = mean(out);

for i = 1:length(p)
    ci(i,:) = prctile(out(:,i),[2.5,97.5]);
end

x = histc(combclean(day,:), edgs);
%x = histc(comb(:), edgs);
pnorm = p/sum(p);
cinorm = ci'/sum(p);

hold on
shadedErrorBar(1:21, pnorm, [(cinorm(1,:) -  pnorm); ...
    (pnorm - cinorm(2,:))], {'color', [0.5 0.5 0.5]}, 0)

plot(x/sum(x),'.-b', 'lineWidth', 3)

xlim([1 nSamp])
set(gca, 'XTick', 1:2:nSamp)
%set(gca, 'XTickLabel', edgs)
set(gca, 'XTickLabel', 0:0.1:1)

observed = mean(abs(combclean(day,:)-median(combclean(day,:))));
expected = mean(abs(tmp(:)-median(tmp(:))));

vbe = log2(observed/expected);
title(['VBE = ' sprintf('%0.2f', vbe)])

display(['VBE = ' sprintf('%0.2f', vbe) ', n = ' sprintf('%d', length(n))])

