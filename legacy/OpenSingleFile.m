%% Get paths to data files
[fName,fDir,fFilter] = uigetfile('*.txt;*','Open data file',...
    'E:\Decathlon Raw Data');
load(strcat(fDir,fName));