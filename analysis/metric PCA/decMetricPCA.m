function dec = decMetricPCA(varargin)

% Takes an expmt master struct as an input, extracts all the relevant data
% metrics from the struct, PCAs all the data metrics and determines how
% many PCAs to analyze above the measurement noise.

%% Parse inputs
keyarg='';
fDir='';
save = true;
savedir = '';
for i = 1:length(varargin)
    
    arg = varargin{i};
    if ischar(arg)
        switch arg
            case 'Dir'
                i=i+1;
                fDir = varargin{i};
            case 'Save'
                i=i+1;
                save = varargin{i};
            case 'SaveDir'
                i=i+1;
                savedir = varargin{i};
            case 'Keyword'
                i=i+1;
                keyarg = varargin{i};
        end
    end
end

%% prompt user for save directory if none is provided

if save && isempty(savedir)
    [savedir] = uigetdir('C:\Users\debivort\Documents\MATLAB\Decathlon Raw Data',...
    'Select directory for PCA figures to save');
end

savedir = [savedir '\'];

if ~exist(savedir,'dir')
    mkdir(savedir);
end

%% get all structs with keyword under directory

fPaths = getHiddenMatDir(fDir,'keyword',keyarg);
fDir=cell(size(fPaths));
for j=1:length(fPaths)
    [tmp_dir,~,~]=fileparts(fPaths{j});
    fDir(j) = {[tmp_dir '\']};
end

%%

% intialize master struct for data
dec = repmat(struct('data',[],'fields',[],'name',[],'day',[],'ID',[]),10,1);

props = {'Bootstrap';false;'Save';false};   % set data processing options
hwb = waitbar(0,'loading files');           % intialize waitbar

for j = 1:length(fPaths)
    
    hwb = waitbar(j/length(fPaths),hwb,['loading file ' num2str(j) ' of ' num2str(length(fPaths))]);
    load(fPaths{j});                    % read in expmt struct
    name = expmt.Name;                  % query expmt name
    
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
    
    % get trackProps data
    switch name
        case 'Olfaction'
            
            % decimate data
            trackProps=[];
            decmask = mod(1:length(expmt.orientation),12)==0;           % create mask for decimating data
            expmt.orientation = expmt.orientation(decmask,:);
            
        otherwise
            
            % get trackProps
            [expmt,trackProps,meta] = autoDataProcess(expmt,props{:});

            % decimate trackProps data
            expmt.FrameRate = 1/nanmedian(expmt.Time.data);     % get median frame rate
            decfac = 5;                                         % set decimation to 5Hz
            decfac = round(expmt.FrameRate/decfac);             % round to nearest whole number
            decmask = mod(1:expmt.nFrames,decfac)==0;           % create mask for decimating data
            ftrack = fieldnames(trackProps);
            ftrack(strmatch('center',ftrack)) = [];
            for i=1:length(ftrack)
                trackProps.(ftrack{i}) = trackProps.(ftrack{i})(decmask,:);
            end
    end
    
    % extract experiment metrics
    [data,field_names] = getDataFields_abshand(expmt,trackProps);  
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

delete(hwb);

% delete empty indices of struct
del=[];
for i=1:length(dec)
    if isempty(dec(i).data)
        del = [del i];
    end
end

dec(del)=[];


%% PCA each day

for k = 1:length(dec)
    
    tmpf = dec(k).fields;
    nf = length(tmpf);
    tmpdata = NaN(length(dec(k).ID),nf);
    for i = 1:nf
        tmpdata(:,i) = dec(k).data.(tmpf{i});
        tmpdata(~dec(k).data.filter,i)=NaN;
    end
    
    % normalize values in the data matrix and replace missing values with
    % mean of each metric
    mus = NaN(nf,1);
    sigma = mus;
    normdata = tmpdata;
    mean_replaced = normdata;
    for i = 1:length(mus)
        mus(i) = nanmean(tmpdata(:,i));
        sigma(i) = nanstd(tmpdata(:,i));
        normdata(~isnan(tmpdata(:,i)),i) = (tmpdata(~isnan(tmpdata(:,i)),i) - mus(i))./sigma(i);
        mean_replaced(:,i) = normdata(:,i);
        mean_replaced(isnan(mean_replaced(:,i)),i) = nanmean(mean_replaced(:,i));
    end
    
    [coef,score,lat,~,explained] = pca(mean_replaced);
    lat = lat./sum(lat);
    fh=figure();
    plot(lat,'ko','Linewidth',2,'MarkerFaceColor',[0.7 0.7 0.7]);

    % shuffle IDs and plot variance explained
    nReps = 100;
    slat = NaN(nf,nReps);

    for j = 1:nReps
        sMat = mean_replaced;
        for i = 1:nf
            sMat(:,i) = sMat(randperm(length(sMat)),i);
        end

        [~,~,shuflat] = pca(sMat);
        slat(:,j) = shuflat./sum(shuflat);
    end

    hold on
    plot(median(slat,2),'ro','MarkerFaceColor',[1 0 0]);
    hold off
    nKeep = sum((lat-median(slat,2))>0.001);

    xlabel('no. of eigenvalues');
    ylabel('eigenvalue');
    legend({'data matrix','shuffled data'});
    
    % save fig
    daynum='';
    if length(dec)>1
        daynum = ['_day' num2str(dec(k).day)];
    end
    fname = [savedir name '_shuffled_PCs' daynum];
    if ~isempty(savedir) && save
        hgsave(fh,fname);
        close(fh);
    end
    
    dec(k).PCA.lat = lat;
    dec(k).PCA.coef = coef;
    dec(k).PCA.explained = explained;
    dec(k).PCA.nKeep = nKeep;
    dec(k).normdata = normdata;
    dec(k).PCA.mean_replaced = mean_replaced;
    dec(k).PCA.score = score;
    
    % show ranked loadings for each PC
    rank = NaN(nf);
    loading = rank;
    for i = 1:nf
        [v,p] = sort(coef(:,i));
        rank(:,i) = fliplr(p');
        loading(:,i) = fliplr(v');
    end

    for i = 1:length(tmpf)
        tf = tmpf{i};tf(tf=='_')=' ';tmpf(i)={tf};
    end
    
    % plot of save loadings for each significant PC
    for idx=1:nKeep
        fh=figure();
        plot(loading(:,idx),'ko','Linewidth',2,'MarkerFaceColor',[.7 .7 .7]);
        hold on
        plot([0 length(rank)],[0 0],'r--');
        ylabel('coefficient value');
        set(gca,'XTick',1:length(tmpf),'XTickLabel',tmpf(rank(:,idx)),'XTickLabelRotation',45);
        title(['Metric loadings for PC no. ' num2str(idx)]);
        
        % save fig
        fname = [savedir name '_PC' num2str(idx) '_loadings' daynum];
        if ~isempty(savedir) && save
            hgsave(fh,fname);
            close(fh);
        end
    end
    
end