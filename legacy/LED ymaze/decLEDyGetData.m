function [cenDat,ledDat,lightseq,turnseq]=decLEDyGetData
[fName,fDir,fFilter] = uigetfile('*.txt;*','Open data file','C:\Users\OEB131-B\Desktop\LED ymaze data');
path=strcat(fDir,fName);

periods=find(path=='.');
pathname=path(1:periods(1)-1);

centroidPath=[pathname '.cen.txt'];
ledPath=[pathname '.led.txt'];
lightSeqPath=[pathname '.lightseq.txt'];
turnSeqPath=[pathname '.turnseq.txt'];
cenDat=importdata(centroidPath);
ledDat=importdata(ledPath);
lightseq=importdata(lightSeqPath);
turnseq=importdata(turnSeqPath);