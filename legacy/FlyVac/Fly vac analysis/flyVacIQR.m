function out=flyVacIQR(data,datatype,interval)

if min(datatype=='raw')==1
    
    series=nanmean(data');
    series=sort(series);
    
    N=length(series);
    
    N1=N*0.25;
    N3=N*0.75;
    
    Q1=(N1-floor(N1))*series(floor(N1))+(floor(N1+1)-N1)*series(floor(N1+1));
    Q3=(N3-floor(N3))*series(floor(N3))+(floor(N3+1)-N3)*series(floor(N3+1));
    
    d1=N*0.1;
    d9=N*0.9;
    
    D1=(d1-floor(d1))*series(floor(d1))+(floor(d1+1)-d1)*series(floor(d1+1));
    D9=(d9-floor(d9))*series(floor(d9))+(floor(d9+1)-d9)*series(floor(d9+1));
    
    
    
    if interval == 'IQR'
        out=([Q1 Q3]+1)/2;
    end
    if interval == 'IDR'
        out=([D1 D9]+1)/2;
    end
end

if min(datatype=='pdf')==1
    choices=length(data)-1;
    cumdata=zeros(size(data));
    for i=1:length(data)
        cumdata(i)=nansum(data(1:i));
    end
    
    for i=1:length(data)-1
        
        if cumdata(1) > 0.1
            d1=0;
        else
            if cumdata(i) <= 0.1 && cumdata(i+1)> 0.1
                d1=i;
            end
        end
        
        if cumdata(1)>0.25
            q1=0;
        end

        if cumdata(i) <= 0.25 && cumdata(i+1)> 0.25
            q1=i;
        end
        if cumdata(i) <= 0.5 && cumdata(i+1)> 0.5
            q2=i;
        end
        if cumdata(i) <= 0.75 && cumdata(i+1)> 0.75
            q3=i;
            
        end
  
        if cumdata(i) <= 0.9 && cumdata(i+1)> 0.9
            d9=i;
            break;
        end
        
        
    end
    
    if interval == 'IQR'
        if q1 >0
            Q1=(cumdata(q1+1)-0.25)/(cumdata(q1+1)-cumdata(q1))*((q1-1)/choices) + (0.25-cumdata(q1))/(cumdata(q1+1)-cumdata(q1))*(q1/choices);
        else
            Q1=0;
        end
        Q3=(cumdata(q3+1)-0.75)/(cumdata(q3+1)-cumdata(q3))*((q3-1)/choices) + (0.75-cumdata(q3))/(cumdata(q3+1)-cumdata(q3))*(q3/choices);
        
        out=[Q1 Q3]+1/(2*choices);
    end
    if interval == 'IDR'
        if d1 >0
            D1=(cumdata(d1+1)-0.1)/(cumdata(d1+1)-cumdata(d1))*((d1-1)/choices) + (0.1-cumdata(d1))/(cumdata(d1+1)-cumdata(d1))*(d1/choices);
        else
            D1=0;
        end
        D9=(cumdata(d9+1)-0.9)/(cumdata(d9+1)-cumdata(d9))*((d9-1)/choices) + (0.9-cumdata(d9))/(cumdata(d9+1)-cumdata(d9))*(d9/choices);
        
        out=[D1 D9]+1/(2*choices);
    end
    
    if interval =='IPR'
        percentiles=20;
        percentilePositions=zeros(percentiles-1,1);
        whichPerc=1;
        for j=(1/percentiles):(1/percentiles):(1-1/percentiles); % vary percentile being considered
            for k=1:length(data)-1      %search cdf for that percentile
                if cumdata(1) > j          % already in bin 1?
                    perc=0;
                else
                    if cumdata(k) <= j  && cumdata(k+1)>j
                        perc=k;
                    end
                end
            end
            if perc > 0
                percentilePositions(whichPerc)=(cumdata(perc+1)-j)/(cumdata(perc+1)-cumdata(perc))*((perc-1)/choices) + (j-cumdata(perc))/(cumdata(perc+1)-cumdata(perc))*(perc/choices);
            else
                percentilePositions(whichPerc)=0;
            end
            whichPerc=whichPerc+1;
        end
        
        out=percentilePositions;
        
    end
end






















