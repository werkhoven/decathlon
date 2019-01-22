function plotHabituationCurve(comb)
% input comb is matrix (fly x choice #) with all odor choices made by each
% fly during the experiment.  Entries are logicals (1 = Air choice) and
% empty cells are filled with NaN.

[phat, pci] = binofit(sum(comb == 1), sum(comb == 1) + sum(comb == 0));

maxCount = 35;

figure
hold on
for i=1:maxCount
    line([i i], pci(i,:), 'color', 'k', 'linewidth', 3)
end

plot(phat(1:maxCount),'.b', 'markersize', 24)
ylim([0.3 1])
xlim([0 maxCount+1])

line(xlim, [0.5 0.5], 'color', 'k', 'linestyle', '--')

xlabel('Choice number')
ylabel('p(choosing Air)')


figure
nchoices=sum(~isnan(comb),2);
[h, x] = hist(nchoices,15);
hist(nchoices,15)

figure
plot(x,cumsum(h)/max(cumsum(h)))

