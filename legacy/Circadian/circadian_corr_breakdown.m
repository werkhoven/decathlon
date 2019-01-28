%%

fDir = autoDir;
fPaths = recursiveSearch(fDir,'keyword','Circadian');
data = NaN(24*10,192);
fprintf('\n')
for i=1:numel(fPaths)
   fprintf('loading file %i of %i\n',i,numel(fPaths))
   load(fPaths{i});
   day = expmt.meta.labels_table.Day(1);
   ids = expmt.meta.labels_table.ID;
   idx = day*(i-1)+1:day*(i-1)+24;
   spd = expmt.meta.Circadian.avg_spd;
   spd(expmt.meta.Circadian.avg > 0.1) = NaN;
   data(idx,ids) = spd;
end

days = 1:10;

%% z-score data to normalize

data = nanzscore(data');
data = data';

%% plot raw data

figure();imagesc(data);

hold on
stp=24;
label=cell(size(data,1)/stp,1);
for i = 1:size(data,1)/stp
    plot([0.5 size(data,2)],[stp*i+0.5 stp*i+0.5],'k','Linewidth',2);
    label(i)={['Day ' num2str(i)]};
end
set(gca,'YTick',stp/2+0.5:stp:size(data,1),'YTickLabel',label);
title('Raw speed data');
xlabel('individual flies');


%% plot correlation matrix sorted by day of testing

strain = expmt.meta.Strain;
treatment = expmt.meta.Treatment;
field = 'Speed';
figure();
fsz = 12;
[corrMat,p_values]=corrcoef(data','rows','pairwise');
del = ~any(~isnan(corrMat));
stp = cumsum(sum(reshape(~del,length(del)/length(unique(days)),length(unique(days)))));
corrMat(del,:)=[];
corrMat(:,del)=[];
corrMat(isnan(corrMat))=0;
imagesc(corrMat)
nanticoke=interp1([1 52 128 164 225 255 256],[0 1 1; 0 .2 1; 0 0 0; 1 .1 0; 1 .5 0; 1 1 0; 1 1 1],1:256);
colormap(nanticoke);
colorbar
caxis([-1,1])
title(['Inter-experiment correlation: ',strain,' ',treatment,' ',field,' (n=',num2str(size(data,2)),')']);


%% draw lines blocking off hour groupings

% draw lines blocking off hour groupings
hold on
for i=1:length(unique(days))
    plot([0 length(corrMat)],[stp(i)+0.5 stp(i)+0.5],'k','Linewidth',1.5);
    plot([stp(i)+0.5 stp(i)+0.5],[0 length(corrMat)],'k','Linewidth',1.5);
end
tickmarks = stp-(diff([0 stp])./2);
set(gca,'Xtick',tickmarks,'XTickLabel',0:23);   
set(gca,'Ytick',tickmarks,'YTickLabel',0:23);   
xlabel('Day of testing');
ylabel('Day of Testing');
%{
hold on
stp=24;
for i=1:8
    plot([0 length(corrMat)],[i*stp+0.5 i*stp+0.5],'k','Linewidth',1.5);
    plot([i*stp+0.5 i*stp+0.5],[0 length(corrMat)],'k','Linewidth',1.5);
end
set(gca,'Xtick',stp/2:stp:size(data,1),'XTickLabel',0:23);   
set(gca,'Ytick',stp/2:stp:size(data,1),'YTickLabel',0:23);   
%}

%% sort rows by time of day
perm=[];

for i=1:24
    t=i;
    if t==24
        t=0;
    end
    perm = [perm find(mod(1:size(data,1),24)==t)];        
end
data=data(perm,:);


%% plot raw data sorted by time of day

figure();imagesc(data);

hold on
stp=length(unique(days));
label=cell(size(data,1)/stp,1);
for i = 1:size(data,1)/stp
    plot([0.5 size(data,2)],[stp*i+0.5 stp*i+0.5],'k','Linewidth',2);
    label(i)={[num2str(i-1) ':00']};
end
set(gca,'YTick',stp/2+0.5:stp:size(data,1),'YTickLabel',label);
title('Raw speed data - time of day sorted');
xlabel('individual flies');

%% plot sorted by time of day

figure();
fsz = 12;
[corrMat,p_values]=corrcoef(data','rows','pairwise');
del = ~any(~isnan(corrMat));
stp = cumsum(sum(reshape(~del,length(del)/24,24)));
corrMat(del,:)=[];
corrMat(:,del)=[];
corrMat(isnan(corrMat))=0;
imagesc(corrMat)
nanticoke=interp1([1 52 128 164 225 255 256],[0 1 1; 0 .2 1; 0 0 0; 1 .1 0; 1 .5 0; 1 1 0; 1 1 1],1:256);
colormap(nanticoke);
colorbar
caxis([-1,1])
title(['Inter-experiment correlation: ',strain,' ',treatment,' ',field,' (n=',num2str(size(data,2)),')']);

    
% draw lines blocking off hour groupings
hold on
for i=1:23
    plot([0 length(corrMat)],[stp(i)+0.5 stp(i)+0.5],'k','Linewidth',1.5);
    plot([stp(i)+0.5 stp(i)+0.5],[0 length(corrMat)],'k','Linewidth',1.5);
end
tickmarks = stp-(diff([0 stp])./2);
set(gca,'Xtick',tickmarks,'XTickLabel',0:23);   
set(gca,'Ytick',tickmarks,'YTickLabel',0:23);   
xlabel('Time of day (0:00-23:00)');
ylabel('Time of day (0:00-23:00)');