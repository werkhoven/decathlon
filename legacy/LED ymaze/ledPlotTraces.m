function ledPlotTraces(cenDat)

%% Find frames where centroid was lost and stitch traces together
numFlies=(size(cenDat,2)-1)/2;
numFigures=ceil(numFlies/10);

for i=1:numFlies
    
   % Open new figure window and reset subplot count every 15 flies 
   if mod(i-1,10)==0
       figure()
       k=0;
   end
    subP=mod(i-1,5)+1+k*10;

    %Plot fly trace
    hold on
    subplot(5,5,subP);
    
    % Plot rect
    hold on
    %bounds=[cROIs(i,1) cROIs(i,2) (cROIs(i,3)-cROIs(i,1)) (cROIs(i,4)-cROIs(i,2))];
    %rectangle('Position',bounds,'EdgeColor','r')

    % Restrict data points to frames where fly was detected
    temp = cenDat(:,i*2:i*2+1);
    tTrace=temp(~isnan(temp));
    tTrace=reshape(tTrace,length(tTrace)/2,2);
    z=zeros(length(tTrace),1);
    c=logspace(0,1,length(tTrace))';
    
    surface([tTrace(:,1)';tTrace(:,1)'],[tTrace(:,2)';tTrace(:,2)'],[z';z'],[c';c'],...
    'facecol','no','edgecol','interp','linew',1)

       if subP==5
            k=k+1;
       end
       
end