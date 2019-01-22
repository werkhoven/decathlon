% This script pools data from multiple optomotor expmt data structs (pooled
% together as output from extractField_multiFile with fields: sdist, tdist,
% and n. After the data is pooled, it is bootstrap resampled.
% extract only active animals

[out,labelNames]=extractField_multiFile('Optomotor');

%%
nmax=NaN(length(out),1);
nactive=0;
for i=1:length(out)
    nmax(i) = max(out(i).Optomotor.n);
    active = out(i).Optomotor.n > 40;
    nactive = nactive + sum(active);
end
nmax=max(nmax);

dat.Optomotor.sdist = NaN(nmax,nactive);
dat.Optomotor.tdist = NaN(nmax,nactive);
dat.Optomotor.n = NaN(nactive,1);
dat.Optomotor.index = NaN(nactive,1);
ct=0;

for i=1:length(out)
    
    n = out(i).Optomotor.n;
    active = n > 40;
    n=n(active);
    
    sd = out(i).Optomotor.sdist(:,active);
    td = out(i).Optomotor.tdist(:,active);
    index = nansum(sd) ./ nansum(td);
    dat.Optomotor.sdist(1:size(sd,1),ct+1:ct + sum(active)) = sd;
    dat.Optomotor.tdist(1:size(sd,1),ct+1:ct + sum(active)) = td;
    dat.Optomotor.n(ct+1:ct + sum(active)) = n;
    dat.Optomotor.index(ct+1:ct + sum(active)) = index;
    
    ct = ct + sum(active);
    
end

%%
bootstrap_optomotor(dat,200,'Optomotor');