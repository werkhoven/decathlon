figure;
PCs=4;

%% plot correlation between raw data
subplot(4,3,1);
pairFields(D1,D2,'Trim',true,'Title','D1-D2 (raw)');
subplot(4,3,2);
pairFields(D1,D3,'Trim',true,'Title','D1-D3 (raw)');
subplot(4,3,3);
pairFields(D2,D3,'Trim',true,'Title','D2-D3 (raw)');

%% plot correlation after circadian metric collapse

D1col = collapseMetrics(D1);
D2col = collapseMetrics(D2);
D3col = collapseMetrics(D3);
subplot(4,3,4);
pairFields(D1col,D2col,'Trim',true,'Title','D1-D2 (circ collapsed)');
subplot(4,3,5);
pairFields(D1col,D3col,'Trim',true,'Title','D1-D3 (circ collapsed)');
subplot(4,3,6);
pairFields(D2col,D3col,'Trim',true,'Title','D2-D3 (circ collapsed)');

%% plot correlation after all apriori collapse

D1col = collapseMetrics(D1,'Fields','all');
D2col = collapseMetrics(D2,'Fields','all');
D3col = collapseMetrics(D3,'Fields','all');
subplot(4,3,7);
pairFields(D1col,D2col,'Title','D1-D2 (all collapsed)');
subplot(4,3,8);
pairFields(D1col,D3col,'Title','D1-D3 (all collapsed)');
subplot(4,3,9);
pairFields(D2col,D3col,'Title','D2-D3 (circ collapsed)');

%%

D1col = collapseMetrics(D1,'Fields','all','Mode','PCA','PCs',PCs);
D2col = collapseMetrics(D2,'Fields','all','Mode','PCA','PCs',PCs);
D3col = collapseMetrics(D3,'Fields','all','Mode','PCA','PCs',PCs);
subplot(4,3,10);
pairFields(D1col,D2col,'Title','D1-D2 (PCA)');
subplot(4,3,11);
pairFields(D1col,D3col,'Title','D1-D3 (PCA)');
subplot(4,3,12);
pairFields(D2col,D3col,'Title','D2-D3 (PCA)');

