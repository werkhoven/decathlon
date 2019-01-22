function permutation=optoMatchROIs2Gabors(binaryimage,ROI_coords)

width=size(binaryimage,2);
height=size(binaryimage,1);

% Separate ROIs from right to left
w=abs(ROI_coords(:,3)-width);
w=w.^2;
[val,xSorted]=sort(w);
numColumns=median(diff(find(diff(val)>std(diff(val))==1)));
xSorted=reshape(xSorted,numColumns,floor(length(ROI_coords)/numColumns));

permutation=[];
for i=1:size(xSorted,2)
h=abs(ROI_coords(xSorted(:,i),4)-height);
h=h.^2;
[val,ySorted]=sort(h);
permutation=[permutation xSorted(ySorted,i)];
end
permutation=permutation(:);
end



