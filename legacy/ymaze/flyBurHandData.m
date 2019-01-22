function out=flyBurHandData(data,numFlies,roi)

%flyBurHandData(data,roi)

    out=[];

for j=1:numFlies
    
    inx=data(:,2*j+1);
    iny=data(:,2*j+2);
    width=roi;
    
    out(j).x=inx;
    out(j).y=iny;
    out(j).r=sqrt((inx-width/2).^2+(iny-width/2).^2);
    out(j).theta=atan2(iny-width/2,inx-width/2);
    
    out(j).direction=zeros(size(inx,1),1);
    out(j).speed=zeros(size(inx,1),1);
    out(j).turning=zeros(size(inx,1),1);
    
    for i=1:size(inx,1)-1;
        if mod(i,1000) ==1
        end
        
        if i > 1
            out(j).direction(i)=atan2(iny(i)-iny(i-1),inx(i)-inx(i-1));
            out(j).speed(i)=sqrt((iny(i)-iny(i-1))^2+(inx(i)-inx(i-1))^2);
            if i>2
                out(j).turning(i)=out(j).direction(i)-out(j).direction(i-1);
                if out(j).turning(i) >pi()
                    out(j).turning(i)=out(j).turning(i)-2*pi();
                end
                if out(j).turning(i) < -pi()
                    out(j).turning(i)=out(j).turning(i)+2*pi();
                end
            end
        end             
    end
    out(j).speed(out(j).speed>12)=NaN;
end

