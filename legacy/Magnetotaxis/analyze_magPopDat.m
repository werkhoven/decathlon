% Analyze magneto popData

%% magneto
%{
fDat1=femalesPopulationMagnetsInitial;
fDat2N=femalesNorthRetest;
fDat2S=femalesSouthRetest;
fDat3N=femalesNorthReretest;
fDat3S=femalesSouthReretest;

disp('Northies')
Totals1=sum(fDat1(:,1:2))
Totals1/sum(sum(fDat1(:,1:2)))
Totals2N=sum(fDat2N(:,1:2))
Totals2N/sum(sum(fDat2N(:,1:2)))
Totals3N=sum(fDat3N(:,1:2))
Totals3N/sum(sum(fDat3N(:,1:2)))

disp('Southies')
Totals1=sum(fDat1(:,1:2))
Totals1/sum(sum(fDat1(:,1:2)))
Totals2S=sum(fDat2S(:,1:2))
Totals2S/sum(sum(fDat2S(:,1:2)))
Totals3S=sum(fDat3S(:,1:2))
Totals3S/sum(sum(fDat3S(:,1:2)))

nSims=500000;
nReps=sum(sum(fDat1(:,1:2)));
bias=sum(rand(nReps,nSims)>0.5)/nReps;
bins=linspace(min(bias),max(bias),1001);
histogram=histc(bias,bins)/sum(histc(bias,bins));
plot(bins,histogram)
set(gca,'Xtick',bins(1:100:1001),'XtickLabel',bins(1:100:1001))

tail1=b(1);
nStd=abs(mean(bias)-tail1)/std(bias);
tail2=mean(bias)-nStd*std(bias);

[val,i1]=min(abs(tail1-bins));
[val,i2]=min(abs(tail2-bins));

p=sum(histogram([1:i2 i1:end]))

%}

%% Control

magData.malesInitial=malesInitial;
magData.malesNRetest=malesNRetest;
magData.malesNReretest=malesNReretest;
magData.malesSRetest=malesSRetest;
magData.malesSReretest=malesSReretest;

magData.femalesInitial=femalesInitial;
magData.femalesNRetest=femalesNRetest;
magData.femalesNReretest=femalesNReretest;
magData.femalesSRetest=femalesSRetest;
magData.femalesSReretest=femalesSReretest;

magData.totalsInitial=sum(malesInitial)+sum(femalesInitial);
magData.totalsNRetest=sum(malesNRetest)+sum(femalesNRetest);
magData.totalsNReretest=sum(malesNReretest)+sum(femalesNReretest);
magData.totalsSRetest=sum(malesSRetest)+sum(femalesSRetest);
magData.totalsSReretest=sum(malesSReretest)+sum(femalesSReretest);

males=cell(6,5);
males(1,:)={'Exp. Group';'North';'South';'p-value';'N'};
females=cell(6,5);
females(1,:)={'Exp. Group';'North';'South';'p-value';'N'};
totals=cell(6,5);
totals(1,:)={'Exp. Group';'North';'South';'p-value';'N'};

%% Males initial
a=sum(magData.malesInitial);
b=sum(magData.malesInitial)/sum(sum(magData.malesInitial));

%%

nSims=500000;
nReps=sum(a);
bias=sum(rand(nReps,nSims)>0.5)/nReps;
bins=linspace(min(bias),max(bias),1001);
histogram=histc(bias,bins)/sum(histc(bias,bins));
plot(bins,histogram)
set(gca,'Xtick',bins(1:100:1001),'XtickLabel',bins(1:100:1001))

tail1=b(1);
nStd=abs(mean(bias)-tail1)/std(bias);
tail2=mean(bias)+nStd*std(bias);

[val,i1]=min(abs(tail1-bins));
[val,i2]=min(abs(tail2-bins));

p=sum(histogram([1:i1 i2:end]));
males(2,:)={'Initial',b(1),b(2),p,sum(a)};
    

%% Males North Retest
a=sum(magData.malesNRetest);
b=sum(magData.malesNRetest)/sum(sum(magData.malesNRetest));

%%

