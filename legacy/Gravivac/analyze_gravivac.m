function analyze_gravivac(varargin)


%% Parse input vars

plots = {'histogram'};
save_mode = true;
choice_thresh = 10;

for i = 1:length(varargin)
    
    arg = varargin{i};
    
    if ischar(arg)
        switch arg
            case 'Dir'
                i=i+1;
                fDir = varargin{i};         % directory of data files
            case 'Day'
                i=i+1;
                day = varargin{i};          % array of testing days for each data file
            case 'SavePath'
                i=i+1;
                savepath = varargin{i};     % directory to save files
            case 'Plots'
                i=i+1;
                plots = varargin{i};        % plots to make and save
            case 'Save'
                i=i+1;
                save_mode = varargin{i};         % set file saving on or off
            case 'Label'
                i=i+1;
                fLabel = varargin{i};       % label to append to file names
            case 'Thresh'
                i=i+1;
                choice_thresh = varargin{i};       % label to append to file names
        end
    end
end


%% Get file paths

if ~exist('fDir','var')
    
    [fDir] = uigetdir('C:\Users\debivort\Documents\MATLAB\Decathlon Raw Data',...
    'Select directory containing raw geotaxis data to be analyzed');

end

fPaths = getHiddenMatDir(fDir,'ext','.txt');

% ensure path is formatted as cell
if ~iscell(fPaths)
    fPaths = {fPaths};
end

% get save path and figure directory
if save_mode && ~exist('savepath','var')
    
    if ~exist('fLabel','var')
        
        fLabel = cell(length(fPaths),1);
        
        
        for i=1:length(fPaths)
            [~,tmp_name,~]=fileparts(fPaths{i});
            fLabel(i) = {tmp_name};
        end
    end
    
    savepath = cell(size(fPaths));
    for i=1:length(fPaths)
        [tmp_dir,~,~]=fileparts(fPaths{i});
        savepath(i) = {[tmp_dir '\' fLabel{i} '\']};    
    end
    
end


% create save figure directories if necessary
figdir = cell(length(fPaths),1);
for i=1:length(fPaths)
    
    if ~exist(savepath{i},'dir')
        mkdir(savepath{i});
    end   
    
    figdir(i) = {[savepath{i} '\figures\']};
    if ~exist(figdir{i},'dir')
        mkdir(figdir{i});
    end
    
end



%% Initialize variables.
delimiter = '\t';
numReps = 1000;

% For more information, see the TEXTSCAN documentation.
formatSpec = '%f%s%f%f%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';

%% Read in and analyze data files sequentially



for i = 1:length(fPaths)

    % Open the text file
    fID = fopen(fPaths{i},'r');

    % Read columns of data according to format string
    dataArray = textscan(fID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN, 'ReturnOnError', false);

    % Close the text file
    fclose(fID);

    % Create output variable
    dataArray([1, 3, 4, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19,...
        20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36,...
        37, 38, 39, 40, 41, 42, 43, 44, 45, 46]) = cellfun(@(x) num2cell(x),...
        dataArray([1, 3, 4, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18,...
        19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35,...
        36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46]), 'UniformOutput', false);
    
    data = [dataArray{1:end-1}];
    clearvars filename fID dataArray ans;
    
    % find permutation for id numbers
    filter = mod(1:size(data,1),3)==1;
    delim=cellfun(@(x) find(x=='_'), data(filter,2),'UniformOutput',false);
    IDs=str2double(cellfun(@(x,idx)x(idx+1:end),data(filter,2),delim,'UniformOutput',false));
    [IDs,perm] = sort(IDs);

    % sort data into data struct and save
    expmt.nTracks = size(data,1)/3;
    
    expmt.Name = 'Gravitaxis';
    expmt.Gravity.bias = (cell2mat(data(perm.*3-2,6))+1)./2;
    expmt.Gravity.n = 40 - sum(isnan(cell2mat(data(perm.*3-2,7:46))),2);
    expmt.Gravity.iti = nanmean((cell2mat(data(perm.*3,7:46))/1000));
    expmt.Gravity.ID = IDs;
    expmt.Gravity.seq = cell2mat(data(perm.*3-2,7:46))';
    expmt.labels_table = table(IDs,repmat(day(i),size(IDs)),...
        'VariableNames',{'ID';'Day'});
    
    % get active flies
    
    expmt.Gravity.active = expmt.Gravity.n > choice_thresh;

    % optionally bootstrap resample data to compare to null
    if any(strcmp(plots,'bootstrap'))
        
        [expmt.bs,f] = bootstrap_gravivac(expmt.Gravity.seq,numReps,expmt.Gravity.active);
        hgsave(f,[figdir{i} fLabel{i} '_bootstrap']);

    end
    
    if save_mode
        savepath(i) = {[savepath{i} fLabel{i} '.mat']};
        save(savepath{i},'expmt');
    end
    
    
end
    
%%
%{
d1raw=d1;
d2raw=d2;

thresh = 11;

d1(n1<thresh)=NaN;
d2(n2<thresh)=NaN;

[r,p] = corrcoef([d1;d2]','rows','pairwise');
disp(['r = ' num2str(r(1,2))]);
disp(['p = ' num2str(p(1,2))]);

filter = isnan(d1) | isnan(d2);
scatter(d1(~filter),d2(~filter),'ok','Linewidth',1.5,'MarkerFaceColor',[0.5 0.5 0.5]);
xlabel(['day 1 - geo. prob. (u=' num2str(nanmean(d1),2) ')']);
ylabel(['day 2 - geo. prob. (u=' num2str(nanmean(d2),2) ')']);
title(['Bk-iso-1 Geotaxis (r=' num2str(r(1,2),2) ', n=' ...
    num2str(sum(~filter)) ', p=' num2str(p(1,2),'%2.1e') ')']);
%}