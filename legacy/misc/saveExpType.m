function saveExpType(exp_name)

%% Purely temporary function for retroactively adding experiment type to data struct

[fName,fDir,fFilter] = uigetfile('*.txt;*','Open data file',...
    'E:\Decathlon Raw Data','Multiselect','on');

for j=1:length(fName)
    j
    load(strcat(fDir,fName{j}));                        % Load data struct
    flyTracks.exp=exp_name;
    save(strcat(fDir,fName{j}),'flyTracks');
end