[fName,fDir,fFilter] = uigetfile('*.txt;*','Open data file','C:\Users\debivort\Desktop\Decathlon Data Files');
numReps = 10000;

%% Initialize variables.
filename = strcat(fDir,fName);
delimiter = '\t';

%% Format string for each line of text:

% For more information, see the TEXTSCAN documentation.
formatSpec = '%f%s%f%f%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN, 'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Create output variable
dataArray([1, 3, 4, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46]) = cellfun(@(x) num2cell(x), dataArray([1, 3, 4, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46]), 'UniformOutput', false);
data = [dataArray{1:end-1}];
clearvars filename delimiter formatSpec fileID dataArray ans;

%% Extract Choices

numFlies=length(data)/3;
choiceSeq=[];
j=1;

for i=1:numFlies
    
    numTrials = 40 - sum(isnan(cell2mat(data(i*3-2,7:46))));
    
    if numTrials>39
    choiceSeq(j,:)=cell2mat(data(i*3-2,7:end));
    j=j+1;
    end
    
end

numFlies=length(choiceSeq);

%% Simulate 20 Trial runs with 20 individuals

nReps=30;
nSims=3000;
numFlies_simulated=50;
numChoices=40;

for i=1:nReps
    
    % Initialize arrays
    flies=zeros(numFlies_simulated,1);
    tempChoices=zeros(numFlies_simulated,numChoices);
    tempMAD=zeros(nSims,1);
    
    % Pick flies randomly until all 20 are unique
    while length(unique(flies))<numFlies_simulated
    flies=ceil(rand(numFlies_simulated,1).*258);
    end
    
    tempChoices=choiceSeq(flies,1:numChoices);
    tempChoices=tempChoices==1;
    pBias=sum(tempChoices,2)/numChoices;
    obsMAD(i)=mad(pBias,2);
    
    tempChoices=tempChoices(:);
    %Bootstrap resample the data
    for j=1:nSims
        
        % Pick 20 x 20 random choices with equal probability
        tempRows=ceil(rand(numFlies_simulated*numChoices,1)*numFlies_simulated*numChoices);
        simChoices=tempChoices(tempRows);
        simChoices=reshape(simChoices,numFlies_simulated,numChoices);
        
        % Calculate simulated choice bias as before
        simBias=sum(simChoices,2)/numChoices;
        
        tempMAD(j)=mad(simBias,2);
    end
    
    avgMAD(i)=mean(tempMAD);
    
end
        
 MADdiff=avgMAD-obsMAD
 mean(MADdiff)
