function analyzeMultiFiles(field)

%% Get paths to data files
[fName,fDir,fFilter] = uigetfile('*.txt;*','Open data file',...
    'C:\Users\debivort\Documents\MATLAB\Decathlon Raw Data','Multiselect','on');

%% Iterate through each data file

if iscell(fName)
    nGroups=length(fName);
else
    nGroups=1;
end

if nGroups>1
cVecL=ceil(nGroups/3);
cMap=zeros(size(fName,2),3);
cMap(1:cVecL+1,1)=fliplr(linspace(0,1,cVecL+1));
cMap(nGroups-cVecL:nGroups,3)=linspace(0,1,cVecL+1);

if mod(nGroups,2)==0
cMap(1:nGroups/2,2)=linspace(0,1,length(1:nGroups)/2);
cMap(nGroups/2+1:end,2)=fliplr(linspace(0,1,length(1:nGroups)/2));
else
cMap(1:round(nGroups/2),2)=linspace(0,1,length(1:round(nGroups/2)));
cMap(round(nGroups/2+1):end,2)=fliplr(cMap(1:round(nGroups/2-1),2)');
end
else
    cMap=[1 0 1];
end

n=zeros(nGroups,1);
u=zeros(nGroups,1);
MAD=zeros(nGroups,1);
indv_choice_probs=NaN(nGroups*120,nGroups);
label=cell(nGroups,2);
legendLabels=cell(nGroups,1);

inc=0.05;
bins=-inc/2:0.05:1+inc/2;
h=zeros(nGroups,length(bins)-1);
yLim=0;
nCohorts=1;

% Sort the data into distinct cohorts



for i=1:nGroups
    i
    if iscell(fName)
    load(strcat(fDir,fName{i}));
    else
    load(strcat(fDir,fName));
    end
       
        
    if iscellstr(flyTracks.labels{1,1})
    label(i,1)=flyTracks.labels{1,1};
    else
    label(i,1)={num2str(flyTracks.labels{1,1})};
    end
    if iscellstr(flyTracks.labels{1,3})
        label(i,2)=flyTracks.labels{1,3};
    end
    
    % Check to see if duplicate entry for strain already exists
    cohort=[label{i,1} label{i,2}];         % Combination of strain + treatment condition
    if i>1
        for j=1:size(label,1)
            tmpCohort=[label{j,1} label{j,2}];
            if strcmp(cohort,tmpCohort)
                index=j;
                break
            else
                index=i;
            end
        end
    else
        index=1;
    end
    
    active=flyTracks.numTurns>40;
    bias=flyTracks.(field)(active);
    sum(active)
    
    if index<i
        u(index)=round((u(index)*n(index)+mean(bias)*sum(active))/(n(index)+sum(active))*100)/100;        % Calculate new mean
        n(index)=n(index)+sum(active);                                                      % Calculate new N
        insert_i=find(isnan(indv_choice_probs(:,index)),1,'first');
        indv_choice_probs(insert_i:insert_i+length(bias)-1,index)=bias;
        tmph=histc(bias,bins);
        tmph(end)=[];
        h(index,:)=h(index,:)+tmph;
    else
        u(index)=round(mean(bias)*100)/100;
        n(index)=sum(active);  
        indv_choice_probs(1:length(bias),index)=bias;
        tmph=histc(bias,bins);
        tmph(end)=[];
        h(index,:)=tmph;
    end
    
    legendLabels(index)={[label{index,1},', ',label{index,2},' (u=',num2str(u(index)),', n=',num2str(n(index))]};
    
end

% Round mean scores to two decimal places
%u(index)=round((u(index)*100))/100;
size(h,2)
del=sum(h,2)==0;
h(del,:)=[];
n(del)=[];
u(del)=[];
legendLabels(del)=[];

for i=1:sum(sum(~isnan(indv_choice_probs))>0)
MAD(i)=round(mad(indv_choice_probs(~isnan(indv_choice_probs(:,i)),i))*100)/100;
legendLabels(i)={[legendLabels{i},', MAD=',num2str(MAD(i)),')']};
end

figure();
hold on

for i=1:size(h,1)
h(i,:)=h(i,:)/sum(h(i,:));
plot(h(i,:),'Color',cMap(i,:),'Linewidth',2);
end
h
yLim=max(max(h))
set(gca,'Xtick',1:length(h),'XtickLabel',0:inc:1);
axis([1 size(h,2) 0 yLim]);
legend(legendLabels);
title('Light Choice Probability Histogram');
    