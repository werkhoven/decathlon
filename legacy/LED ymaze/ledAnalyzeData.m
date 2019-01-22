function [flyLights,meanLightPref,numChoices]=ledAnalyzeData(flyLights)
numFlies=size(flyLights,2);
numChoices=NaN(numFlies,1);
bs=NaN(numFlies,1);


for i=1:size(flyLights,2)
    
    numChoices(i)=size(flyLights(i).lightChoiceSeq,1);
    simChoices=round(rand(round(numChoices(i)),1));
    bs(i)=mean(simChoices);
    
end

inactive=numChoices<150;
flyLights(inactive)=[];
bs(inactive)=[];
numFlies=size(flyLights,2);
meanLightPref=nanmean([flyLights.lightProb]);

numChoices=mean(numChoices);
obs=squeeze([flyLights.lightProb]);
bins=linspace(0.3,0.7,20);
hGramBS=histc(bs,bins);
hGramBS=hGramBS./sum(hGramBS);
hGramOBS=histc(obs,bins);
hGramOBS=hGramOBS./sum(hGramOBS);
plot(hGramBS,'b','Linew',2);
hold on
plot(hGramOBS,'r','Linew',2);
set(gca,'Xtick',1:2:length(bins),'XtickLabel',bins(1:2:length(bins)));