function plot_sigstar(ax,data,pairs,varargin)
% Plots significance stars for distributions in data
% 
% data - Nx1 cell array of distributions
% pairs - Mx2 comparison indices

% set defaults
test = 'ranksum';
bars = 'on';

% parse inputs
for i=1:numel(varargin)
    arg = varargin{i};
    if ischar(arg)
        switch arg
            case 'Test'
                i=i+1;
                test = varargin{i};
            case 'Bars'
                i=i+1;
                bars = varargin{i};
        end
    end
end

hold(ax,'on');
ax.YLim(2) = ax.YLim(2)*1.5;
pairs = num2cell(pairs,2);

switch test
    case 'ranksum'
        [p_vals,~,stats] = cellfun(@(idx) ...
            ranksum(data{idx(1)},data{idx(2)}),...
            pairs, 'UniformOutput', false);
end

% plot bars
p_vals = cat(1,p_vals{:});
p_vals = p_vals.*numel(pairs);
pairs = pairs(p_vals<0.05);
p_vals(p_vals>0.05) = [];

switch bars
    case 'on'
        vx = cellfun(@(pa) [pa([1 1 2 2])'; NaN], pairs, 'UniformOutput',false);
        vy = repmat(ax.YLim(2).*[.78,.8,.8,.78,NaN],numel(vx),1)';
        vx = cat(1,vx{:});
        plot(vx(:),vy(:),'k','LineWidth',1);
        
        x = num2cell(cellfun(@nanmean,pairs));
    case 'off'
        x = num2cell(cellfun(@(p) p(1), pairs));
end

% plot stars
siglevel = ones(numel(pairs),1);
siglevel(p_vals<0.01)=2;
siglevel(p_vals<0.001)=3;
sigstr = arrayfun(@(p, sl) ...
    {sprintf('(p = %1.1e)',p);repmat('*',1,sl)}, ...
    p_vals, siglevel, 'UniformOutput', false);

ths = cellfun(@(idx,s) ...
    text(idx, ax.YLim(2)*0.9, s, 'HorizontalAlignment','center','FontSize',7),...
    x, sigstr, 'UniformOutput', false);