nSims=500000;
nReps=sum(a);
bias=sum(rand(nReps,nSims)>0.5)/nReps;
bins=linspace(min(bias),max(bias),1001);
histogram=histc(bias,bins)/sum(histc(bias,bins));
plot(bins,histogram)
set(gca,'Xtick',bins(1:100:1001),'XtickLabel',bins(1:100:1001))

tail1=b(1);
nStd=abs(mean(bias)-tail1)/std(bias);
tail2=mean(bias)-nStd*std(bias);

[val,i1]=min(abs(tail1-bins));
[val,i2]=min(abs(tail2-bins));

p=sum(histogram([1:i2 i1:end]));
males(3,:)={'North-1',b(1),b(2),p,sum(a)};

%% Males North Reretest
a=sum(magData.malesNReretest);
b=sum(magData.malesNReretest)/sum(sum(magData.malesNReretest));

%%

nSims=500000;
nReps=sum(a);
bias=sum(rand(nReps,nSims)>0.5)/nReps;
bins=linspace(min(bias),max(bias),1001);
histogram=histc(bias,bins)/sum(histc(bias,bins));
plot(bins,histogram)
set(gca,'Xtick',bins(1:100:1001),'XtickLabel',bins(1:100:1001))

tail1=b(1);
nStd=abs(mean(bias)-tail1)/std(bias);
tail2=mean(bias)-nStd*std(bias);

[val,i1]=min(abs(tail1-bins));
[val,i2]=min(abs(tail2-bins));

p=sum(histogram([1:i2 i1:end]));
males(4,:)={'North-2',b(1),b(2),p,sum(a)};

%% Males South Retest
a=sum(magData.malesSRetest);
b=sum(magData.malesSRetest)/sum(sum(magData.malesSRetest));

%%

nSims=500000;
nReps=sum(a);
bias=sum(rand(nReps,nSims)>0.5)/nReps;
bins=linspace(min(bias),max(bias),1001);
histogram=histc(bias,bins)/sum(histc(bias,bins));
plot(bins,histogram)
set(gca,'Xtick',bins(1:100:1001),'XtickLabel',bins(1:100:1001))

tail1=b(1);
nStd=abs(mean(bias)-tail1)/std(bias);
tail2=mean(bias)+nStd*std(bias);

[val,i1]=min(abs(tail1-bins));
[val,i2]=min(abs(tail2-bins));

p=sum(histogram([1:i1 i2:end]));
males(5,:)={'South-1',b(1),b(2),p,sum(a)};

%% Males South Reretest
a=sum(magData.malesSReretest);
b=sum(magData.malesSReretest)/sum(sum(magData.malesSReretest));

%%

nSims=500000;
nReps=sum(a);
bias=sum(rand(nReps,nSims)>0.5)/nReps;
bins=linspace(min(bias),max(bias),1001);
histogram=histc(bias,bins)/sum(histc(bias,bins));
plot(bins,histogram)
set(gca,'Xtick',bins(1:100:1001),'XtickLabel',bins(1:100:1001))

tail1=b(1);
nStd=abs(mean(bias)-tail1)/std(bias);
tail2=mean(bias)-nStd*std(bias);

[val,i1]=min(abs(tail1-bins));
[val,i2]=min(abs(tail2-bins));

p=sum(histogram([1:i2 i1:end]));
males(6,:)={'South-2',b(1),b(2),p,sum(a)};

%% Females Initial
a=sum(magData.femalesInitial);
b=sum(magData.femalesInitial)/sum(sum(magData.femalesInitial));

%%

nSims=500000;
nReps=sum(a);
bias=sum(rand(nReps,nSims)>0.5)/nReps;
bins=linspace(min(bias),max(bias),1001);
histogram=histc(bias,bins)/sum(histc(bias,bins));
plot(bins,histogram)
set(gca,'Xtick',bins(1:100:1001),'XtickLabel',bins(1:100:1001))

tail1=b(1);
nStd=abs(mean(bias)-tail1)/std(bias);
tail2=mean(bias)+nStd*std(bias);

