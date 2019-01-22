%% extract fields

f={'SpatialFreq' 'AngularVel' 'Contrast'};
sf={'index' 'values' 'active'};
[pooldat,labelNames]=extractField_multiFile(f,'Subfield',sf);

%% extract spatf sweep values

f={'sweep'};
[tmp,labelNames]=extractField_multiFile(f);

for i=1:length(tmp)
    pooldat(i).SpatialFreq.values = tmp(i).sweep.spatial_freq;
end


%% get unique values of spatial frequency and angular velocity


spatf = [];
angv = [];
cont = [];
for i = 1:length(pooldat)
    spatf = unique([spatf pooldat(i).SpatialFreq.values]);
    angv = unique([angv pooldat(i).AngularVel.values]);
    cont = unique([cont pooldat(i).Contrast.values]);
end

%% 

pc = cell(length(cont),1);

for i = 1:length(cont)
    
    for j = 1:length(pooldat)
        idx = cont(i) == pooldat(j).Contrast.values;
        pc(i) = {[pc{i} pooldat(j).Contrast.index(idx,pooldat(j).Contrast.active(idx,:))]};
    end
    
    
end

%% 

sf = cell(length(spatf),1);

for i = 1:length(spatf)
    
    for j = 1:length(pooldat)
        idx = spatf(i) == pooldat(j).SpatialFreq.values;
        sf(i) = {[pc{i} pooldat(j).SpatialFreq.index(idx,pooldat(j).SpatialFreq.active(idx,:))]};
    end
    
    
end

plot(spatf,-cellfun(@nanmean,sf))

%% 

pc = cell(length(spatf),1);

for i = 1:length(spatf)
    
    for j = 1:length(pooldat)
        idx = spatf(i) == pooldat(j).Contrast.values;
        pc(i) = {[pc{i} pooldat(j).Contrast.index(idx,pooldat(j).Contrast.active(idx,:))]};
    end
    
    
end
%% iterate through files, scan data for each pair of parameter values 
% and pool trials across experiments

% Get paths to data files
[fName,fDir,fFilter] = uigetfile('*.mat;*','Open data file',...
    'C:\Users\debivort\Documents\MATLAB\Decathlon Raw Data','Multiselect','on');

numinclude = NaN(length(spatf),length(angv),length(pooldat));
meanindex = NaN(length(spatf),length(angv),length(pooldat));

for k = 1:length(pooldat)
    
    disp(['processing file ' num2str(k) ' of ' num2str(length(fName))]);
    load([fDir fName{k}]);
    [expmt,trackProps] = processCentroid(expmt);
    
    for i = 1:length(spatf)
        
        for j = 1:length(angv)
            
            %disp(['[sf = ' num2str(spatf(i)) ', av = ' num2str(angv(j)) ']']);

            spatfinc = expmt.SpatialFreq.data == spatf(i);
            angvinc = expmt.AngularVel.data == angv(j);
            coninc = expmt.Contrast.data > 0.1;
            
            % extract subset traces
            subset = expmt.StimStatus.data & repmat(spatfinc & angvinc & coninc,1,expmt.nTracks);
            
            if any(subset(:))
                [da,opto_index,nTrials] = extractOptoTraces(subset,expmt,trackProps.speed);

                % filter data for activity
                a=~isnan(da);
                trialnum_thresh = round(median(nTrials)*0.5);
                active = nTrials > trialnum_thresh;
                sampling = false(size(active));
                sampling(active) = (squeeze(sum(sum(a(:,1:trialnum_thresh,active))))...
                    ./(size(da,1)*size(da,2))) > 0.01;
                active = sampling;
                meanindex(i,j,k) = nanmean(opto_index(active));
                numinclude(i,j,k) = sum(active);
            end
            
        end
    end
    
    clearvars expmt trackProps
    
end

%% calculate the mean effect for each parameter value pair and plot results

ntot = nansum(numinclude,3);
meaneffect = nansum(meanindex.*numinclude,3)./ntot;
meaneffect(6:7,1)=0;
imagesc(meaneffect);
set(gca,'XTick',1:length(angv),'XTickLabel',angv);
set(gca,'YTick',1:length(spatf),'YTickLabel',spatf);
xlabel('stim \omega (deg/s)');
ylabel('stim cycles per 360°');
title(['mean optomotor index (n=' num2str(nanmedian(ntot(:))) ')']);
colorbar

%% iterate through files, scan data for each pair of parameter values 
% and pool trials across experiments

% Get paths to data files
[fName,fDir,fFilter] = uigetfile('*.mat;*','Open data file',...
    'C:\Users\debivort\Documents\MATLAB\Decathlon Raw Data','Multiselect','on');

numinclude = NaN(length(angv),length(pooldat));
meanindex = NaN(length(angv),length(pooldat));

