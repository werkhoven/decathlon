figure();
hold on
for i=1:length(pooldat)
    for j=1:length(pooldat(i).(f).bias)
        plot(pooldat(i).(f).bias(:,j));
    end
end

%% 

d1 = pooldat(1).(f).bias;
d2 = pooldat(3).(f).bias;
d3 = pooldat(2).(f).bias;
d4 = pooldat(4).(f).bias;

d1(~pooldat(1).(f).active)=NaN;
d2(~pooldat(3).(f).active)=NaN;
d3(~pooldat(2).(f).active)=NaN;
d4(~pooldat(4).(f).active)=NaN;

%%

g1 = [d1 d3];
g2 = [d2 d4];

con = pooldat(1).(f).values';
slope1=NaN(96,1);
int1=NaN(96,1);

for i=1:96
    tmp = g1(:,i);
    %tmp = tmp(~isnan(tmp));
    if ~any(isnan(tmp))
        p=polyfit(con,tmp,1);
        slope1(i)=p(1);
        int1(i)=p(2);
    end
end


slope2=NaN(96,1);
int2=NaN(96,1);

for i=1:96
    tmp = g2(:,i);
    %tmp = tmp(~isnan(tmp));
    if ~any(isnan(tmp))
        p=polyfit(con,tmp,1);
        slope2(i)=p(1);
        int2(i)=p(2);
    end
end

[r_slope,p_slope]=corrcoef([slope1 slope2],'rows','pairwise');
[r_int,p_int]=corrcoef([int1 int2],'rows','pairwise');

disp([f ' psychometric curve slope (r=' num2str(r_slope(1,2)) ', p=' num2str(p_slope(1,2)) ')']);
disp([f ' psychometric curve intercept (r=' num2str(r_int(1,2)) ', p=' num2str(p_int(1,2)) ')']);

