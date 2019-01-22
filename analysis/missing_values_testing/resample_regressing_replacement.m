
d2=d;
labels = D12copy.fields;
n = sum(isnan(d2));
d2(:,n>150)=[];
labels(n>150)=[];
rows = any(isnan(d2),2);
a=d2(~rows,:);

%%

nReps = 1000;
rvals = NaN(nReps,size(a,2));
nWithheld = 0.5;
nWithheld = ceil(size(a,1)*nWithheld);

for i=1:nReps
    
    disp(i);
    withheld = arrayfun(@(c) [randperm(size(a,1),nWithheld)' ...
        repmat(c,nWithheld,1)],1:size(a,2),'UniformOutput',false);
    true_val = cellfun(@(x) a(x(:,1),x(1,2)),withheld,'UniformOutput',false);
    tmp = a;
    linIdx = cat(1,withheld{:});
    linIdx = sub2ind(size(a),linIdx(:,1),linIdx(:,2));
    tmp(linIdx)=NaN;
    tmp = fillWithRegressedValues(tmp);
    regressed_val = cellfun(@(x) tmp(x(:,1),x(1,2)),withheld,'UniformOutput',false);
    r = cellfun(@(x,y) corrcoef([x y],'rows','pairwise'),...
        true_val,regressed_val,'UniformOutput',false);
    r = cellfun(@(x) x(1,2),r);
    rvals(i,:)=r;
    
end

%% plot r-values separately

boxplot(rvals,'Notch','on','Orientation','horizontal','Labels',labels,'Whisker',0,'Symbol','');
title('regression resampling - r-value distributions');
hold on
ah=gca;
lh=plot([0 0],[ah.YLim(1) ah.YLim(2)],'k--','Linewidth',1);
uistack(lh,'down');
axis([0 1 0 size(data',2)+1])