for k = 1:length(pooldat)
    
    disp(['processing file ' num2str(k) ' of ' num2str(length(fName))]);
    load([fDir fName{k}]);
    [expmt,trackProps] = processCentroid(expmt);
    
    for i = 1:length(angv)
            
            %disp(['[sf = ' num2str(spatf(i)) ', av = ' num2str(angv(j)) ']']);

            angvinc = expmt.AngularVel.data == angv(i);
            coninc = expmt.Contrast.data > 0.1;
            
            % extract subset traces
            subset = expmt.StimStatus.data & repmat(angvinc & coninc,1,expmt.nTracks);
            
            if any(subset(:))
                [da,opto_index,nTrials] = extractOptoTraces(subset,expmt,trackProps.speed);

                % filter data for activity
                a=~isnan(da);
                trialnum_thresh = round(median(nTrials)*0.5);
                active = nTrials > trialnum_thresh;
                sampling = false(size(active));
                sampling(active) = (squeeze(sum(sum(a(:,1:trialnum_thresh,active))))...
                    ./(size(da,1)*size(da,2))) > 0.01;
                active = sampling;
                meanindex(i,k) = nanmean(opto_index(active));
                numinclude(i,k) = sum(active);
            end
            
    end
    
    clearvars expmt trackProps
    
end

%%

ntot = nansum(numinclude,2);
meaneffect = nansum(meanindex.*numinclude,2)./ntot;
figure();
plot(meaneffect,'LineWidth',3);
set(gca,'XTick',1:length(angv),'XTickLabel',angv);
xlabel('stim \omega (deg/s)');
ylabel('opto index');
title(['mean optomotor index (n=' num2str(nanmedian(ntot(:))) ')']);

%% iterate through files, scan data for each pair of parameter values 
% and pool trials across experiments

% Get paths to data files
[fName,fDir,fFilter] = uigetfile('*.mat;*','Open data file',...
    'C:\Users\debivort\Documents\MATLAB\Decathlon Raw Data','Multiselect','on');

numinclude = NaN(length(spatf),length(pooldat));
meanindex = NaN(length(spatf),length(pooldat));

for k = 1:length(pooldat)
    
    disp(['processing file ' num2str(k) ' of ' num2str(length(fName))]);
    load([fDir fName{k}]);
    [expmt,trackProps] = processCentroid(expmt);
    
    for i = 1:length(spatf)
            
            %disp(['[sf = ' num2str(spatf(i)) ', av = ' num2str(angv(j)) ']']);

            spatfinc = expmt.SpatialFreq.data == spatf(i);
            coninc = expmt.Contrast.data > 0.1;
            
            % extract subset traces
            subset = expmt.StimStatus.data & repmat(spatfinc & coninc,1,expmt.nTracks);
            
            if any(subset(:))
                [da,opto_index,nTrials] = extractOptoTraces(subset,expmt,trackProps.speed);

                % filter data for activity
                a=~isnan(da);
                trialnum_thresh = round(median(nTrials)*0.5);
                active = nTrials > trialnum_thresh;
                sampling = false(size(active));
                sampling(active) = (squeeze(sum(sum(a(:,1:trialnum_thresh,active))))...
                    ./(size(da,1)*size(da,2))) > 0.01;
                active = sampling;
                meanindex(i,k) = nanmean(opto_index(active));
                numinclude(i,k) = sum(active);
            end
            
    end
    
    clearvars expmt trackProps
    
end

%%

ntot = nansum(numinclude,2);
meaneffect = nansum(meanindex.*numinclude,2)./ntot;
figure();
plot(meaneffect,'LineWidth',3);
set(gca,'XTick',1:length(spatf),'XTickLabel',spatf);
xlabel('stim num cycles');
ylabel('opto index');
title(['mean optomotor index (n=' num2str(nanmedian(ntot(:))) ')']);

%% iterate through files, scan data for each pair of parameter values 
% and pool trials across experiments

% Get paths to data files
[fName,fDir,fFilter] = uigetfile('*.mat;*','Open data file',...
    'C:\Users\debivort\Documents\MATLAB\Decathlon Raw Data','Multiselect','on');

numinclude = NaN(length(cont),length(pooldat));
meanindex = NaN(length(cont),length(pooldat));

for k = 1:length(pooldat)
    
    disp(['processing file ' num2str(k) ' of ' num2str(length(fName))]);
    load([fDir fName{k}]);
    [expmt,trackProps] = processCentroid(expmt);
    
    for i = 1:length(cont)
            
            %disp(['[sf = ' num2str(spatf(i)) ', av = ' num2str(angv(j)) ']']);

            coninc = expmt.Contrast.data == cont(i);
            
            % extract subset traces
            subset = expmt.StimStatus.data & repmat(coninc,1,expmt.nTracks);
            
            if any(subset(:))
                [da,opto_index,nTrials] = extractOptoTraces(subset,expmt,trackProps.speed);

                % filter data for activity
                a=~isnan(da);
                trialnum_thresh = round(median(nTrials)*0.5);
                active = nTrials > trialnum_thresh;
                sampling = false(size(active));
                sampling(active) = (squeeze(sum(sum(a(:,1:trialnum_thresh,active))))...
                    ./(size(da,1)*size(da,2))) > 0.01;
                active = sampling;
                meanindex(i,k) = nanmean(opto_index(active));
                numinclude(i,k) = sum(active);
            end
            
    end
    
    clearvars expmt trackProps
    
end

%%

ntot = nansum(numinclude,2);
meaneffect = nansum(meanindex.*numinclude,2)./ntot;
figure();
plot(cont,meaneffect,'LineWidth',3);
tick = (cont * (length(cont)-1)) + 1;
set(gca,'XTick',1:length(spatf),'XTickLabel',cont);
xlabel('stim num cycles');
ylabel('opto index');
title(['mean optomotor index (n=' num2str(nanmedian(ntot(:))) ')']);