[val,i1]=min(abs(tail1-bins));
[val,i2]=min(abs(tail2-bins));

p=sum(histogram([1:i1 i2:end]));
females(2,:)={'Initial',b(1),b(2),p,sum(a)};


%% Females North Retest
a=sum(magData.femalesNRetest);
b=sum(magData.femalesNRetest)/sum(sum(magData.femalesNRetest));

%% 

nSims=500000;
nReps=sum(a);
bias=sum(rand(nReps,nSims)>0.5)/nReps;
bins=linspace(min(bias),max(bias),1001);
histogram=histc(bias,bins)/sum(histc(bias,bins));
plot(bins,histogram)
set(gca,'Xtick',bins(1:100:1001),'XtickLabel',bins(1:100:1001))

tail1=b(1);
nStd=abs(mean(bias)-tail1)/std(bias);
tail2=mean(bias)+nStd*std(bias);

[val,i1]=min(abs(tail1-bins));
[val,i2]=min(abs(tail2-bins));

p=sum(histogram([1:i1 i2:end]));
females(3,:)={'North-1',b(1),b(2),p,sum(a)};

%% Females North Reretest
a=sum(magData.femalesNReretest);
b=sum(magData.femalesNReretest)/sum(sum(magData.femalesNReretest));

%%

nSims=500000;
nReps=sum(a);
bias=sum(rand(nReps,nSims)>0.5)/nReps;
bins=linspace(min(bias),max(bias),1001);
histogram=histc(bias,bins)/sum(histc(bias,bins));
plot(bins,histogram)
set(gca,'Xtick',bins(1:100:1001),'XtickLabel',bins(1:100:1001))

tail1=b(1);
nStd=abs(mean(bias)-tail1)/std(bias);
tail2=mean(bias)-nStd*std(bias);

[val,i1]=min(abs(tail1-bins));
[val,i2]=min(abs(tail2-bins));

p=sum(histogram([1:i2 i1:end]));
females(4,:)={'North-2',b(1),b(2),p,sum(a)};

%% Females South Retest
a=sum(magData.femalesSRetest);
b=sum(magData.femalesSRetest)/sum(sum(magData.femalesSRetest));

%%

nSims=500000;
nReps=sum(a);
bias=sum(rand(nReps,nSims)>0.5)/nReps;
bins=linspace(min(bias),max(bias),1001);
histogram=histc(bias,bins)/sum(histc(bias,bins));
plot(bins,histogram)
set(gca,'Xtick',bins(1:100:1001),'XtickLabel',bins(1:100:1001))

tail1=b(1);
nStd=abs(mean(bias)-tail1)/std(bias);
tail2=mean(bias)+nStd*std(bias);

[val,i1]=min(abs(tail1-bins));
[val,i2]=min(abs(tail2-bins));

p=sum(histogram([1:i1 i2:end]));
females(5,:)={'South-1',b(1),b(2),p,sum(a)};

%% Females South Reretest
a=sum(magData.femalesSReretest);
b=sum(magData.femalesSReretest)/sum(sum(magData.femalesSReretest));

%%

nSims=500000;
nReps=sum(a);
bias=sum(rand(nReps,nSims)>0.5)/nReps;
bins=linspace(min(bias),max(bias),1001);
histogram=histc(bias,bins)/sum(histc(bias,bins));
plot(bins,histogram)
set(gca,'Xtick',bins(1:100:1001),'XtickLabel',bins(1:100:1001))

tail1=b(1);
nStd=abs(mean(bias)-tail1)/std(bias);
tail2=mean(bias)+nStd*std(bias);

[val,i1]=min(abs(tail1-bins));
[val,i2]=min(abs(tail2-bins));

p=sum(histogram([1:i1 i2:end]));
females(6,:)={'South-2',b(1),b(2),p,sum(a)};

%% TOTALS initial
a=magData.totalsInitial;
b=magData.totalsInitial/sum(magData.totalsInitial);

%%

nSims=500000;
nReps=sum(a);
bias=sum(rand(nReps,nSims)>0.5)/nReps;
bins=linspace(min(bias),max(bias),1001);
histogram=histc(bias,bins)/sum(histc(bias,bins));
plot(bins,histogram)
set(gca,'Xtick',bins(1:100:1001),'XtickLabel',bins(1:100:1001))

