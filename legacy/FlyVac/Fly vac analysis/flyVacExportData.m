varList=who;

allData=[];

for indexNumber=1:length(varList)
   
    eval(['temp=' varList{indexNumber} ';']);
    numRows=size(temp,1);
    numCols=size(temp,2);
    tempMatrix=num2cell(temp);
    varLabels=cell(numRows,1);
    varLabels(:)=varList(indexNumber);
    tempMatrix=[varLabels tempMatrix];
    allData=[allData;tempMatrix];
end

clear varList;
clear temp;
clear tempMatrix;
clear numRows;
clear numCols;
clear varLabels;
clear indexNumber;
clear ans;
