% figure;
% PCs=4;
% 
% subplot(2,2,1);
% pairFields(D1,D2,'Trim',true,'Title','raw data');
% subplot(2,2,2);
% D1col = collapseMetrics(D1);
% D2col = collapseMetrics(D2);
% pairFields(D1col,D2col,'Trim',true,'Title','circadian data averaged');
% subplot(2,2,3);
% D1col = collapseMetrics(D1,'Fields','all');
% D2col = collapseMetrics(D2,'Fields','all');
% pairFields(D1col,D2col,'Title','apriori grouped data averaged');
% subplot(2,2,4);
% D1col = collapseMetrics(D1,'Fields','all','Mode','PCA','PCs',PCs);
% D2col = collapseMetrics(D2,'Fields','all','Mode','PCA','PCs',PCs);
% pairFields(D1col,D2col,'Title','apriori grouped data PCA');

%% bootstrap D1 and D2

D1_raw = D1;
D2_raw = D2;
D1 = collapseMetrics(D1);
D2 = collapseMetrics(D2);

nReps = 100;
D1D2_r = NaN(nReps,1);
D1D1_r = NaN(nReps,1);
D2D2_r = NaN(nReps,1);

for i=1:nReps
    
    disp(i);
    D1bs = D1;
    d1 = D1.data;
    D1_idx = randi(size(d1,1),[size(d1,1) 1]);
    D1bs.data = d1(D1_idx,:);
    D2bs = D2;
    d2 = D2.data;
    D2_idx = randi(size(d2,1),[size(d2,1) 1]);
    D2bs.data = d2(D2_idx,:);
    [tmp,~] = pairFields(D1bs,D2bs,'Trim',true,'Title','raw data','Plot',false);
    D1D2_r(i) = tmp(1,2);

    % bootstrap D1 and D1
    D1bs = D1;
    d1 = D1.data;
    D1_idx = randi(size(d1,1),[size(d1,1) 1]);
    D1bs.data = d1(D1_idx,:);
    D2bs = D1;
    d2 = D1.data;
    D2_idx = randi(size(d1,1),[size(d1,1) 1]);
    D2bs.data = d2(D2_idx,:);
    [tmp,~] = pairFields(D1bs,D2bs,'Trim',true,'Title','raw data','Plot',false);
    D1D1_r(i) = tmp(1,2);

    % bootstrap D1 and D1
    D1bs = D2;
    d1 = D2.data;
    D1_idx = randi(size(d1,1),[size(d1,1) 1]);
    D1bs.data = d1(D1_idx,:);
    D2bs = D2;
    d2 = D2.data;
    D2_idx = randi(size(d2,1),[size(d2,1) 1]);
    D2bs.data = d2(D2_idx,:);
    [tmp,~] = pairFields(D1bs,D2bs,'Trim',true,'Title','raw data','Plot',false);
    D2D2_r(i) = tmp(1,2);

end


%%

autoPlotDist(D1D2_r(:),true(size(D1D2_r(:))));
autoPlotDist(D1D1_r(:),true(size(D1D1_r(:))),gca);
autoPlotDist(D2D2_r(:),true(size(D2D2_r(:))),gca);

lbls = {'D2-D2';'D1-D1';'D1-D2'};
legend(lbls,'Location','Northwest');
xlabel('correlation coefficient');

