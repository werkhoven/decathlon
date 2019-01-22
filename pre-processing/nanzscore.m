function [norm] = nanzscore(raw)


raw=num2cell(raw,1);
norm = arrayfun(@nanz,raw,'UniformOutput',false);
norm = cell2mat(norm);



function n = nanz(r)

    n=r{:};
    mu = nanmean(n);
    sig = nanstd(n);
    n(~isnan(n))= (n(~isnan(n))-mu)./sig;