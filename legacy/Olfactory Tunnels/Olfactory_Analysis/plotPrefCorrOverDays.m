function plotPrefCorrOverDays(comb)

combclean = comb;
combclean(:,find(sum(isnan(comb) > 0))) = [];

x = combclean(1,:)';
y = combclean(2,:)';
b = [ones(length(x),1) x] \ y;

[r, p] = corrcoef(combclean');
ci = bootstrapCorrelationCI(combclean');

display(['r = ' sprintf('%0.4f', r(2)) ', p = ' ...
    sprintf('%0.4f', p(2)) ', n = ' sprintf('%0.0f', size(combclean,2))])
display(['95% CI (bootstrap): [' sprintf('%0.4f', ci(1)) ' ' ...
    sprintf('%0.4f', ci(2)) ']'])

h = plot(combclean(1,:), combclean(2,:), 'ok', 'MarkerSize', 10);
set(h, 'MarkerEdgeColor', 'w', 'MarkerFaceColor', 'k')
axis square
xlim([0 1])
ylim([0 1])
% line([0 1],[0 1],'Color', 'k')
line([0 1], [b(1), b(1)+b(2)], 'LineStyle', '--', 'Color', 'k')
set(gca, 'XTick', get(gca,'YTick'))
xlabel('Day 1')
ylabel('Day 2')

