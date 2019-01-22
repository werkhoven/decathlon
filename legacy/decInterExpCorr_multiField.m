function [corrMat,p_values]=decInterExpCorr_multiField(fields)

% This function calculates the correlation in turn or light choice
% probability over the interval (in minutes) specified in the input.
% Fields - a cell array of strings containing names of the relevant fields
% to compare across experimental conditions or days
%%
act_fieldnames = cell(length(fields),1);
data=NaN(length(fields),2000);
activity_dat = NaN(length(fields),2000);
numActive=zeros(length(fields),1);

for k=1:length(fields)

% Get paths to data files
[fName,fDir,fFilter] = uigetfile('*.txt;*',['Open data for ' fields{k}],...
    'E:\Decathlon Raw Data\Phototactic Triathlon 1-26-2017\','Multiselect','on');


if iscell(fName)
    numFiles=length(fName);
else
    numFiles=1;
end
%
    for j=1:numFiles

        if iscell(fName)
        load(strcat(fDir,fName{j}));                        % Load data struct
        else
        load(strcat(fDir,fName));                        % Load data struct
        end

        % Restrict the data to active flies
        [activity_thresh,activity_fieldname] = thresh_activity(fields{k});
        tmp_activity = flyTracks.(activity_fieldname);
        active = flyTracks.(activity_fieldname) > activity_thresh;
        act_fieldnames(k) = {activity_fieldname};
             
        tmp_data=flyTracks.(fields{k});                             % Data specified in field


        % Parse out strain, treatment, day, and ID numbers
        if iscellstr(flyTracks.labels{1,1})
            strain=flyTracks.labels{1,1}{:};
        else
            strain='';
        end
        if iscellstr(flyTracks.labels{1,3})
            treatment=flyTracks.labels{1,3}{:};
        else
            treatment='';
        end
        if ~isempty(flyTracks.labels{:,4})
            IDs=flyTracks.labels{:,4};
        end

        if ~isempty(flyTracks.labels{:,5}) && any(~isnan(flyTracks.labels{:,5}))
            Day=flyTracks.labels{:,5};
            Day=Day(active);
        else
            Day = ones(size(active));
        end

        % Record data to placeholder by day and ID number
        activeIDs=IDs(active);
        data(k,activeIDs) = tmp_data(active);
        activity_dat(k,activeIDs) = tmp_activity(active);
        numActive(k)=numActive(k)+sum(active);
        disp([num2str(j) ' out of ' num2str(length(fName)) ' complete'])

    end
end

% Delete empty rows and columns
emptyRows=sum(~isnan(data),2)<1;
emptyCols=sum(~isnan(data),1)<2;
data(emptyRows,:)=[];
data(:,emptyCols)=[];
activity_dat(emptyRows,:)=[];
activity_dat(:,emptyCols)=[];
%{
% Delete empty rows and columns
emptyCols=sum(isnan(data),1)>1;
data(:,emptyCols)=[];
%}
[corrMat,p_values]=corrcoef([data' activity_dat'],'rows','pairwise');
imagesc(corrMat)
nanticoke=interp1([1 52 103 164 225 256],[0 1 1; 0 .2 1; 0 0 0; 1 .1 0; 1 .9 0; 1 1 1],1:256);
colormap(nanticoke);
colorbar
caxis([-1,1])

fstring=[];
for i=1:length(fields)
    if i~=length(fields)
    fstring=[fstring fields{i} ' & '];
    else
    fstring=[fstring fields{i}];
    end
end

title(['Inter-experiment correlation: ',strain,' ',treatment,' ',fstring,' (n=',num2str(size(data,2)),')'],'fontsize',14);
hold on
for i=1:size(corrMat,1)
    for j=1:size(corrMat,2)
        if i~=j
            text(i-0.15,j-0.1,['r = ',num2str(round(corrMat(i,j)*1000)/1000)],'fontsize',14,'Color',[1 1 1])
            text(i-0.15,j+0.1,['p = ',num2str(round(p_values(i,j)*1000)/1000)],'fontsize',14,'Color',[1 1 1])
        end
    end
end
hold off
set(gca,'fontsize', 14);

labels=cell(6,1);
labels(1) = {'flyvac - light choice probability'};
labels(2) = {'LEDymaze - light choice probability'};
labels(3) = {'slowphoto - light occupancy'};
labels(4) = {'flyvac - choice number'};
labels(5) = {'LEDymaze - choice number'};
labels(6) = {'slowphoto - avg speed'};

set(gca,'Ytick',1:size(data,1)*2,'YtickLabel',labels)

figure();
numActive(numActive<1)=[];
plot(numActive,'Linewidth',2);
title('Num. Flies above Choice Number Threshold')
    
shg