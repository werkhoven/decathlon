% get circadian data

[out,labelNames]=extractField_multiFile({'Circadian';'labels_table'},'Keyword','Circadian');

%% query max no. data pts per trial and total trial no. per individual
nTrials = 0;
nPts = 0;
ids = [];
days = [];
for i = 1:length(out)
    
    if out(i).labels_table.ID(1) == 1      
        nTrials = nTrials + size(out(i).Circadian.motor.bouts,3);
    end
    
    if length(out(i).Circadian.motor.bouts) > nPts
        nPts = length(out(i).Circadian.motor.bouts);
    end
    
    ids = unique([ids;out(i).labels_table.ID]);
    days = unique([days;out(i).labels_table.Day]);
end

%% collect data into matrix

d = NaN(nPts,length(ids),nTrials);
tCt = zeros(length(ids),1);

for i = 1:length(out)
    
    nt = size(out(i).Circadian.motor.bouts,3);
    ids = out(i).labels_table.ID;
    t = tCt(out(i).labels_table.ID(1))+1;
    d(:,ids,t:t+nt-1) = out(i).Circadian.motor.bouts;
    tCt(out(i).labels_table.ID) = tCt(out(i).labels_table.ID) + nt;
    
end

dmu = nanmean(d,3);
clearvars d

%% sub sample data to reduce noise

fac = 5;
smp = mod(1:nPts,fac)==0;
dmu = dmu(smp,:);
dsmooth = NaN(size(dmu));
for i = 1:size(dmu,2)
    
    dsmooth(:,i) = smooth(dmu(:,i),20);

end

t0 = round(length(dmu));
baseline = nanmean(dmu(1:t0-1,:));
stmspd = nanmean(dmu(t0:end,:));
response = stmspd./baseline;
response(response==Inf)=NaN;
expmt.Circadian.motor.response = response;
expmt.Circadian.motor.baseline = baseline;
expmt.Circadian.motor.stimspd = stmspd;

% pick save directory
[fDir] = uigetdir('C:\Users\debivort\Documents\MATLAB\Decathlon Raw Data',...
    'Select directory containing expmt structs to be analyzed');
save([expmt.fdir expmt.fLabel],'expmt');

%% collect data into matrix

d = NaN(nPts,length(ids),length(days));
s = NaN(length(days),length(ids));

for i = 1:length(out)
    
    nt = size(out(i).Circadian.motor.bouts,3);
    ids = out(i).labels_table.ID;
    tmp_day = out(i).labels_table.Day(1);
    d(:,ids,tmp_day) = nanmean(out(i).Circadian.motor.bouts,3);
    s(tmp_day,ids) = out(i).Circadian.avg;
    
end


%% sub sample data to reduce noise

fac = 5;
smp = mod(1:nPts,fac)==0;
d = d(smp,:,:);
t0 = round(length(d)/2);
baseline = squeeze(nanmean(d(1:t0-1,:,:)));
stmspd = squeeze(nanmean(d(t0:end,:,:)));
data = stmspd./baseline;
data(data==Inf)=NaN;
metrics = [data s'];
for i = 1:size(metrics,2)
    metrics(:,i) = (metrics(:,i) - nanmean(metrics(:,i)))./nanstd(metrics(:,i));
end

[corrMat,p_values] = corrcoef([data s'],'rows','pairwise');

%%

imagesc(corrMat)
egoalley=interp1([1 52 128 129 164 225 256],...
    [0 1 1; 0 .2 1; 0 .0392 .1961; .1639 .0164 0 ; 1 .1 0; 1 .9 0; 1 1 1],1:256);
colormap(egoalley);
colorbar
caxis([-1,1])

hold on
set(gca,'Xtick',1:size(data,1),'Ytick',1:size(data,1),'FontSize',fsz);
for i=1:size(corrMat,1)
    for j=1:size(corrMat,2)
        if i~=j
            text(i,j-0.2,num2str(corrMat(i,j),2),...
                'HorizontalAlignment','center','FontSize',5,'FontUnits','normalized')
            text(i,j+0.2,['(p=' num2str(p_values(i,j),'%2.1e') ')'],...
                'HorizontalAlignment','center','FontSize',5,'FontUnits','normalized');
        end
    end
end
hold off
set(gca,'fontsize', fsz);
