%%

fDir = autoDir;

%%

groups = [{{'circling';'right_bias'};{'speed';'nTrials'};{'clumpiness'};{'switchiness'};...
    {'Circadian'}}; unique(arrayfun(@(d) d.name, dec, 'UniformOutput', false));...
    arrayfun(@(i) sprintf('(%i)',i), unique(cat(1,circ.day)), 'UniformOutput', false)];

%%

for i=1:numel(groups)
    
    [f, fidx] = groupFields(dFields,groups{i});
    grp_mat = dMat(:,fidx);
    grp_label = groups{i};
    if iscell(grp_label)
        grp_label = grp_label{1};
    end
    plotCorr(grp_mat,'Labels',f,'SavePath',[fDir '\' grp_label],...
        'Title',grp_label);
end