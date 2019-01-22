function out=floatingBarGraph(data,labels)
 % This function takes a cell array of measurements (data) where each entry
 % is an array of measurements for a single line, condition, etc. The labels argument is a cell array with
 % strings to label each entry in data.
 
 %% Compute a 95% confidence interval for each array in data
 figure();
 
 for i=1:size(data,1)
     
     tmpDat=data{i};
     mu=mean(tmpDat);
     sig=std(tmpDat);
     pd = makedist('Normal','mu',mu,'sigma',sig);
     ci = paramci(pd);
     ub=ci(1,1)+ci(1,2);
     lb=ci(1,1)-ci(1,2);
     if ub>1
         ub=1;
     end
     if lb<0
         lb=0;
     end
     h=ub-lb;
     hold on
     pos=i*2-1.5;
     rectangle('Position',[pos ub 1 h],'FaceColor',[1 0 0]);
     hold off
 
 end
 
  axis([0 pos+1.5 0 1])