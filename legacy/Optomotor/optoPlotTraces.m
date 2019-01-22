function [angle0,angle120,angle240,angleNoStim]=optoPlotTraces(flyTracks)

%% Find frames where centroid was lost and stitch traces together

numFigures=ceil(flyTracks.nFlies/10);
bins=linspace(-1,1,20);

for i=1:flyTracks.nFlies
    
   % Open new figure window and reset subplot count every 15 flies 
   if mod(i-1,10)==0
       figure()
       k=0;
   end
    subP=mod(i-1,5)+1+k*10;

    %Plot fly trace
    hold on
    subplot(5,5,subP);

    % Restrict data points to frames where fly was detected
    temp = flyTracks.centroid(:,:,i);
    tTrace=temp(~isnan(temp));
    tTrace=reshape(tTrace,length(tTrace)/2,2);
    tOri=flyTracks.orientation(~isnan(temp(:,1)),i);
    tAng=flyTracks.stimulusAngle(~isnan(temp(:,1)));
    tStim=flyTracks.stimulusStatus(~isnan(temp(:,1)));
    tAng(tStim==0)=720;
    tOri=tOri./90;
    z=zeros(length(tTrace),1);
    
    
    surface([tTrace(:,1)';tTrace(:,1)'],[tTrace(:,2)';tTrace(:,2)'],[z';z'],[tAng';tAng'],...
    'facecol','no','edgecol','interp','linew',1)


       if subP==5
            k=k+1;
       end
       
   % Plot histogram of orientation angles for each stimulus condition    
   subplot(5,5,subP+5);
   angle0 = tOri(tAng==0);
   %angle0(angle0==0)=[];
   angle0=histc(angle0,bins);
   angle0=angle0./sum(angle0);
   
   angle120 = tOri(tAng==120);
   %angle120(angle120==0)=[];
   angle120=histc(angle120,bins);
   angle120=angle120./sum(angle120);
   
   angle240 = tOri(tAng==240);
   %angle240(angle240==0)=[];
   angle240=histc(angle240,bins);
   angle240=angle240./sum(angle240);
   
   angleNoStim = tOri(tAng==720);
   %angleNoStim(angleNoStim==0)=[];
   angleNoStim = histc(angleNoStim,bins);
   angleNoStim=angleNoStim./sum(angleNoStim);
   
   hold on
   plot(bins,angle0,'r')
   plot(bins,angle120,'g')
   plot(bins,angle240,'b')
   plot(bins,angleNoStim,'k')
   hold off
   
end
