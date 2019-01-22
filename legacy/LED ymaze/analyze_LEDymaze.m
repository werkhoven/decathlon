[fName,path,fIndex]=uigetfile('C:\Users\OEB131-B\Desktop\LED ymaze data\');
periods=find(fName=='.');
fName=fName(1:periods(1)-1);
extensions={'.cen' '.led' '.lightseq' '.turnseq'};

cenData=dlmread(strcat(path,fName,extensions{1},'.txt'));
ledStatus=dlmread(strcat(path,fName,extensions{2},'.txt'));
lightSeq=dlmread(strcat(path,fName,extensions{3},'.txt'));
turnSeq=dlmread(strcat(path,fName,extensions{4},'.txt'));

nFlies=floor(size(cenData,2)/2);
expStart=find(cenData(:,1)==0);
cenData(1:expStart(2)-1,:)=[];
ledStatus(1:expStart(2)-1,:)=[];
lightSeq(1:expStart(2)-1,:)=[];
turnSeq(1:expStart(2)-1,:)=[];
flyLights=[];
rowOri=[1 0 1 0 1 0 1 0 1 0];
mazeOri=boolean([rowOri 1 rowOri rowOri rowOri rowOri rowOri rowOri 1]);

for i=1:nFlies
    % Calculate light choice probability
    flyLights(i).lightSeq=lightSeq(~isnan(lightSeq(:,i+1)),i+1);
    flyLights(i).lightProb=mean(flyLights(i).lightSeq);
    
    %Calculate turn probability
    flyLights(i).turnSeq=turnSeq(~isnan(turnSeq(:,i*2)),i*2:i*2+1);
    tDiff=flyLights(i).turnSeq(:,1)-flyLights(i).turnSeq(:,2);
    tRight=NaN(size(flyLights(i).turnSeq,1),1);
    tRight(tDiff==-1||tDiff==2)=0;
    tRight(tDiff==1||tDiff==-2)=1;
    if(~mazeOri(i))
        tRight=~tRight;
    end
    flyLights(i).rightSeq=tRight;
    flyLights(i).rightProb=mean(flyLights(i).rightSeq);          
end

