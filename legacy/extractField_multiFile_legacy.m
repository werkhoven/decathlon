function [data,labelNames,numActive,MAD]=extractField_multiFile(field)

% Takes field as an input (eg. 'rBias') and prompts the user to select
% multiple files. Files are automatically sorted and grouped by line,
% treatment, and day.

%% Get paths to data files
[fName,fDir,fFilter] = uigetfile('*.txt;*','Open data file',...
    'C:\Users\debivort\Documents\MATLAB\Decathlon Raw Data','Multiselect','on');

%%

data=NaN(length(fName),2000);           % Initialize an arbitrarily large placeholder
numActive=zeros(length(fName),1);
labelNames=cell(0,0);


for j=1:length(fName)
    
    load(strcat(fDir,fName{j}));                        % Load data struct
    tmp_data=flyTracks.(field);                         % Data specified in field
    
    choiceThresh=25;
    active=flyTracks.numTurns>choiceThresh;             % Remove data from flies that make less than 40 turns
    
    % Exclude mazes 41 and 48 if photobias is being considered
    if strcmp(field,'pBias')
        active([41 48])=0;
    end
    
    %% Parse out strain, treatment, day, and ID numbers
    if iscellstr(flyTracks.labels{1,1})
        strain=flyTracks.labels{1,1}{:};
    else
        strain='';
    end
    del=find(strain==95);
    strain(del:end)=[];
    
    if iscellstr(flyTracks.labels{1,3})
        treatment=flyTracks.labels{1,3}{:};
    else
        treatment='';
    end
    if ~isempty(flyTracks.labels{:,4})
    IDs=flyTracks.labels{:,4};
    end
    
    if ~isempty(flyTracks.labels{:,5})
    Day=flyTracks.labels{:,5};
    Day=Day(active);
    end
    
    tmpLabel=[strain ' ' treatment ' day ' num2str(unique(Day))];
    
    if ~isempty(labelNames)
        i=1;
        while i<=length(labelNames) && ~strcmp(tmpLabel,labelNames{i})
            i=i+1;
        end
        rowNum=i;
        labelNames(rowNum)={tmpLabel};
    else
        disp('here')
        labelNames(1)={tmpLabel};
        rowNum=1;
    end

    %% Record data to placeholder by day and ID number
    activeIDs=IDs(active);
    Day(isnan(Day))=[];

    data(rowNum,activeIDs)=tmp_data(active);
    numActive(rowNum)=numActive(rowNum)+sum(active);
    
    disp([num2str(j) ' out of ' num2str(length(fName)) ' complete'])
    

end

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