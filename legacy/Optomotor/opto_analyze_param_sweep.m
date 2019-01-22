function contrast = opto_analyze_param_sweep(expmt)


expmt.Contrast.values = expmt.sweep.contrasts;
expmt.Contrast.index = NaN(length(expmt.sweep.contrasts),expmt.nTracks);
expmt.Contrast.active = false(length(expmt.sweep.contrasts),expmt.nTracks);

for i = 1:length(expmt.sweep.contrasts)

    % extract subset traces
    subset = expmt.Contrast.data == expmt.sweep.contrasts(i);
    subset = subset & (expmt.SpatialFreq.data < 10);
    subset = subset & (expmt.AngularVel.data > 180 & expmt.AngularVel.data < 480);
    subset = expmt.StimStatus.data & repmat(subset,1,expmt.nTracks);
    [da,opto_index,nTrials] = extractOptoTraces_legacy(subset,expmt);
    expmt.Contrast.index(i,:) = opto_index;

    % filter data for activity
    a=~isnan(da);
    trialnum_thresh = round(median(nTrials)*0.5);
    active = nTrials > trialnum_thresh;
    sampling = false(size(active));
    sampling(active) = (squeeze(sum(sum(a(:,1:trialnum_thresh,active))))...
        ./(size(da,1)*size(da,2))) > 0.01;
    active = sampling;
    expmt.Contrast.active(i,:) = active;

%     % plot traces
%     titstr = ['contrast = ' num2str(expmt.sweep.contrasts(i))];
%     plotOptoTraces(da,active,expmt.parameters,'title',titstr,'Ylim',[llim ulim]);
end

contrast = expmt.Contrast;

