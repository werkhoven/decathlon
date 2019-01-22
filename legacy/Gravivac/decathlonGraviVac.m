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

%% 

%load flyData.mat

BS = decathlonFlyVacHabituationAndClumpinessControlDistribution(data,numReps);

figure;hold on;d=BS;bins=linspace(-.5,2.5,10);
plot(bins,hist(d.observed(:,1),bins)/length(d.observed),'r');
plot(bins,hist(d.bootstrap(:,1),bins)/length(d.bootstrap),'b');
figure;hold on;d=BS;bins=linspace(0,30,10);
plot(bins,hist(d.observed(:,2),bins)/length(d.observed),'r');
plot(bins,hist(d.bootstrap(:,2),bins)/length(d.bootstrap),'b');

numFlies = size(data,1)/3;

for i = 1:numFlies
    
    flyID = cell2mat(data(i*3-2,2));
    index = find(flyID == '~');
    flyID(1:index(1)) = [];
    index = find(flyID == '~');
    flyID(index) = '-';
    datIndex = find(cellfun(@(x)isequal(x,flyID), {flyData.ID}));
    
    % For graviprop: 0 is positively gravitactic while 1 is negatively gravitactic
    
    gravData(i).gravity.g_graviprob = (cell2mat(data(i*3-2,6))+1)/2;
    gravData(i).gravity.g_numTrials = 40 - sum(isnan(cell2mat(data(i*3-2,7:46))));
    gravData(i).gravity.g_choicepermin = 60/nanmean((cell2mat(data(i*3,7:46))/1000));
    gravData(i).gravity.g_habituation = BS.observed(i,1);
    gravData(i).gravity.g_clumpiness = BS.observed(i,2);
    
    % Record behavioral parameters in master data file
    flyData(datIndex).gravity=gravData(i).gravity;
    
    gravData(i).gravity.maze = cell2mat(data(i*3-2,3));
    
    
end
    
