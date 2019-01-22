function out=flyVacIQRBootstrap(orig_data,resamples)

resampleHistoryVBE=zeros(resamples+1,1);
resampleHistorySDR=zeros(resamples+1,1);
% resampleHistoryMOM=zeros(resamples+1,1);
resampleHistoryIPRR=zeros(resamples+1,1);
resampleHistoryIPRR2=zeros(resamples+1,1);

for iter=1:resamples+1
    disp(iter);
    
    which=ceil(rand(size(orig_data,1),1)*size(orig_data,1));
    data=orig_data(which,:);
    if iter==resamples+1
        data=orig_data;
    end
    temp=data(:);
    p=(nanmean(temp)+1)/2;
    numData=size(data,1);
    nVector=zeros(numData,1);
    
    for i=1:numData
        n=length(data(i,:))-sum(isnan(data(i,:)));
        nVector(i)=n;
    end
    
    numBins=max(nVector)+1;
    bins=zeros(numBins,1);
    histData=histc(nanmean(data,2),([-inf,-1:2/(numBins-1):1]+1/(100*numBins)))';
    histData=histData(1:end-1)/numData;
    
    for i=1:length(nVector)
        n=nVector(i);
        y=zeros(n+1,1);
        for j=0:n
            y(j+1)=nchoosek(n,j)*p^j*(1-p)^(n-j);
        end
        for j=0:n
            for k=0:numBins-1
                if j/n >= k/(numBins-1) && j/n < (k+1)/(numBins-1)
                    bins(k+1)=bins(k+1)+y(j+1);
                end
            end
        end
    end
    
    probs=bins/numData;
    expIQR=flyVacIQR(probs,'pdf', 'IQR');
    obsIQR=flyVacIQR(histData,'pdf', 'IQR');
    
    resampleHistoryVBE(iter)=log2((obsIQR(2)-obsIQR(1))/(expIQR(2)-expIQR(1)));
    
    x_i=((1:numBins)-1)';
    N=size(orig_data,1);
    mu=sum(x_i.*bins/N);
    expStd= sqrt(sum((bins/N).*(x_i-mu).^2));
    scores=40*nanmean(((data+1)/2),2);
    obsStd=sqrt(var(scores));
    
    resampleHistorySDR(iter)=log2(obsStd/expStd);
    histData=histData';
    %     obsMoments(1)=sum(histData(1:floor(40*p)).*((0:floor(40*p)-1)/40)')/sum(histData(1:floor(40*p)));
    %     obsMoments(2)=sum(histData(ceil(40*p):40).*((ceil(40*p):40)/40)')/sum(histData(ceil(40*p):40));
    %     expMoments(1)=sum(probs(1:floor(40*p)).*((0:floor(40*p)-1)/40)')/sum(probs(1:floor(40*p)));
    %     expMoments(2)=sum(probs(ceil(40*p):40).*((ceil(40*p):40)/40)')/sum(probs(ceil(40*p):40));
    %     resampleHistoryMOM(iter)=log2((obsMoments(2)-obsMoments(1))/(expMoments(2)-expMoments(1)));
    
    IPRTemp=flyVacIQR(probs,'pdf', 'IPR');
    numPercs=length(IPRTemp);
    expIPR=mean(flipud(IPRTemp(((numPercs-1)/2+2):numPercs))-IPRTemp(1:((numPercs-1)/2)));
    IPRTemp=flyVacIQR(histData,'pdf', 'IPR');
    obsIPR=mean(flipud(IPRTemp(((numPercs-1)/2+2):numPercs))-IPRTemp(1:((numPercs-1)/2)));
    resampleHistoryIPRR(iter)=log2(obsIPR/expIPR);
    resampleHistoryIPRR2(iter)=(log2(obsIPR/expIPR))^2;
end

out.VBEvalues=resampleHistoryVBE(1:end-1);
out.VBE=resampleHistoryVBE(end);
out.VBEstd=std(resampleHistoryVBE(1:end-1));
out.VBEmean=mean(resampleHistoryVBE(1:end-1));
out.VBEz=(out.VBE)/out.VBEstd;
out.VBEp=1-normcdf(out.VBEz,0,1);

out.SDRvalues=resampleHistorySDR(1:end-1);
out.SDR=resampleHistorySDR(end);
out.SDRstd=std(resampleHistorySDR(1:end-1));
out.SDRmean=mean(resampleHistorySDR(1:end-1));
out.SDRz=(out.SDR)/out.SDRstd;
out.SDRp=1-normcdf(out.SDRz,0,1);

out.IPRRvalues=resampleHistoryIPRR(1:end-1);
out.IPRR=resampleHistoryIPRR(end);
out.IPRRstd=std(resampleHistoryIPRR(1:end-1));
out.IPRR2std=std(resampleHistoryIPRR2(1:end-1));
out.IPRRmean=mean(resampleHistoryIPRR(1:end-1));
out.IPRRz=(out.IPRR)/out.IPRRstd;
out.IPRRp=1-normcdf(out.IPRRz,0,1);


% out.MOMvalues=resampleHistoryMOM(1:end-1);
% out.MOM=resampleHistoryMOM(end);
% out.MOMstd=std(resampleHistoryMOM(1:end-1));
% out.MOMmean=mean(resampleHistoryMOM(1:end-1));
% out.MOMz=(out.MOM)/out.MOMstd;
% out.MOMp=1-normcdf(out.MOMz,0,1);

sound(.25*sin(1:.5:150))