tail1=b(1);
nStd=abs(mean(bias)-tail1)/std(bias);
tail2=mean(bias)+nStd*std(bias);

[val,i1]=min(abs(tail1-bins));
[val,i2]=min(abs(tail2-bins));

p=sum(histogram([1:i1 i2:end]));
totals(2,:)={'Initial',b(1),b(2),p,sum(a)};

%% TOTALS North Retest
a=magData.totalsNRetest;
b=magData.totalsNRetest/sum(magData.totalsNRetest);

%%

nSims=500000;
nReps=sum(a);
bias=sum(rand(nReps,nSims)>0.5)/nReps;
bins=linspace(min(bias),max(bias),1001);
histogram=histc(bias,bins)/sum(histc(bias,bins));
plot(bins,histogram)
set(gca,'Xtick',bins(1:100:1001),'XtickLabel',bins(1:100:1001))

tail1=b(1);
nStd=abs(mean(bias)-tail1)/std(bias);
tail2=mean(bias)+nStd*std(bias);

[val,i1]=min(abs(tail1-bins));
[val,i2]=min(abs(tail2-bins));

p=sum(histogram([1:i1 i2:end]));
totals(3,:)={'North-1',b(1),b(2),p,sum(a)};

%% TOTALS North Reretest
a=magData.totalsNReretest;
b=magData.totalsNReretest/sum(magData.totalsNReretest);

%%

nSims=500000;
nReps=sum(a);
bias=sum(rand(nReps,nSims)>0.5)/nReps;
bins=linspace(min(bias),max(bias),1001);
histogram=histc(bias,bins)/sum(histc(bias,bins));
plot(bins,histogram)
set(gca,'Xtick',bins(1:100:1001),'XtickLabel',bins(1:100:1001))

tail1=b(1);
nStd=abs(mean(bias)-tail1)/std(bias);
tail2=mean(bias)-nStd*std(bias);

[val,i1]=min(abs(tail1-bins));
[val,i2]=min(abs(tail2-bins));

p=sum(histogram([1:i2 i1:end]));
totals(4,:)={'North-2',b(1),b(2),p,sum(a)};

%% TOTALS South Retest
a=magData.totalsSRetest;
b=magData.totalsSRetest/sum(magData.totalsSRetest);

%%

nSims=500000;
nReps=sum(a);
bias=sum(rand(nReps,nSims)>0.5)/nReps;
bins=linspace(min(bias),max(bias),1001);
histogram=histc(bias,bins)/sum(histc(bias,bins));
plot(bins,histogram)
set(gca,'Xtick',bins(1:100:1001),'XtickLabel',bins(1:100:1001))

tail1=b(1);
nStd=abs(mean(bias)-tail1)/std(bias);
tail2=mean(bias)+nStd*std(bias);

[val,i1]=min(abs(tail1-bins));
[val,i2]=min(abs(tail2-bins));

p=sum(histogram([1:i1 i2:end]));
totals(5,:)={'South-1',b(1),b(2),p,sum(a)};

%% TOTALS South Reretest
a=magData.totalsSReretest;
b=magData.totalsSReretest/sum(magData.totalsSReretest);

%%

nSims=500000;
nReps=sum(a);
bias=sum(rand(nReps,nSims)>0.5)/nReps;
bins=linspace(min(bias),max(bias),1001);
histogram=histc(bias,bins)/sum(histc(bias,bins));
plot(bins,histogram)
set(gca,'Xtick',bins(1:100:1001),'XtickLabel',bins(1:100:1001))

tail1=b(1);
nStd=abs(mean(bias)-tail1)/std(bias);
tail2=mean(bias)-nStd*std(bias);

[val,i1]=min(abs(tail1-bins))
[val,i2]=min(abs(tail2-bins))

p=sum(histogram([1:i2 i1:end]));
totals(6,:)={'South-2',b(1),b(2),p,sum(a)};

%% Display tables

males
females
totals