% subplot(dim,3,i+1);
% avg_trace = [];
% ci_trace = [];
% for i = 1:length(expmt.sweep.contrasts)
%     [m,~,ci95,~] = normfit(expmt.Contrast.index(i,expmt.Contrast.active(i,:))');
%     avg_trace = [avg_trace m];
%     ci_trace = [ci_trace ci95];
% end
% plot(avg_trace,'Linewidth',3);
% vx = [1:length(avg_trace) fliplr(1:length(avg_trace))];
% vy = [ci_trace(1,:) fliplr(ci_trace(2,:))];
% hold on
% ph = patch(vx,vy,[0 0.9 0.9],'FaceAlpha',0.3);
% uistack(ph,'bottom');
% title('avg. trace');
% xlabel('contrast')
% ylabel('opto index')
% set(gca,'Xtick',1:length(avg_trace),'XtickLabel',expmt.sweep.contrasts);
% legend({'95%CI' 'index'})
% 
% fname = [expmt.meta.path.fig expmt.meta.date '_con_swp'];
% if ~isempty(expmt.meta.path.fig) && options.save
%     hgsave(f,fname);
%     close(f);
% end

%% extract traces by angular velocity

% dim = ceil((length(expmt.sweep.ang_vel)+1)/3);
% expmt.AngularVel.values = expmt.sweep.ang_vel;
% expmt.AngularVel.index = NaN(length(expmt.sweep.ang_vel),expmt.nTracks);
% expmt.AngularVel.active = false(length(expmt.sweep.ang_vel),expmt.nTracks);
% 
% for i = 1:length(expmt.sweep.ang_vel)
% 
%     % extract subset traces
%     subplot(dim,3,i);
%     subset = expmt.StimStatus.data & repmat(expmt.AngularVel.data == expmt.sweep.ang_vel(i),1,expmt.nTracks);
%     [da,opto_index,nTrials] = extractOptoTraces_legacy(subset,expmt);
% 
%     % filter data for activity
%     a=~isnan(da);
%     trialnum_thresh = round(median(nTrials)*0.5);
%     active = nTrials > trialnum_thresh;
%     sampling = false(size(active));
%     sampling(active) = (squeeze(sum(sum(a(:,1:trialnum_thresh,active))))...
%         ./(size(da,1)*size(da,2))) > 0.01;
%     active = sampling;
% 
% 
% %     % create plots
% %     titstr = ['angular velocity = ' num2str(expmt.sweep.ang_vel(i))];
% %     plotOptoTraces(da,active,expmt.parameters,'title',titstr,'Ylim',[llim ulim]);
% 
%     expmt.AngularVel.active(i,:) = active;
%     expmt.AngularVel.index(i,:) = opto_index;
% end
% % 
% % subplot(dim,3,i+1);
% % avg_trace = [];
% % ci_trace = [];
% % for i = 1:length(expmt.sweep.ang_vel)
% %     [m,~,ci95,~] = normfit(expmt.AngularVel.index(i,expmt.AngularVel.active(i,:))');
% %     avg_trace = [avg_trace m];
% %     ci_trace = [ci_trace ci95];
% % end
% % plot(avg_trace,'Linewidth',3);
% % vx = [1:length(avg_trace) fliplr(1:length(avg_trace))];
% % vy = [ci_trace(1,:) fliplr(ci_trace(2,:))];
% % hold on
% % ph = patch(vx,vy,[0 0.9 0.9],'FaceAlpha',0.3);
% % uistack(ph,'bottom');
% % title('avg. trace');
% % legend({'95%CI' 'index'})
% % xlabel('stim \omega  (deg/s)')
% % ylabel('opto index')
% % set(gca,'Xtick',1:length(avg_trace),'XtickLabel',expmt.sweep.ang_vel);    
% % 
% % fname = [expmt.meta.path.fig expmt.meta.date '_angv_swp'];
% % if ~isempty(expmt.meta.path.fig) && options.save
% %     hgsave(f,fname);
% %     close(f);
% % end
% 
% %% extract traces by spatial frequency
% 
% dim = ceil((length(expmt.sweep.spatial_freq)+1)/3);
% 
% expmt.SpatialFreq.values = expmt.sweep.ang_vel;
% expmt.SpatialFreq.index = NaN(length(expmt.sweep.ang_vel),expmt.nTracks);
% expmt.SpatialFreq.active = false(length(expmt.sweep.ang_vel),expmt.nTracks);
% 
% for i = 1:length(expmt.sweep.spatial_freq)
% 
%     % extract subset traces
%     subplot(dim,3,i);
%     subset = expmt.StimStatus.data & repmat(expmt.SpatialFreq.data == expmt.sweep.spatial_freq(i),1,expmt.nTracks);
%     [da,opto_index,nTrials] = extractOptoTraces_legacy(subset,expmt);
% 
%     % filter data for activity
%     a=~isnan(da);
%     trialnum_thresh = round(median(nTrials)*0.5);
%     active = nTrials > trialnum_thresh;
%     sampling = false(size(active));
%     sampling(active) = (squeeze(sum(sum(a(:,1:trialnum_thresh,active))))...
%         ./(size(da,1)*size(da,2))) > 0.01;
%     active = sampling;
% 
%     % create plots
% %     titstr = ['num. cycles = ' num2str(expmt.sweep.spatial_freq(i))];
% %     plotOptoTraces(da,active,expmt.parameters,'title',titstr,'Ylim',[llim ulim]);
% 
%     expmt.SpatialFreq.index(i,:) = opto_index;
%     expmt.SpatialFreq.active(i,:) = active;
% 
% end

% subplot(dim,3,i+1);
% avg_trace = [];
% ci_trace = [];
% for i = 1:length(expmt.sweep.spatial_freq)
%     [m,~,ci95,~] = normfit(expmt.SpatialFreq.index(i,expmt.SpatialFreq.active(i,:))');
%     avg_trace = [avg_trace m];
%     ci_trace = [ci_trace ci95];
% end
% plot(avg_trace,'Linewidth',3);
% vx = [1:length(avg_trace) fliplr(1:length(avg_trace))];
% vy = [ci_trace(1,:) fliplr(ci_trace(2,:))];
% hold on
% ph = patch(vx,vy,[0 0.9 0.9],'FaceAlpha',0.3);
% uistack(ph,'bottom');
% title('avg. trace');
% legend({'95%CI' 'index'})
% xlabel('stim nCycles/360°')
% ylabel('opto index')
% set(gca,'Xtick',1:length(avg_trace),'XtickLabel',expmt.sweep.spatial_freq);  
% 
% fname = [expmt.meta.path.fig expmt.meta.date '_spatf_swp'];
% if ~isempty(expmt.meta.path.fig) && options.save
%     hgsave(f,fname);
%     close(f);
% end
