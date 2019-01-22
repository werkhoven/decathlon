function [out,labelNames]=extractField_multiFile(fields,varargin)

% Takes field as an input (eg. 'rBias') and prompts the user to select
% multiple files. Files are automatically sorted and grouped by line,
% treatment, and day.

keyarg = {};
for i=1:length(varargin)
    arg = varargin{i};
    if ischar(arg)
        switch arg
            case 'Keyword'
                keyidx = i;
                i=i+1;
                keyarg = {'keyword';varargin{i}};
        end
    end
end

if exist('keyidx','var')
    varargin(keyidx:keyidx+1)=[];
end

for i = 1:length(varargin)
    
    arg = varargin{i};
    
    if ischar(arg)
        switch arg
            case 'Subfield'
                i = i+1;
                subfields = varargin{i};
                if ~iscell(subfields)
                    subfields = {subfields};
                end
            case 'SortMode'
                i = i+1;
                sortmode = varargin{i};
            case 'Filter'
                i = i+1;
                filter = varargin{i};
        end
    end
end

if ~exist('sortmode','var')
    sortmode = 'none';
end

if ~iscell(fields)
    fields = {fields};
end

%% Get paths to data files

[fDir] = uigetdir('C:\Users\debivort\Documents\MATLAB\Decathlon Raw Data',...
    'Select directory containing expmt structs to be analyzed');

fPaths = recursiveSearch(fDir,keyarg{:});
%dir_idx = i+1;
fDir=cell(size(fPaths));
for j=1:length(fPaths)
    [tmp_dir,~,~]=fileparts(fPaths{j});
    fDir(j) = {[tmp_dir '\']};
end

%% extract the data from the specified fields

%out=struct(fields);           % Initialize an arbitrarily large placeholder
numActive=zeros(length(fPaths),1);
labelNames=cell(0,0);


for i=1:length(fPaths)
    
    disp([num2str(i) ' out of ' num2str(length(fPaths)) ' loading...']) 
    
    load(fPaths{i});                    % Load data struct
    labelNames = [labelNames {getLabelStr(expmt)}];
    
    disp(['processing ' num2str(i) ' out of ' num2str(length(fPaths))]) 
    
    for j = 1:length(fields)

        if exist('subfields','var')
            
            for k = 1:length(subfields)
                
                tmp_data.(subfields{k}) = expmt.(fields{j}).(subfields{k});

                if exist('filter','var')
                    switch filter
                        case 'active'
                            active = expmt.(fields{j}).(filter);
                            tmp_data(~active) = NaN;
                            numActive(i)=sum(active);
                    end
                end
            end
            
            out(i).(fields{j}) = tmp_data;
            
        else
            out(i).(fields{j}) = expmt.(fields{j});               % Data specified in field
        end
        
    end

    disp([num2str(i) ' out of ' num2str(length(fPaths)) ' complete'])  

end

%%

%{
% Delete empty rows and columns
emptyRows=sum(~isnan(data),2)<1;
data(emptyRows,:)=[];
numActive(emptyRows)=[];

% Calculate MAD
MAD=NaN(size(data,1),1);
for i=1:size(data,1)
    MAD(i)=mad(data(i,~isnan(data(i,:))));
end

fData=cell(size(data,1),1);
for i=1:size(fData,1)
    fData(i)={data(i,~isnan(data(i,:)))};
    labelNames(i)={[labelNames{i} ' (n=' num2str(numActive(i)) ')']};
end
%}