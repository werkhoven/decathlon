function D = collapseMetrics(D,varargin)


% parse inputs
mode = 'average';
fields = 'circadian';
PCs = 2;
grp_path = 'D:\Decathlon Raw Data\decathlon 8-2017\meta\apriori_groups.mat';
for i=1:length(varargin)
    
    arg = varargin{i};
    if ischar(arg)
        switch arg
            case 'Mode'
                i=i+1;
                mode = varargin{i};
            case 'Fields'
                i=i+1;
                fields = varargin{i};
            case 'PCs'
                i=i+1;
                PCs = varargin{i};
        end
    end
end

f = D.fields;
    


switch fields
    case 'circadian'
        
        % find relevant indices in the matrix
        idx = find(~cellfun(@isempty,strfind(f,'Circadian')));
        cf = f(idx);
        cf = cellfun(@(x,y) x(1:y-2),cf,strfind(cf,'('),'UniformOutput',false);
        cf = cellfun(@(x,y) x(y+10:end),cf,strfind(cf,'Circadian'),'UniformOutput',false);
        
        % get unique field names and compute average
        uf = unique(cf);
        ufilt = cellfun(@(x) strcmp(cf,x),uf,'UniformOutput',false);
        collapsed = cellfun(@(x) nanmean(D.data(:,idx(x)),2),ufilt,'UniformOutput',false);
        newFields = cellfun(@(x) ['Circadian ' x],uf,'UniformOutput',false);
        
        % remove raw data and old field names
        D.data(:,idx)=[];
        D.fields(idx)=[];
        D.data = [D.data cat(2,collapsed{:})];
        D.fields = [D.fields; newFields];      
        
    case 'all'
        
        f = cellfun(@(x,y) x(1:y-2),f,strfind(f,'('),'UniformOutput',false);
        dMat = [];
        nf = [];
        
        load(grp_path,'apriori_groups');
        grps = cat(1,apriori_groups{:,2});
        for i=1:length(unique(grps))
            uf = apriori_groups(grps==i,1);
            idx = cellfun(@(x) any(strcmp(uf,x)),f);
            data=D.data(:,idx);
            if ~isempty(data)
            switch mode
                case 'average'
                    collapsed = nanmean(data,2);
                    dMat = [dMat collapsed];
                    nf = [nf; unique(apriori_groups(grps==i,3))];
                case 'PCA'
                    data = nanzscore(data);
                    %data = fillWithRegressedValues(data);
                    [coef,score,lat,~,explained] = pca(data);
                    if size(score,2)<PCs
                        nPC = size(score,2);
                    else
                        nPC=PCs;
                    end
                    dMat = [dMat score(:,1:nPC)];
                    tf = cell(nPC,1);
                    tf(:) = unique(apriori_groups(grps==i,3));
                    tf = cellfun(@(x,y) [x ' (' num2str(y) ')'],tf,...
                        num2cell(1:nPC)','UniformOutput',false);
                    nf = [nf; tf];
            end
            end
        end
        
        D.data = dMat;
        D.fields = nf;
end

