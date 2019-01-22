function out=handGetExpGroup(allHandData,which,varargin)

    searchString=allHandData{1,5};
    count=0;
    while isequal(class(searchString),'cell') && count<10
        searchString=searchString{1};
        count=count+1;
    end
    
if length(varargin)>=1
    colNum=varargin{1};
else
    if isequal(class(searchString),'char')
        colNum=5;
    else
        warning('no cell found in column 5, assuming experimental group label is in column 7');
        colNum=7;
    end
end

disp(['looking for labels in column ' num2str(colNum)]);

temp={};



for i=1:size(allHandData,1)
    searchString=allHandData{i,colNum};
    count=0;
    while isequal(class(searchString),'cell') && count<10
        searchString=searchString{1};
        count=count+1;
    end
    
    searchVector=allHandData{i,end};
    count=0;
    while isequal(class(searchVector),'cell') && count<10
        searchVector=searchVector{1};
        count=count+1;
    end
    
    if isequal(searchString,which) && length(allHandData{i,end})>50
        temp=[temp;allHandData(i,:)];
    end
end

out=temp;