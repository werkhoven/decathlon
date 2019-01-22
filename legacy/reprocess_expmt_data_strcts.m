function analyze_multiFile(funstr,varargin)

    % This script reprocesses the expmt data structs from a user-selected set
    % of files with the function specified by funstr. 

    %% Get paths to data files
    [fName,fDir,fFilter] = uigetfile('*.mat;*','Open data file',...
        'C:\Users\debivort\Documents\MATLAB\Decathlon Raw Data','Multiselect','on');

    %% reprocess data
    
    fh = str2func(funstr);

    for i=1:length(fName)
        disp(['processing file ' num2str(i) ' of ' num2str(length(fName))]);
        load([fDir fName{i}]);
        expmt = feval(fh,varargin{:});
        clearvars expmt
    end