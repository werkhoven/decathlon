%% Get parent directory of all decathlon files

fDir = autoDir;

% intialize master struct for data
dec = repmat(struct('data',[],'fields',[],'name',[],'day',[],'ID',[]),14,1);
circ = repmat(struct('data',[],'fields',[],'name',[],'day',[],'ID',[]),15,1);

keyarg = '';
%%
fPaths = getHiddenMatDir(fDir,'Keyword',keyarg);
fDir=cell(size(fPaths));
for j=1:length(fPaths)
    [tmp_dir,~,~]=fileparts(fPaths{j});
    fDir(j) = {[tmp_dir '/']};
end

%% read in files sequentially

hwb = waitbar(0,'loading files');

for j = 1:length(fPaths)
    
    hwb = waitbar(j/length(fPaths),hwb,['loading file ' num2str(j) ' of ' num2str(length(fPaths))]);
    load(fPaths{j});                    % read in expmt struct
    name = expmt.Name;                  % query expmt name
    if strcmp(name,'Basic Tracking')
        name = 'Arena Circling';
        expmt.Name = name;
    end
    

    
    switch name
        case 'Circadian'
            
            day =  expmt.labels_table.Day(1);   % query testing day
            circ(day).ID = [circ(day).ID; expmt.labels_table.ID];
            expmt.nTracks = length(expmt.labels_table.ID);
            
            if day==1
                disp(j)
            end
            
            % store values in decathlon data struct
            circ(day).name = name;
            circ(day).day = day;

            % extract experiment metrics
            [data,field_names] = getDataFields(expmt);
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
            [data,field_names] = getDataFields(expmt);
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
fList = {};

for i=1:nDays
    
    if i<=length(circ) && ~isempty(circ(i).fields)
        
        f = circ(i).fields;
        fList = [fList;f];  

        for j=1:length(f)

            fct=fct+1;
            dMat(circ(i).ID,fct) = circ(i).data.(f{j});
            dMat(circ(i).ID(~circ(i).data.filter),fct) = NaN;
            dFields(fct) = {[circ(i).name ' ' f{j} ' (' num2str(i) ')']};
        end 
    end
    
    if i<=length(dec) && ~isempty(dec(i).fields)
        
        f = dec(i).fields;
        fList = [fList;f]; 

        for j=1:length(f)

            fct=fct+1;
            dMat(dec(i).ID,fct) = dec(i).data.(f{j});
            dMat(dec(i).ID(~dec(i).data.filter),fct) = NaN;
            dFields(fct) = {[dec(i).name ' ' f{j} ' (' num2str(i) ')']};
        end 
    end
    
    
end

% query unique fields
uFields = unique(fList);

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

fMat = NaN(size(dMat));
fFields = {};
fNames = {};
fList=cell(length(fList),1);
fct = 0;
dec([dec(:).n]==0)=[];
circ([circ(:).n]==0)=[];

for i = 1:length(uFields)
    
    f = uFields{i};
    
    for j = 1:length(dec)       
        fIdx = strcmp(f,dec(j).fields);
        if any(fIdx)
            fct = fct+1;
            fMat(dec(j).ID,fct) = dec(j).data.(dec(j).fields{fIdx});
            fMat(dec(j).ID(~dec(j).data.filter),fct) = NaN;
            fFields(fct) = {[dec(j).name ' ' f ' (' num2str(dec(j).day) ')']};
            fNames(fct) = {dec(j).name};
            fList(fct) = {f};
        end      
    end
    
    
    
    for j = 1:length(circ)
        
        fIdx = strcmp(f,circ(j).fields);
        if any(fIdx)
            fct = fct+1;
            fMat(circ(j).ID,fct) = circ(j).data.(circ(j).fields{fIdx});
            fMat(circ(j).ID(~circ(j).data.filter),fct) = NaN;
            fFields(fct) = {[circ(j).name ' ' f ' (' num2str(circ(j).day) ')']};
            fNames(fct) = {circ(j).name};
            fList(fct) = {f};
        end      
    end
end

%%
f = figure();
[r,p] = corrcoef(fMat,'rows','pairwise');
r(isnan(r))=0;
p(isnan(p))=1;

imh = imagesc(r);
egoalley=interp1([1 52 128 129 164 225 256],...
    [0 1 1; 0 .2 1; 0 0 0; 0 0 0 ; 1 .1 0; 1 .9 0; 1 1 0],1:256);
colormap(egoalley);
colorbar
caxis([-1,1]);


%% create axis labels and category blocks

for i = 1:length(uFields)
    tmp = uFields{i};
    fIdx = strcmp(fList,tmp);
    tmp(tmp=='_') = ' ';
    %tmp(tmp==' ') = '_';
    uFields(i)={tmp};
    fList(fIdx)={tmp};
end

uNames = unique(fNames);
nameIdx = cell(length(uNames),1);
fLabels = {};
ticks = [];
filters = {};
fct=0;
for j=1:length(uFields)
    for i=1:length(uNames)
    
    nameIdx(i) = {strcmp(uNames{i},fNames)};
    
        cmb = nameIdx{i} & strcmp(uFields{j},fList)';
        
        if sum(cmb)>1
            fct = fct+1;
            fLabels= [fLabels;{[uNames{i} ' - ' uFields{j}]}];
            filters(fct) = {cmb};
            cmb = cmb./sum(cmb);
            ticks = [ticks;[sum(cmb.*(1:length(cmb))) find(cmb,1,'first') find(cmb,1,'last')]];          
        end
    end
end

hold on
for i=1:size(ticks,1)
    plot([ticks(i,3)+.5 ticks(i,3)+.5],[0 length(r)+.5],'k-','Linewidth',1.5);
    plot([0 length(r)+.5],[ticks(i,3)+.5 ticks(i,3)+.5],'k-','Linewidth',1.5);
end
hold off

[~,p]=sort(ticks(:,1));
ticks = ticks(p,:);
tf = fLabels(p);

set(gca,'Ytick',ticks(:,1),'YtickLabel',tf,'fontsize',10);
set(gca,'XTick',ticks(:,1),'XTickLabel',tf,'fontsize',10,'XTickLabelRotation',45);

%% 
figure();
hold on
for i = 1:length(filters)
    nd = sum(filters{i});
    daydiff = abs(repmat(1:nd,nd,1) - repmat(1:nd,nd,1)');
    tmpdat = fMat(:,filters{i});
    [tmpr,~] = corrcoef(tmpdat,'rows','pairwise');
    line = NaN(nd-1,1);
    for j = 1:nd-1
        line(j) = nanmean(tmpr(daydiff==j));
    end
    plot(line,'-','Linewidth',2.5);   
    
end

legend(fLabels);
ylabel('mean r-value');
xlabel('days between measurements');