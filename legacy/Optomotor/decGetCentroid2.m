function [props,imagedata]=decGetCentroid2(vid,current_Reference,current_Thresh,propFields)
imagedata=peekdata(vid,1);
imagedata=current_Reference-imagedata(:,:,1);
props=regionprops((imagedata>current_Thresh),propFields);
end


