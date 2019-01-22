%% get data

[pooldat,labelNames]=extractField_multiFile({'Circadian';'Circaidan';'labels_table'});

%{
for i = 1:length(pooldat)
    pooldat(i).Circadian.id_trace.t = pooldat(i).Circaidan.id_trace.t;
    pooldat(i).Circadian.id_trace.break = pooldat(i).Circaidan.id_trace.break;
end
%}

%%


npts=0;         % get the maximum number of points in any trace
ids=[];         % get number of flies and ids
days=[];
for i = 1:length(pooldat)
    
    tmp = size(pooldat(i).Circadian.id_trace.data,1);
    if tmp > npts
        npts=tmp;
    end
    
    ids = unique([ids pooldat(i).labels_table.ID']);
    days = unique([days pooldat(i).labels_table.Day(1)]);
    
end


%% 

npts = 2500;
nf = numel(ids);
nd = numel(days);
interpdat = NaN(npts,nf,nd);
interptime = NaN(npts,nd);

for i=1:length(pooldat)
    
    % get trace data
    tmp = pooldat(i).Circadian.id_trace.data;
    act = pooldat(i).Circadian.avg > 0.1;
    tmp(:,~act) = NaN;
    t = pooldat(i).Circadian.id_trace.t;
    
    % query fly ids and day number
    ids = pooldat(i).labels_table.ID;
    day = pooldat(i).labels_table.Day(1);
    
    % interpolate trace and time data
    
    tmp_t = interp1(1:length(tmp),t,linspace(1,length(tmp),npts));
    interptime(:,day) = tmp_t;
    dt = [0 diff(tmp_t)] > median(diff(tmp_t))*3;
    dat = interp1(t,tmp,linspace(0,24*3600,npts));
    dat(dt,:)=NaN;
    interpdat(:,ids,day) = dat;
    
    
end

%%

ppa = 48;                           % plots per axes
apf = 4;                            % axes per figure
nrows = floor(sqrt(apf));
ncols = ceil(apf/nrows);
axnum=0;

mu = nanmean(interpdat,3);          % mean activity trace for each individual across days
t_mu = linspace(0,24*3600,npts);
[~,breaks]=max(diff(mu));           % breakpoints in traces

figure();

for i=1:nf
    
    if mod(i,ppa)==1
        axnum = axnum+1
        if axnum > apf
            figure();
            axnum=1;
        end
        subplot(ncols,nrows,axnum);
    end
    hold on
    plot(t_mu,smooth(mu(:,i),250));
    hold off
    
end

set(findobj('Type','axes'),'YLim',[0 max(mu(:))*0.5]);

    