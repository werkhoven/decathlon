function out=flyVacANOVAbootstrap(data,N)

nVect=[77 75 63 101 79 67 74 56 66 54 64 91 72 81];

numData=size(data,1);

FValues=zeros(N,1);

totalCalcs=N*14;
calcsDone=0;

H=waitbar(0);

for i=1:N
    
    dataAll=cell(14,1);
    VBEs=zeros(14,1);
    
    for j=1:14
        which=ceil(rand(nVect(j),1)*numData);
        tempData=data(which,:);
        %         flyVacResults=flyVacAnalysis(tempData,1,0);
        VBEs(j)=flyVacIPRR(tempData);
        calcsDone=calcsDone+1;
        waitbar(calcsDone/totalCalcs, H, [num2str(i) ' of ' num2str(N)] );
    end
    FValues(i)=sum(VBEs-0.9856)/14;
    
end


out=FValues;