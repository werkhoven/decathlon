function out=flyVacSimPTSD(data)

samplingVar=0.0064;
AobsVar=0.0255;
BobsVar=0.0342;
AundVar=AobsVar-samplingVar;
BundVar=BobsVar-samplingVar;
distMean=.355;

numFlies=400;

A=randn(numFlies,1)*(AundVar^0.5);
% B=A*(BundVar^0.5)/(AundVar^0.5);
B=A+randn(numFlies,1)*((BundVar-AundVar)^0.5);
A=A+randn(numFlies,1)*(samplingVar^0.5)+distMean;
B=B+randn(numFlies,1)*(samplingVar^0.5)+distMean;


   figure
   scatter(A,B)