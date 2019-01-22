%% Get parent directory of all decathlon files

[fDir] = uigetdir('C:\Users\debivort\Documents\MATLAB\Decathlon Raw Data',...
    'Select directory containing expmt structs to be analyzed');

% intialize master struct for data
dec = repmat(struct('data',[],'fields',[],'name',[],'day',[],'ID',[]),11,1);
circ = repmat(struct('data',[],'fields',[],'name',[],'day',[],'ID',[]),15,1);


%%
fPaths = getHiddenMatDir(fDir);
fDir=cell(size(fPaths));
for j=1:length(fPaths)
    [tmp_dir,~,~]=fileparts(fPaths{j});
    fDir(j) = {[tmp_dir '\']};
end

%% read in files sequentially

hwb = waitbar(0,'loading files');

for j = 1:length(fPaths)
    
    hwb = waitbar(j/length(fPaths),hwb,['loading file ' num2str(j) ' of ' num2str(length(fPaths))]);
    load(fPaths{j});                    % read in expmt struct
    name = expmt.Name;                  % query expmt name
    
    switch name
        case 'Circadian'
            
            day =  expmt.labels_table.Day(1);   % query testing day
            circ(day).ID = [circ(day).ID; expmt.labels_table.ID];
            expmt.nTracks = length(expmt.labels_table.ID);
            
            % store values in decathlon data struct
            circ(day).name = name;
            circ(day).day = day;

            % extract experiment metrics
            [data,field_names] = getDataFields_allmetrics(expmt);
            circ(day).fields = field_names;

            % append metrics to values in decathlon data struct
            if isempty(circ(day).data)
                circ(day).data = data;
            else
                fn = fieldnames(data);
                for i = 1:length(fn)
                    circ(day).data.(fn{i}) = [circ(day).data.(fn{i}); data.(fn{i})];
                end
            end
            
        otherwise
            
            switch name
                case 'Olfaction'
                    day = expmt.Day;
                    dec(day).ID = [dec(day).ID; expmt.ID'];
                otherwise
                    day =  expmt.labels_table.Day(1);   % query testing day
                    dec(day).ID = [dec(day).ID; expmt.labels_table.ID];
                    expmt.nTracks = length(expmt.labels_table.ID);
            end

            % store values in decathlon data struct
            dec(day).name = name;
            dec(day).day = day;

            % extract experiment metrics
            [data,field_names] = getDataFields_allmetrics(expmt);
            dec(day).fields = field_names;

            % append metrics to values in decathlon data struct
            if isempty(dec(day).data)
                dec(day).data = data;
            else
                fn = fieldnames(data);
                for i = 1:length(fn)
                    dec(day).data.(fn{i}) = [dec(day).data.(fn{i}); data.(fn{i})];
                end
            end
            
    end
    
    
end
    
delete(hwb);
    
%% create data matrix and create labels array

% query max number of data points
nFields = 0;
for i = 1:length(dec)
    dec(i).n = length(dec(i).ID);
    nFields = nFields + length(dec(i).fields);
end

for i = 1:length(circ)
    circ(i).n = length(circ(i).ID);
    nFields = nFields + length(circ(i).fields);
end

% initialize data mat (observations x variables) 
dMat = NaN(max([dec.n circ.n]),nFields);
dFields = cell(nFields,1);
fct = 0;
nDays = max([dec.day circ.day]);

for i=1:nDays
    
    if i<=length(circ) && ~isempty(circ(i).fields)
        
        f = circ(i).fields;

        for j=1:length(f)

            fct=fct+1;
            dMat(circ(i).ID,fct) = circ(i).data.(f{j});
            dMat(circ(i).ID(~circ(i).data.filter),fct) = NaN;
            dFields(fct) = {[circ(i).name ' ' f{j} ' (' num2str(i) ')']};
        end 
    end
    
    if i<=length(dec) && ~isempty(dec(i).fields)
        
        f = dec(i).fields;

        for j=1:length(f)

            fct=fct+1;
            dMat(dec(i).ID,fct) = dec(i).data.(f{j});
            dMat(dec(i).ID(~dec(i).data.filter),fct) = NaN;
            dFields(fct) = {[dec(i).name ' ' f{j} ' (' num2str(i) ')']};
        end 
    end
    
    
end

% calculate number of samples for each pairwise comparison
n = NaN(nFields);
for i=1:nFields
    for j=1:nFields       
        if i~=j
            n(i,j) = sum(~isnan(dMat(:,i)) & ~isnan(dMat(:,j)));
        end
    end
end
        

%%

f = figure();
[r,p] = corrcoef(dMat,'rows','pairwise');
r(isnan(r))=0;
p(isnan(p))=1;
Z=linkage(r,'single','spearman');
[ZH, ZT, Zoutperm]=dendrogram(Z,length(r));
r=r(Zoutperm,Zoutperm);
p=p(Zoutperm,Zoutperm);
n=n(Zoutperm,Zoutperm);
clusteredLabels=dFields(Zoutperm);



imh = imagesc(r);
egoalley=interp1([1 52 128 129 164 225 256],...
    [0 1 1; 0 .2 1; 0 .0392 .1961; .1639 .0164 0 ; 1 .1 0; 1 .9 0; 1 1 1],1:256);
colormap(egoalley);
colorbar
caxis([-1,1]);
%{
fsz = 10;
hold on
set(gca,'Xtick',1:size(data,1),'Ytick',1:size(data,1),'FontSize',fsz);
for i=1:size(r,1)
    for j=1:size(r,2)
        if i~=j && p(i,j)<0.05
            text(i,j-0.22,num2str(r(i,j),2),...
                'HorizontalAlignment','center','FontSize',4.5,'FontUnits','normalized')
            text(i,j+0.2,[num2str(p(i,j),'%2.1e')],...
                'HorizontalAlignment','center','FontSize',3.7,'FontUnits','normalized');
        end
    end
end
hold off
set(gca,'fontsize', fsz);
%}

% format field labels for display
for i = 1:length(clusteredLabels)
    tmp = clusteredLabels{i};
    tmp(tmp=='_')=' ';
    clusteredLabels(i)={tmp};
end
set(gca,'Ytick',[1:nFields],'YtickLabel', clusteredLabels,'fontsize',10);

%% create plot for number of samples

figure();
imh = imagesc(n);
egoalley=interp1([1 52 128 129 164 225 256],...
    [0 1 1; 0 .2 1; 0 .0392 .1961; .1639 .0164 0 ; 1 .1 0; 1 .9 0; 1 1 1],1:256);
colormap('cool');
colorbar
%caxis([-1,1]);

fsz = 10;
hold on
set(gca,'Xtick',1:size(data,1),'Ytick',1:size(data,1),'FontSize',fsz);
for i=1:size(n,1)
    for j=1:size(n,2)
        if i~=j
            text(i,j-0.2,num2str(n(i,j)),...
                'HorizontalAlignment','center','FontSize',5,'FontUnits','normalized');
        end
    end
end
hold off
set(gca,'fontsize', fsz);
set(gca,'Ytick',[1:nFields],'YtickLabel', clusteredLabels,'fontsize',10);