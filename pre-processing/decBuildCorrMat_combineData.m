%% Get parent directory of all decathlon files

fDir = autoDir;

% intialize master struct for data
dec = repmat(struct('data',[],'fields',[],'name',[],'day',[],'ID',[],'meta',[]),11,1);
circ = repmat(struct('data',[],'fields',[],'name',[],'day',[],'ID',[],'meta',[]),15,1);

assays = {'Arena Circling';'Slow Phototaxis';'Temporal Phototaxis';...
    'Optomotor';'Olfaction';'Culling';'Y-maze';'LED Y-maze'};

collapse = false;
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
            tmpID = expmt.labels_table.ID;
            circ(day).ID = [circ(day).ID; tmpID];
            expmt.nTracks = length(tmpID);
            
            % store values in decathlon data struct
            circ(day).name = name;
            circ(day).day = day;

            % extract experiment metrics
            [data,field_names] = getDataFields(expmt);
            circ(day).fields = [circ(day).fields;...
                field_names(~cellfun(@(x) any(strcmp(circ(day).fields,x)),field_names))];

            % append metrics to values in decathlon data struct
            if isempty(circ(day).data)
                circ(day).data = data;
            else
                fn = fieldnames(data);
                for i = 1:length(fn)
                    if isfield(circ(day).data,fn{i})
                        if length(circ(day).ID) > length(circ(day).data.(fn{i}))
                            circ(day).data.(fn{i}) = [circ(day).data.(fn{i}); data.(fn{i})];
                        else
                            id_mapping = arrayfun(@(x) find(circ(day).ID==x),tmpID);
                            circ(day).data.(fn{i})(id_mapping) = data.(fn{i});
                        end
                    else
                        dfn = fieldnames(circ(day).data);
                        circ(day).data.(fn{i}) = NaN(size(circ(day).data.(dfn{1})));
                        id_mapping = arrayfun(@(x) find(circ(day).ID==x),tmpID);
                        circ(day).data.(fn{i})(id_mapping) = data.(fn{i});
                    end 
                        
                end
                missingFields = ~cellfun(@(x) any(strcmp(fn,x)),fieldnames(circ(day).data));
                if any(missingFields)
                    dfn = fieldnames(circ(day).data);
                    dfn = dfn(missingFields);
                    for i=1:length(dfn)
                        circ(day).data.(dfn{i}) = [circ(day).data.(dfn{i}); NaN(expmt.nTracks,1)];
                    end
                end
                
            end
            
            % get meta data for experiment
            meta = assignMetaData(expmt);
            if isempty(circ(day).meta)
                circ(day).meta = meta;
            else
                fn = fieldnames(circ(day).meta);
                for i=1:length(fn)
                    circ(day).meta.(fn{i}) = [circ(day).meta.(fn{i}); meta.(fn{i})];
                end
            end
            
        otherwise
            
            assayIdx = find(strcmp(name,assays));
            
            switch name
                case 'Olfaction'
                    day = expmt.Day;
                    if size(expmt.ID,2)>size(expmt.ID,1)
                        expmt.ID = expmt.ID';
                    end
                    dec(assayIdx).ID = [dec(assayIdx).ID; expmt.ID];
                case 'Y-maze'
                    day =  expmt.labels_table.Day(1);   % query testing day
                    if day==1
                        name = 'Culling';
                        assayIdx = find(strcmp(name,assays));             
                    end
                    dec(assayIdx).ID = [dec(assayIdx).ID; expmt.labels_table.ID];
                otherwise
                    day =  expmt.labels_table.Day(1);   % query testing day
                    dec(assayIdx).ID = [dec(assayIdx).ID; expmt.labels_table.ID];
                    expmt.nTracks = length(expmt.labels_table.ID);
            end

            % store values in decathlon data struct
            dec(assayIdx).name = name;
            dec(assayIdx).day = day;

            % extract experiment metrics
            [data,field_names] = getDataFields(expmt);
                        dec(assayIdx).fields = [dec(assayIdx).fields;...
                field_names(~cellfun(@(x) any(strcmp(dec(assayIdx).fields,x)),field_names))];

            % append metrics to values in decathlon data struct
            if isempty(dec(assayIdx).data)
                dec(assayIdx).data = data;
            else
                fn = fieldnames(data);
                for i = 1:length(fn)
                    dec(assayIdx).data.(fn{i}) = [dec(assayIdx).data.(fn{i}); data.(fn{i})];
                end
            end
            
            % get meta data and append
            meta = assignMetaData(expmt);
            if isempty(dec(assayIdx).meta)
                dec(assayIdx).meta = meta;
            else
                fn = fieldnames(dec(assayIdx).meta);
                for i=1:length(fn)
                    dec(assayIdx).meta.(fn{i}) = [dec(assayIdx).meta.(fn{i}); meta.(fn{i})];
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

