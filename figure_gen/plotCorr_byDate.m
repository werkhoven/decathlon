function plotCorr_byDate(dMat,dFields)
% plot decathlon correlation matrix sorted by day of testing

% get unique day numbers
days = regexp(dFields,'(?<=\()[0-9]*(?=\))','match');
days = days(~cellfun(@isempty,days));
days = cellfun(@(d) d{1}, days, 'UniformOutput', false);
days = cellfun(@str2double, days);
udays = unique(days);

% sort by data and field labels by day of testing
sorted_dMat = [];
sorted_dFields = [];

for i=1:numel(udays) 
    sorted_dMat = [sorted_dMat dMat(:,days==udays(i))];
    sorted_dFields = [sorted_dFields; dFields(days==udays(i))];
end

plotCorr(sorted_dMat,'Labels',sorted_dFields,'Cluster',false);

