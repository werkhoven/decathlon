function out=flyVacMedian(data,datatype)

if min(datatype=='raw')==1
    
    out=median(data);
end

if min(datatype=='pdf')==1
    
    choices=length(data)-1;
    cumdata=zeros(size(data));
    for i=1:length(data)
        cumdata(i)=sum(data(1:i));
    end
    
    for i=1:length(data)-1
        if cumdata(i) <= 0.25 && cumdata(i+1)> 0.25
            q1=i;
        end
        if cumdata(i) <= 0.5 && cumdata(i+1)> 0.5
            q2=i;
        end
        if cumdata(i) <= 0.75 && cumdata(i+1)> 0.75
            q3=i;
            break;
        end
        
        
    end

    Q1=(cumdata(q1+1)-0.25)/(cumdata(q1+1)-cumdata(q1))*((q1-1)/choices) + (0.25-cumdata(q1))/(cumdata(q1+1)-cumdata(q1))*(q1/choices);
    Q3=(cumdata(q3+1)-0.75)/(cumdata(q3+1)-cumdata(q3))*((q3-1)/choices) + (0.75-cumdata(q3))/(cumdata(q3+1)-cumdata(q3))*(q3/choices);
    Q2=(cumdata(q2+1)-0.5)/(cumdata(q2+1)-cumdata(q2))*((q2-1)/choices) + (0.5-cumdata(q2))/(cumdata(q2+1)-cumdata(q2))*(q2/choices);
    
    out=Q2+1/(2*choices);
    
end