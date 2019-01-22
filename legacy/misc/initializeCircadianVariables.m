[fName,fDir,fFilter] = uigetfile('*.txt;*','Open data file',...
    'E:\Decathlon Raw Data');

delim=find(fName=='_');
delim=delim(end);
fName(delim+1:end)=[];
cenID=strcat(fDir,fName,'Centroid.dat');
motorID=strcat(fDir,fName,'Motor.dat');
labelID=strcat(fDir,fName,'labels.dat');
areaID=strcat(fDir,fName,'Area.dat');

tON=[9 0];
tOFF=[21 0];

delim=find(fName=='-');
tmp=fName;
tmp(delim(end)+3:end)=[];
delim=[delim(1) diff(delim)];
delim=[delim length(tmp)-sum(delim)+1];
tStart=NaN(1,6);
for i=1:length(delim)
    tStart(i)=str2num(tmp(1:delim(i)-1));
    if i<length(delim)
    tmp(1:delim(i))=[];
    end
end