figure;
PCs=4;

subplot(2,2,1);
pairFields(D1,D2,'Trim',true,'Title','raw data');
subplot(2,2,2);
D1col = collapseMetrics(D1);
D2col = collapseMetrics(D2);
pairFields(D1col,D2col,'Trim',true,'Title','circadian data averaged');
subplot(2,2,3);
D1col = collapseMetrics(D1,'Fields','all');
D2col = collapseMetrics(D2,'Fields','all');
pairFields(D1col,D2col,'Title','apriori grouped data averaged');
subplot(2,2,4);
D1col = collapseMetrics(D1,'Fields','all','Mode','PCA','PCs',PCs);
D2col = collapseMetrics(D2,'Fields','all','Mode','PCA','PCs',PCs);
pairFields(D1col,D2col,'Title','apriori grouped data PCA');
