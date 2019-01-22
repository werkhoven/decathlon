function [corrMat,p_values,activityLevel,data]=decInterExpCorr_multiFile(field,varargin)

% This function calculates the correlation in turn or light choice
% probability over the interval (in minutes) specified in the input

plots=[];
keyarg={};

for i=1:length(varargin)
    
    arg=varargin{i};
    
    if ischar(arg)
        switch arg
            case 'Subfield'
                i=i+1;
                subfield = varargin{i};
            case 'Plots'
                i=i+1;
                plots = varargin{i};
            case 'Keyword'
                i=i+1;
                keyarg={'keyword';varargin{i}};
        end
    end
end

%% Get paths to data files

[fDir] = uigetdir('C:\Users\debivort\Documents\MATLAB\Decathlon Raw Data',...
    'Select directory containing expmt structs to be analyzed');

fPaths = getHiddenMatDir(fDir,keyarg{:});
fDir=cell(size(fPaths));
for j=1:length(fPaths)
    [tmp_dir,~,~]=fileparts(fPaths{j});
    fDir(j) = {[tmp_dir '\']};
end

%%

load(fPaths{1});                                    % Load data struct
tmp_data=expmt.(field);                             % Data specified in field

if exist('subfield','var')
    tmp_data = tmp_data.(subfield);
end

numdim = sum(size(tmp_data)>1);
id_dim = find(size(tmp_data) == expmt.nTracks);
data_dim = find(size(tmp_data) ~= expmt.nTracks);
data_sz = size(tmp_data,data_dim);

data=NaN(length(fPaths)*data_sz,expmt.nTracks*length(fPaths));
activityLevel=NaN(length(fPaths),expmt.nTracks*length(fPaths));
numActive=zeros(length(fPaths),1);
allIDs=[];
time = NaN(length(fPaths),1);
box = NaN(length(fPaths),1);
unsorted_data = NaN(length(fPaths),200);
unsorted_activity = NaN(length(fPaths),200);
unsorted_nTrials = NaN(length(fPaths),200);
group = NaN(length(fPaths),1);
days = NaN(length(fPaths),1);


for j=1:length(fPaths)
    
    load(fPaths{j});                                    % Load data struct
    tmp_data=expmt.(field);                             % Data specified in field
    
    if exist('subfield','var')
        tmp_data = tmp_data.(subfield);
    end

    % Parse out thresholds for different experiment and parameter types
    
    switch expmt.Name
        case 'Optomotor'
            active=expmt.(field).active;
            activity = nanmean(expmt.Speed.data);
            unsorted_activity(j,1:length(activity)) = activity;
            unsorted_nTrials(j,1:length(expmt.Optomotor.n)) = expmt.Optomotor.n;
        case 'LED Y-maze'
            active=expmt.(field).active;
            active=expmt.(field).n > 40;
            activity = expmt.(field).n;
            unsorted_activity(j,1:length(activity)) = activity;
            unsorted_nTrials(j,1:length(expmt.(field).n)) = expmt.(field).n;
        case 'Circadian'
            active=nanmean(expmt.Speed.data)>0.1;
            activity=expmt.Circadian.avg;   
        case 'Slow Phototaxis'
            active=expmt.Light.active;
            activity = nansum(cell2mat(expmt.Light.tInc));
            unsorted_activity(j,1:length(activity)) = activity;
        case 'Gravitaxis'
            active=expmt.Gravity.nApproach > 9;
            activity = expmt.Gravity.nApproach;
            unsorted_activity(j,1:length(activity)) = activity;
        case 'Arena Circling'
            active = expmt.Speed.avg > 0.001;
            activity = expmt.Speed.avg;
            unsorted_activity(j,1:length(activity)) = activity;
        case 'Basic Tracking'
            active = expmt.Speed.avg > 0.001;
            activity = expmt.Speed.avg;
            unsorted_activity(j,1:length(activity)) = activity;
        case 'Temporal Phototaxis'
            active = expmt.Speed.avg > 0.01;
            activity = expmt.Speed.avg;
            unsorted_activity(j,1:length(activity)) = activity;
    end
    
    if any(active)
        
        %tmp_data=tmp_data-nanmean(tmp_data(:));
    
        % Parse out strain, treatment, day, and ID numbers
        if isfield(expmt,'Strain')
            strain=expmt.Strain;
        else
            strain='';
        end
        if isfield(expmt,'Treatment')
            treatment=expmt.Treatment;
        else
            treatment='';
        end
        if any(strcmp(expmt.labels_table.Properties.VariableNames,'ID'))
            IDs=expmt.labels_table(:,strcmp(expmt.labels_table.Properties.VariableNames,'ID'));
            IDs=IDs{:,:};
            lastID = IDs(end);
            switch lastID
                case 48
                    group(j)=1;
                case 96
                    group(j)=2;
                case 144
                    group(j)=3;
                case 192
                    group(j)=4;
            end
        end

        if any(strcmp(expmt.labels_table.Properties.VariableNames,'Day'))
            Day=expmt.labels_table(:,strcmp(expmt.labels_table.Properties.VariableNames,'Day'));
            Day=Day{:,:};
            Day=Day(active);
            days(j) = Day(1);
        end

        if any(strcmp(expmt.labels_table.Properties.VariableNames,'Box'))
            b=expmt.labels_table(1,strcmp(expmt.labels_table.Properties.VariableNames,'Box'));
            box(j) = b{:,:};
        end

        % get experiment time of day and convert to hours
        if isfield(expmt,'date')
            date = expmt.date(12:19);
            h = str2double(date(1:2));
            m = str2double(date(4:5))/60;
            s = str2double(date(7:8))/3600;
            time(j) = h + m + s;
        end

        switch numdim
            case 1
                unsorted_data(j,1:length(tmp_data)) = tmp_data;
            case 2
                start = (j-1)*data_sz+1;
                stop = j*data_sz;
                unsorted_data(start:stop,1:size(tmp_data,id_dim)) = tmp_data;
        end

        % Record data to placeholder by day and ID number
        activeIDs=IDs(active);
        Day(isnan(Day))=[];
        unique_Days=unique(Day);
        IDs=IDs(~isnan(IDs));

        switch numdim
            case 1
                tmp_data=tmp_data(active);
                
            case 2
                tmp_data=tmp_data(:,active);
        end

        for i=1:length(unique_Days)

            switch numdim
                case 1
                    data(unique_Days(i),activeIDs)=tmp_data(Day==unique_Days(i));
                case 2
                    start = (unique_Days(i)-1)*data_sz+1;
                    stop = unique_Days(i)*data_sz;
                    data(start:stop,activeIDs)=tmp_data(:,Day==unique_Days(i));
            end
            activityLevel(unique_Days(i),activeIDs)=activity(active);
            
            if unique_Days(i) <= length(numActive)
                numActive(unique_Days(i))=numActive(unique_Days(i))+sum(active);
            else
                numActive = [numActive; zeros(unique_Days(i)-length(numActive),1)];
                numActive(unique_Days(i))=numActive(unique_Days(i))+sum(active);
            end
        end

        if diff(size(IDs))<0
            IDs = IDs';
        end
        allIDs = [allIDs IDs];
        
    end
    
    clearvars expmt
    disp([num2str(j) ' out of ' num2str(length(fPaths)) ' complete'])
    

end

allIDs=allIDs(:);
allIDs = unique(allIDs);
dRaw = data;



%% time of day effects

if any(strcmp('timeofday',plots))
    
    u = nanmean(unsorted_data,2);
    uspd = nanmean(unsorted_activity,2);
    utrial = nanmean(unsorted_nTrials,2);
    stds = nanstd(unsorted_data,[],2);
    dim1 = 2;                               %subplot dimensions
    dim2 = 2;
    k = 0;                                  % current subplot panel num

    figure();
    % mean phenotype v. time of day
    k=k+1;
    subplot(dim1,dim2,k);
    d1 = time;
    d2 = u;
    c = 'r';
    scatter(d1,d2,'Linewidth',1.5,'MarkerEdgeColor',c);
    [r,p]=corrcoef([d1 d2],'rows','pairwise');
    xlabel('time of day');
    ylabel('grp mean ooccupancy score');
    title(['r=' num2str(round(r(1,2)*100)/100) '  (p=' num2str(round(p(1,2)*100)/100) ')']);

    % std dev v. time of day
    k=k+1;
    subplot(dim1,dim2,k);
    d1 = time;
    d2 = stds;
    c = 'm';
    scatter(d1,d2,'Linewidth',1.5,'MarkerEdgeColor',c);
    [r,p]=corrcoef([d1 d2],'rows','pairwise');
    xlabel('time of day');
    ylabel('grp std dev');
    title(['r=' num2str(round(r(1,2)*100)/100) '  (p=' num2str(round(p(1,2)*100)/100) ')']);

    % mean activity v. time of day
    k=k+1;
    subplot(dim1,dim2,k);
    d1 = time;
    d2 = uspd;
    c = 'c';
    scatter(d1,d2,'Linewidth',1.5,'MarkerEdgeColor',c);
    [r,p]=corrcoef([d1 d2],'rows','pairwise');
    xlabel('time of day');
    ylabel('grp mean spd');
    title(['r=' num2str(round(r(1,2)*100)/100) '  (p=' num2str(round(p(1,2)*100)/100) ')']);

    % mean activity v. time of day
    k=k+1;
    subplot(dim1,dim2,k);
    d1 = time;
    d2 = utrial;
    c = 'g';
    scatter(d1,d2,'Linewidth',1.5,'MarkerEdgeColor',c);
    [r,p]=corrcoef([d1 d2],'rows','pairwise');
    xlabel('time of day');
    ylabel('grp mean trial#');
    title(['r=' num2str(round(r(1,2)*100)/100) '  (p=' num2str(round(p(1,2)*100)/100) ')']);

    % create main title
    mtit('Time of day effect');

end


%% plot values by box and by group

if any(strcmp(plots,'Box')) || any(strcmp(plots,'Group'))

figure();
dim1=3;
dim2=2;
groups = unique(group);
boxes = unique(box);

% Srted by box number
subplot(dim1,dim2,1);
plot_dat_pheno = [];
plot_dat_act = [];
plot_dat_nTrials = [];
label_names = {};

for i=1:length(boxes)
    
    idx = find(box==boxes(i));
    [v,p]=sort(group(idx));
    
    dat_sorted = unsorted_data(idx(p),:);
    plot_dat_pheno = [plot_dat_pheno;dat_sorted];
    dat_sorted = unsorted_activity(idx(p),:);
    plot_dat_act = [plot_dat_act;dat_sorted];
    dat_sorted = unsorted_nTrials(idx(p),:);
    plot_dat_nTrials = [plot_dat_nTrials;dat_sorted];
    
    for j=1:length(idx)
        label_names = [label_names {['B' num2str(boxes(i)) '-G' num2str(v(j))]}];
    end
end

boxplot(plot_dat_pheno','Notch','on','PlotStyle','compact');
title('sorted by box');
ylabel('opto score');
set(gca,'XTickLabel',{''});
subplot(dim1,dim2,3);
boxplot(plot_dat_act','Notch','on','PlotStyle','compact');
ylabel('mean spd');
set(gca,'XTickLabel',{''});
subplot(dim1,dim2,5);
boxplot(plot_dat_nTrials','Notch','on','Labels',label_names,'PlotStyle','compact');
ylabel('trial number');



% sorted by group number
subplot(dim1,dim2,2);
plot_dat_pheno = [];
plot_dat_act = [];
plot_dat_nTrials = [];
label_names = {};

for i=1:length(groups)
    
    idx = find(group==groups(i));
    [v,p]=sort(box(idx));
    
    dat_sorted = unsorted_data(idx(p),:);
    plot_dat_pheno = [plot_dat_pheno;dat_sorted];
    dat_sorted = unsorted_activity(idx(p),:);
    plot_dat_act = [plot_dat_act;dat_sorted];
    dat_sorted = unsorted_nTrials(idx(p),:);
    plot_dat_nTrials = [plot_dat_nTrials;dat_sorted];
    
    for j=1:length(idx)
        label_names = [label_names {['G' num2str(groups(i)) '-B' num2str(v(j))]}];
    end
end


boxplot(plot_dat_pheno','Notch','on','PlotStyle','compact');
a1=gca;
title('sorted by group');
ylabel('opto score');
set(gca,'XTickLabel',{''});
subplot(dim1,dim2,4);
boxplot(plot_dat_act','Notch','on','PlotStyle','compact');
a2=gca;
ylabel('mean spd');
set(gca,'XTickLabel',{''});
subplot(dim1,dim2,6);
boxplot(plot_dat_nTrials','Notch','on','Labels',label_names,'PlotStyle','compact');
ylabel('trial number');
a2.Position([1 3]) = a1.Position([1 3]);

end

%% look at combined box and group data sets

if any(strcmp(plots,'Box')) || any(strcmp(plots,'Group'))

figure();
subplot(2,1,1);
data_by_box = NaN(1000,length(boxes));
label_names = cell(length(boxes),1);
for i=1:length(boxes)
    tmp = unsorted_data(box==boxes(i),:);
    tmp = tmp(~isnan(tmp));
    data_by_box(1:length(tmp),i) = tmp;
    label_names(i) = {['Box ' num2str(boxes(i))]};
end
boxplot(data_by_box,'Notch','on','Labels',label_names);
ylabel('optomotor score');

subplot(2,1,2);

data_by_grp = NaN(1000,length(groups));
label_names = cell(length(groups),1);
for i=1:length(groups)
    tmp = unsorted_data(group==groups(i),:);
    tmp = tmp(~isnan(tmp));
    data_by_grp(1:length(tmp),i) = tmp;
    label_names(i) = {['Group ' num2str(groups(i))]};
end
boxplot(data_by_grp,'Notch','on','Labels',label_names);
ylabel('optomotor score');
mtit('combined box and group data');

end

%% Create scatter plots of data on each day color-coded by group

if any(strcmp(plots,'Scatter'))

f=figure();
groups = unique(group);
boxes = unique(box);
uday = unique(days);
ndays = length(uday);
cm='rbgmcy';
ulim = max(max(unsorted_data))*1.1;
llim = min(min(unsorted_data))*1.1;
legendlabels = cell(length(groups),1);

for i=1:ndays
    for j=i+1:ndays
        
        subplot(ndays-1,ndays-1,(ndays-1)*(i-1)+j-1);
        d1_idx = find(days==uday(i));
        [v,p]=sort(group(d1_idx));
        d1_idx = d1_idx(p);
        d2_idx = find(days==uday(j));
        [v,p]=sort(group(d2_idx));
        d2_idx = d2_idx(p);
        
        hold on
        for k=1:length(d1_idx)
            scatter(unsorted_data(d2_idx(k),:),unsorted_data(d1_idx(k),:),...
                'MarkerEdgeColor',cm(k),'Linewidth',2,'Marker','.');
            xlabel(['day' num2str(uday(j))]);
            ylabel(['day' num2str(uday(i))]);
            set(gca,'Xlim',[llim ulim],'Ylim',[llim ulim]);
        end
        hold off
        
    end
    if i==1
        ahs=f.Children;
        b=reshape([ahs(:).Position],4,length(ahs))';
        w = b(1,3);
        b(:,[3 4])=[sum(b(:,[1 3]),2) sum(b(:,[2 4]),2)];
        leftedge = min(b(:,1));
        rightedge = max(b(:,3));
        top = max(b(:,4))*1.01;
        x = linspace(leftedge+w/2,rightedge-w/2,length(groups));
        y = repmat(top,1,length(groups));
        for k=1:length(d1_idx)
            ll(k) = uicontrol('style','text','String',['group ' num2str(k)],...
                'Units','normalized','HorizontalAlignment','left','Parent',f,...
                'ForegroundColor',cm(k),'FontSize',10);
            ll(k).Position([1 2]) = [x(k) y(k)];
        end
    end       
end

end

%% plot trial number by box and group

if any(strcmp(plots,'TrialNumber'))
    
    figure();
    dim1=2;
    dim2=1;
    subplot(dim1,dim2,1);
    plot_dat = [];
    label_names = {};
    for i=1:length(boxes)
        idx = find(box==boxes(i));
        [v,p]=sort(days(idx));
        dat_sorted = unsorted_nTrials(idx(p),:);
        plot_dat = [plot_dat;dat_sorted];
        for j=1:length(idx)
            label_names = [label_names {['B' num2str(boxes(i)) '-D' num2str(v(j))]}];
        end
    end
    boxplot(plot_dat','Notch','on','Labels',label_names,'PlotStyle','compact');
    ylabel('trial number');

    % plot trial number box plots by group number across days
    subplot(dim1,dim2,2);
    groups = unique(group);
    plot_dat = [];
    label_names = {};
    for i=1:length(groups)
        idx = find(group==groups(i));
        [v,p]=sort(days(idx));
        dat_sorted = unsorted_nTrials(idx(p),:);
        plot_dat = [plot_dat;dat_sorted];
        for j=1:length(idx)
            label_names = [label_names {['G' num2str(groups(i)) '-D' num2str(v(j))]}];
        end
    end
    boxplot(plot_dat','Notch','on','Labels',label_names,'PlotStyle','compact');
    ylabel('trial number');


end

%% plot phenotype box plots by group number across days

if any(strcmp(plots,'Group'))

    figure();
    dim1=3;
    dim2=1;
    subplot(dim1,dim2,1);
    plot_dat = [];
    label_names = {};
    for i=1:length(boxes)
        idx = find(box==boxes(i));
        [v,p]=sort(days(idx));
        dat_sorted = unsorted_data(idx(p),:);
        plot_dat = [plot_dat;dat_sorted];
        for j=1:length(idx)
            label_names = [label_names {['B' num2str(boxes(i)) '-D' num2str(v(j))]}];
        end
    end
    boxplot(plot_dat','Notch','on','Labels',label_names,'PlotStyle','compact');
    ylabel('optomotor score');

    % plot activity box plots by group number across days
    subplot(dim1,dim2,2);
    groups = unique(group);
    plot_dat = [];
    label_names = {};
    for i=1:length(groups)
        idx = find(group==groups(i));
        [v,p]=sort(days(idx));
        dat_sorted = unsorted_data(idx(p),:);
        plot_dat = [plot_dat;dat_sorted];
        for j=1:length(idx)
            label_names = [label_names {['G' num2str(groups(i)) '-D' num2str(v(j))]}];
        end
    end
    boxplot(plot_dat','Notch','on','Labels',label_names,'PlotStyle','compact');
    ylabel('optomotor score');

    % plot activity box plots by group number across days
    subplot(dim1,dim2,3);
    groups = unique(group);
    plot_dat = [];
    label_names = {};
    for i=1:length(groups)
        idx = find(group==groups(i));
        [v,p]=sort(box(idx));
        dat_sorted = unsorted_data(idx(p),:);
        plot_dat = [plot_dat;dat_sorted];
        for j=1:length(idx)
            label_names = [label_names {['G' num2str(groups(i)) '-B' num2str(v(j))]}];
        end
    end
    boxplot(plot_dat','Notch','on','Labels',label_names,'PlotStyle','compact');
    ylabel('optomotor score');
    %}

end


%%
% Calculate MAD
MAD=NaN(size(data,1),1);
for i=1:size(data,1)
    MAD(i)=mad(data(i,~isnan(data(i,:))));
end
plot(MAD,'ro');



%%
% Delete empty rows and columns
%delRows = find(any(~isnan(data),2),1,'last') + 1;
%data(delRows:end,:)=[];
delRows=sum(~isnan(data),2)<1;
data(delRows,:)=[];
emptyCols=sum(~isnan(data),1)<1;
data(:,emptyCols)=[];
activityLevel(sum(~isnan(activityLevel),2)<1,:)=[];
activityLevel(:,sum(~isnan(activityLevel),1)<1)=[];

% sort circadian 
perm=[];
if strcmp(field,'Circadian') && data_sz == 24
    for i=1:24
        t=i;
        if t==24
            t=0;
        end
        perm = [perm find(mod(1:size(data,1),24)==t)];        
    end
    data=data(perm,:);
    data(isnan(data))=0;
end

%% 

%data(:,any(isnan(data)))=[];

%%
figure();
subplot(2,1,1);
fsz = 11;
[corrMat,p_values]=corrcoef(data','rows','pairwise');
[activityCorr,act_p_values]=corrcoef(activityLevel','rows','pairwise');
imagesc(corrMat)
egoalley=interp1([1 52 128 129 164 225 256],...
    [0 1 1; 0 .2 1; 0 .0392 .1961; .1639 .0164 0 ; 1 .1 0; 1 .9 0; 1 1 1],1:256);
colormap(egoalley);
colorbar
caxis([-1,1])
title(['Inter-experiment correlation: ',strain,' ',treatment,' ',field,' (n=',num2str(size(data,2)),')']);

if strcmp(field,'Circadian') && data_sz == 24
    
    % draw lines blocking off hour groupings
    hold on
    stp=size(data,1)/24;
    for i=1:23
        plot([0 length(corrMat)],[i*stp+0.5 i*stp+0.5],'k','Linewidth',1.5);
        plot([i*stp+0.5 i*stp+0.5],[0 length(corrMat)],'k','Linewidth',1.5);
    end
    set(gca,'Xtick',stp/2:stp:size(data,1),'XTickLabel',0:23);   
    set(gca,'Ytick',stp/2:stp:size(data,1),'YTickLabel',0:23);   
    xlabel('Time of day (0:00-23:00)');
    ylabel('Time of day (0:00-23:00)');

else
    
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

end

subplot(2,1,2)
imagesc(activityCorr)
colormap(egoalley);
colorbar
caxis([-1,1])
title(['Inter-experiment correlation: ',strain,' ',treatment,' ','activity',' (n=',num2str(size(data,2)),')']);
set(gca,'Xtick',1:size(data,1),'Ytick',1:size(data,1),'FontSize',fsz);

hold on
for i=1:size(activityCorr,1)
    for j=1:size(activityCorr,2)
        if i~=j
            text(i,j-0.2,num2str(activityCorr(i,j),2),...
                'HorizontalAlignment','center','FontSize',5,'FontUnits','normalized')
            text(i,j+0.2,['(p=' num2str(act_p_values(i,j),'%2.1e') ')'],...
                'HorizontalAlignment','center','FontSize',5,'FontUnits','normalized');
        end
    end
end
hold off
set(gca,'fontsize', fsz);
%%
figure();
%numActive(numActive<1)=[];
numActive(numActive==0)=[];
nact=numActive./length(allIDs);
plot(nact,'Linewidth',2);
title([field ' Num. Flies above Choice Number Threshold'])
axis([1 length(numActive) 0 1])
xlabel('day of testing');
ylabel('fraction of population');

    
shg