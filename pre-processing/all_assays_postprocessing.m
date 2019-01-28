%%

fDir = autoDir;
fPaths = recursiveSearch(fDir,'ext','.mat');

options = struct('disable',0,'handedness',1,'bouts',1,'bootstrap',0,...
    'slide',1,'regress',1,'areathresh',1,'save',1,'raw',{'speed'});

%%

fprintf('\n');
for i=1:numel(fPaths)
   
   fprintf('processing file %i of %i\n',i,numel(fPaths))
   load(fPaths{i});
   expmt.meta.options = options;
   expmt = autoAnalyze(expmt);
end