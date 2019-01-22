function out=flyVacAnalysis(data,iters,plotBin)

warning off MATLAB:nchoosek:LargeCoefficient;

temp=data(:);
p=(nanmean(temp)+1)/2;

% numData=length(data)/3;
numData=size(data,1);
nVector=zeros(numData,1);

for i=1:numData
    n=length(data(i,:))-sum(isnan(data(i,:)));
    nVector(i)=n;    
end

numBins=max(nVector)/2;
bins=zeros(numBins,1);
stds=zeros(numBins,1);


out.histData=histc(nanmean(data,2),([-inf,-1:2/(numBins-1):1]+1/(100*numBins)))';
N=sum(out.histData);

% p=0.5128;

for i=1:length(nVector)
    
    n=nVector(i);
   
    y=zeros(n+1,1);
    for j=0:n
        y(j+1)=nchoosek(n,j)*p^j*(1-p)^(n-j);    %binom calculation
    end
    
    
    
    %     if n == numBins-1
    %         bins=bins+y;
    %
    %     else
    for j=0:n           %binom binning
        for k=0:numBins-1
            if j/n >= k/(numBins-1) && j/n < (k+1)/(numBins-1)
                bins(k+1)=bins(k+1)+y(j+1);
                P=y(j+1)/n;
                stds(k+1)=stds(k+1)+n*P*(1-P);
            end
        end
    end
    
    %     end
end

meanProbs=bins;
stdProbs=sqrt(stds);
% quartileScore=zeros(numBins,1);
% 
% 
% 
% for i=1:numBins
%     temp=sum(meanProbs(1:i))/N;
%     if temp<=0.25
%         quartileScore(i)=1;
%     else
%         if temp<=0.75
%             quartileScore(i)=-1;
%         else
%             quartileScore(i)=1;
%         end
%     end
% end

iterations=iters;

histos=zeros(iterations,41);
% pers1Scores=zeros(iterations,1);
persScores=zeros(iterations,1);

out.histData=out.histData(1:end-1)/N;
out.histData=out.histData';

temp=flyVacIQR(out.histData,'pdf','IQR');
sum(out.histData);
q1=temp(1); q3=temp(2);
personalityMetric=q3-q1;

numIter=iterations;

if iterations==0
    p_tally=0;
    for i=1:1000000
        if mod(i,100)==0;
            disp([i p_tally]);
        end
        histo=zeros(41,1);
        for j=1:numData
            
            if nVector(j) >0
                index=(sum(rand(nVector(j),1)<p)/nVector(j))*2-1;
                whichBin=round(index*20)/20;
                histo(round(whichBin*20+21))=histo(round(whichBin*20+21))+1;
            end
        end
        temp=flyVacIQR(histo/sum(histo),'pdf');
        q1=temp(1); q3=temp(2);
        persScore_temp=(q3-q1);
        histos(i,:)=histo;
        if persScore_temp > personalityMetric
            p_tally=p_tally+1;
        end
        p_temp=p_tally/i;
        numIter=i;
        if i>1000 && i>100/p_temp
            break
        end
    end
    personalityMetricPValue=p_tally/numIter;
else
    for i=1:iterations
        if mod(i,min([floor(iterations/10) 100]))==0;
            if i>100
                disp(i);
            end
        end
        histo=zeros(41,1);
        for j=1:numData
            
            if nVector(j) >0
                index=(sum(rand(nVector(j),1)<p)/nVector(j))*2-1;
                whichBin=round(index*20)/20;
                histo(round(whichBin*20+21))=histo(round(whichBin*20+21))+1;
            end
        end
        temp=flyVacIQR(histo/sum(histo),'pdf', 'IQR');
        q1=temp(1); q3=temp(2);
        persScores(i)=(q3-q1);
        histos(i,:)=histo;
    end
    personalityMetricPValue=sum(persScores>=personalityMetric)/iterations;
end

iterations=numIter;

x_i=((1:numBins)-1)';
mu=sum(x_i.*meanProbs/N);
scores=40*nanmean(((data+1)/2),2);
[~,ch2P,~,~]=vartest(scores,sum(meanProbs/N.*(x_i-mu).^2));


out.N=N;
out.P=p;
out.medianP=median((nanmean(data,2)+1)/2);
out.expStd= sqrt(sum((meanProbs/N).*(x_i-mu).^2));
out.obStd=sqrt(var(scores));
out.chisquared=((N-1)*var(scores))/(out.expStd^2);
out.chisquaredP=ch2P;
out.probs=meanProbs/N;
% out.stdevs=std(simData)';
out.stdevs=stdProbs/N;
out.muSEM=std((nanmean(data,2)+1)/2)/sqrt(size(data,1));

