function [corrMat,p_values,activityLevel,data]=decInterExpCorr_multiFile(field)

% This function calculates the correlation in turn or light choice
% probability over the interval (in minutes) specified in the input

%% Get paths to data files
[fName,fDir,fFilter] = uigetfile('*.txt;*','Open data file',...
    'E:\Decathlon Raw Data','Multiselect','on');

%%

data=NaN(15,2000);
activityLevel=NaN(15,2000);
numActive=zeros(length(fName),1);
contrast=zeros(length(fName),1);
stim_duration=zeros(length(fName),1);

for j=1:length(fName)
    
    load(strcat(fDir,fName{j}));                        % Load data struct
    tmp_data=flyTracks.(field);                             % Data specified in field

    %% Parse out thresholds for different experiment and parameter types
    [active,activityParameter]=thresholdActivity(flyTracks);
    
    %% Parse out strain, treatment, day, and ID numbers
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
    
    if ~isempty(flyTracks.labels{:,5})
    Day=flyTracks.labels{:,5};
    Day=Day(active);
    end

    %% Record data to placeholder by day and ID number
    activeIDs=IDs(active);
    Day(isnan(Day))=[];
    unique_Days=unique(Day)
    tmp_data=tmp_data(active);
    IDs=IDs(~isnan(IDs));
    
    for i=1:length(unique_Days)
    data(unique_Days(i),activeIDs)=tmp_data(Day==unique_Days(i));
        if strcmp(activityParameter,'speed')
        activity=nanmean(flyTracks.(activityParameter));
        activityLevel(unique_Days(i),activeIDs)=activity(activeIDs);
        numActive(unique_Days(i))=numActive(unique_Days(i))+sum(active);
        else
        activityLevel(unique_Days(i),activeIDs)=flyTracks.(activityParameter)(active);
        numActive(unique_Days(i))=numActive(unique_Days(i))+sum(active);
        end
    end
    
    disp([num2str(j) ' out of ' num2str(length(fName)) ' complete'])
    

end

% Delete empty rows and columns
emptyRows=sum(~isnan(data),2)<1;
emptyCols=sum(~isnan(data),1)<1;
data(emptyRows,:)=[];
data(:,emptyCols)=[];
activityLevel(sum(~isnan(activityLevel),2)<1,:)=[];
activityLevel(:,sum(~isnan(activityLevel),1)<1)=[];

% Calculate MAD
MAD=NaN(size(data,1),1);
for i=1:size(data,1)
    MAD(i)=mad(data(i,~isnan(data(i,:))));
end
plot(MAD,'ro');


% Delete empty rows and columns
%emptyCols=sum(isnan(data),1)>0;
%data(:,emptyCols)=[];
%emptyCols=sum(isnan(activityLevel),1)>0;
%activityLevel(:,emptyCols)=[];


figure(1);
[corrMat,p_values]=corrcoef(data','rows','pairwise');
[activityCorr,act_p_values]=corrcoef(activityLevel','rows','pairwise');
imagesc(corrMat)
egoalley=interp1([1 52 128 129 164 225 256],[0 1 1; 0 .2 1; 0 .0392 .1961; .1639 .0164 0 ; 1 .1 0; 1 .9 0; 1 1 1],1:256);
colormap(egoalley);
colorbar
caxis([-1,1])
title(['Inter-experiment correlation: ',strain,' ',treatment,' ',field,' (n=',num2str(size(data,2)),')']);
set(gca,'Xtick',1:size(data,1),'Ytick',1:size(data,1),'FontSize',14);

hold on
for i=1:size(corrMat,1)
    for j=1:size(corrMat,2)
        if i~=j
            text(i-0.3,j,num2str(round(corrMat(i,j)*1000)/1000),'fontsize',14)
        end
    end
end
hold off
set(gca,'fontsize', 14);

figure(2);
imagesc(activityCorr)
colormap(egoalley);
colorbar
caxis([-1,1])
title(['Inter-experiment correlation: ',strain,' ',treatment,' ','activity',' (n=',num2str(size(data,2)),')']);
set(gca,'Xtick',1:size(data,1),'Ytick',1:size(data,1),'FontSize',14);

hold on
for i=1:size(activityCorr,1)
    for j=1:size(activityCorr,2)
        if i~=j
            text(i-0.3,j,num2str(round(activityCorr(i,j)*1000)/1000),'fontsize',14)
        end
    end
end
hold off
set(gca,'fontsize', 14);

figure(3);
%numActive(numActive<1)=[];
numActive(numActive==0)=[];
numActive=numActive./144;
plot(numActive,'Linewidth',2);
title('Num. Flies above Choice Number Threshold')
axis([1 size(data,1) 0 1])

    
shg