
nRow=9;
nCol=8;
rect_W=178;
rect_H=118;
i=0;

stimProps=optoInitializeBlackWhiteStim(nRow,nCol,rect_W,rect_H);
stimOFF=boolean(zeros(size(stimProps.dsRects,2),1));
stimProps.angle(:)=115;

while ~KbCheck
    
    %{
    i=i+1;
    i=mod(i,72);
    pause(0.5);
    stimProps.angle(i)=66;
    
    if i>1
        stimOFF(i-1)=~stimOFF(i-1);
    end
    %}
    
    stimProps=optoDispBlackWhiteStim(stimProps,stimOFF);
    
    changeAngle=rand(size(stimProps.angle,1),1)>0.997;
    rndAngle=rand(size(stimProps.angle,1),1);
    newAngle=zeros(size(stimProps.angle,1),1);
    newAngle(rndAngle<(1/6))=0;
    newAngle(rndAngle>(1/6)&rndAngle<=(2/6))=66;
    newAngle(rndAngle>(2/6)&rndAngle<=(3/6))=113;
    newAngle(rndAngle>(3/6)&rndAngle<=(4/6))=180;
    newAngle(rndAngle>(4/6)&rndAngle<=(5/6))=246;
    newAngle(rndAngle>(5/6)&rndAngle<=(6/6))=293;
    stimProps.angle(changeAngle)=newAngle(changeAngle);
    
   
end

sca