out.probUpper95=out.probs+2*out.stdevs;
out.probLower95=out.probs-2*out.stdevs;

out.expIQR=flyVacIQR(out.probs,'pdf', 'IQR');
out.obsIQR=flyVacIQR(out.histData,'pdf', 'IQR');

out.IQRR=log2((out.obsIQR(2)-out.obsIQR(1))/(out.expIQR(2)-out.expIQR(1)));
out.IQRRPValue=personalityMetricPValue;
out.IQRRSimIters=iterations;

% out.expIDR=flyVacIQR(out.probs,'pdf', 'IDR');
% out.obsIDR=flyVacIQR(out.histData,'pdf', 'IDR');
% out.IDRR=log2((out.obsIDR(2)-out.obsIDR(1))/(out.expIDR(2)-out.expIDR(1)));

IPRTemp=flyVacIQR(out.probs,'pdf', 'IPR');
numPercs=length(IPRTemp);
out.expIPR=mean(flipud(IPRTemp(((numPercs-1)/2+2):numPercs))-IPRTemp(1:((numPercs-1)/2)));
IPRTemp=flyVacIQR(out.histData,'pdf', 'IPR');
out.obsIPR=mean(flipud(IPRTemp(((numPercs-1)/2+2):numPercs))-IPRTemp(1:((numPercs-1)/2)));
out.IPRR=log2(out.obsIPR/out.expIPR);

out.SDR=log2(out.obStd/out.expStd);


% out.obsMoments(1)=sum(out.histData(1:floor(40*out.P)).*((0:floor(40*out.P)-1)/40)')/sum(out.histData(1:floor(40*out.P)));
% out.obsMoments(2)=sum(out.histData(ceil(40*out.P):40).*((ceil(40*out.P):40)/40)')/sum(out.histData(ceil(40*out.P):40));
% out.expMoments(1)=sum(out.probs(1:floor(40*out.P)).*((0:floor(40*out.P)-1)/40)')/sum(out.probs(1:floor(40*out.P)));
% out.expMoments(2)=sum(out.probs(ceil(40*out.P):40).*((ceil(40*out.P):40)/40)')/sum(out.probs(ceil(40*out.P):40));
% out.personalityMetric3=log2((out.obsMoments(2)-out.obsMoments(1))/(out.expMoments(2)-out.expMoments(1)));

binsTemp=((1:41)'-1)/40;
meansTemp=(nanmean(data,2)+1)/2;
obsMAD=mad(meansTemp,1);
expTemp=[];
expDistTemp=round(out.probs*1000);
for i=1:size(expDistTemp,1)
    expTemp=[expTemp;zeros(expDistTemp(i),1)+i];
end
expMAD=mad(expTemp/40,1);
out.MADR=log2(obsMAD/expMAD);

temp=flyVacMLBS(data);
out.ML=temp.ML;
out.MLstd=temp.MLstd;

% out.MADR=log2(obsMAD/expMAD);

% out.expSkew=sum(((binsTemp-out.P).^3).*out.probs)/((sum(((binsTemp-out.P).^2).*out.probs))^(3/2));
% out.obsSkew=skewness(meansTemp,0);


% out.MADR=log2(out.obsMAD/out.expMAD);
% out.personalityMetric=sum((out.histData-out.probs)./out.stdevs);
% out.personalityMetricPValue1=sum(pers1Scores>=out.personalityMetric)/iterations;
% out.personalityMetric2=sum((out.histData-out.probs).*quartileScore)/N;
% out.personalityMetricPValue2=sum(pers2Scores>=out.personalityMetric2)/iterations;
% out.personalitySimulatedMetric1s=pers1Scores;
% out.personalitySimulatedMetric2s=pers2Scores;

if plotBin==1
    figure
    hold on;
    darkgray=[.65 .65 .65];
    darkblue=[.1 .2 .9];
    blueblue=[.1 .3 1];
    lightgray=[.93 .93 .93];
    h=bar(out.probUpper95, 'hist');
    set(h,'EdgeColor', lightgray);
    set(h,'FaceColor', lightgray);
    h=bar(out.probLower95, 'hist');
    set(h,'EdgeColor', [1 1 1]);
    set(h,'FaceColor', [1 1 1]);
    plot(out.probs,'-o', 'LineWidth',3, 'MarkerEdgeColor', darkgray, 'MarkerFaceColor', darkgray, 'MarkerSize', 4, 'Color', darkgray);
    plot(out.histData,'-o', 'LineWidth',3, 'MarkerEdgeColor', darkblue, 'MarkerFaceColor', blueblue, 'MarkerSize', 4, 'Color', darkblue);
    xlim([0 41])
end