cnFields=0;
for i = 1:length(circ)
    circ(i).n = length(circ(i).ID);
    cnFields = cnFields + length(circ(i).fields);
end


% model nuisance variable effects and replaced with residuals if necessary
%{
[dec,declm] = modelEffects(dec,nFields,'TimeofDay',false);
[circ,circlm] = modelEffects(circ,cnFields,'TimeofDay',false);
%}
[dec,declm] = modelEffects(dec,nFields);
[circ,circlm] = modelEffects(circ,cnFields);

% initialize data mat (observations x variables)
nFields = nFields + cnFields;
dMat = NaN(max([dec.n circ.n]),nFields);
dFields = cell(nFields,1);
fct = 0;
nDays = max([dec.day circ.day]);

for i=1:nDays
    
    if i<=length(circ) && ~isempty(circ(i).fields)
        
        f = circ(i).fields;

        for j=1:length(f)

            fct=fct+1;
            if any(dMat(:,end)==0)
                disp([num2str(fct) ' ' num2str(i) ' ' num2str(j)]);  
            end
            fidx = sub2ind(size(dMat),circ(i).ID,repmat(fct,size(circ(i).ID)));
            dMat(fidx) = circ(i).data.(f{j});
            dMat(fidx(~circ(i).data.filter)) = NaN;
            dFields(fct) = {[circ(i).name ' ' f{j} ' (' num2str(i) ')']};
        end 
    end
    
    if i<=length(dec) && ~isempty(dec(i).fields)
        
        f = dec(i).fields;

        for j=1:length(f)

            fct=fct+1;
            fidx = sub2ind(size(dMat),dec(i).ID,repmat(fct,size(dec(i).ID)));
            dMat(fidx) = dec(i).data.(f{j});
            dMat(fidx(~dec(i).data.filter)) = NaN;
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
        

% delete empty struct entries
dec(arrayfun(@(x) isempty(dec(x).data),1:length(dec)))=[];
circ(arrayfun(@(x) isempty(circ(x).data),1:length(circ)))=[];

%% unfiltered raw data

nMat = nanzscore(dMat);
[fh,r,p]=plotCorr(dMat,'Labels',dFields,'Cluster',true);

clearvars -except dMat dec circ dFields declm circlm

%% create plot for number of samples

figure();
imh = imagesc(n);
egoalley=interp1([1 52 128 129 164 225 256],...
    [0 1 1; 0 .2 1; 0 0 0; 0 0 0 ; 1 .1 0; 1 .9 0; 1 1 0],1:256);
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
set(gca,'XTick',1:length(dFields),'XTickLabel',clusteredLabels,'fontsize',10,'XTickLabelRotation',45);


%% separate measures into distinct clusters with no apriori hypothesis of correlation

distinctClusters = [{'activity'};{'handedness'};...
    {'phototaxis'};{'olfaction'};{'optomotor'};...
    {'clumpiness'};{'switchiness'}];

clusterIdx = [{[2,4,6,9,11,13,15,17,20,24,26,31,33,35,41,43]};...
    {[5,10,21,28,36]};{[7,37]};{27};{18};{[22,30,38]};{[23,39,40]}];

independentMat = NaN(size(dMat,1),length(clusterIdx));
varCaptured = NaN(length(clusterIdx),1);

% z-score the data and replace missing values by linear regression
tmpMat = dMat;
tmpMat = nanzscore(tmpMat);
tmpMat = fillWithRegressedValues(tmpMat);


for i = 1:length(clusterIdx)
    
    [coef,score,lat] = pca(tmpMat(:,clusterIdx{i}));
    independentMat(:,i)=score(:,1);
    varCaptured(i) = lat(1)/sum(lat);
    
end

plotCorr(independentMat,distinctClusters);

figure;
bh=bar(varCaptured(Zoutperm));
set(gca,'XTick',1:length(varCaptured),'XTickLabel',clusteredLabels,'XTickLabelRotation',45);
ylabel('variance captured for each grouping');

%% look within each category of metric

handMat = dMat(:,clusterIdx{2});
handFields = dFields(clusterIdx{2});

plotCorr(handMat,handFields);

%%
actMat = dMat(:,clusterIdx{1});
actFields = dFields(clusterIdx{1});

plotCorr(actMat,actFields);

%%

clumpMat = dMat(:,clusterIdx{6});
clumpFields = dFields(clusterIdx{6});

plotCorr(clumpMat,clumpFields);