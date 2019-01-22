line1 = [63:92];
line2 = [];
line3 = [];
line4 = [];
total_size = length(line1) + length(line2) + length(line3) + length(line4);

strain = 'BkF24_';
j = 0;

for i = 1:total_size
    j = j+1;
    flyData(j).ID = strcat(strain,num2str(line1(i)));
end

%{
strain = 'isoKH2-';

for i = 1:length(KH2)
    j = j+1;
    flyData(j).ID = strcat(strain,num2str(KH2(i)));
end

strain = 'isoKH3-';

for i = 1:length(KH3)
    j = j+1;
    flyData(j).ID = strcat(strain,num2str(KH3(i)));
end

strain = 'isoKH4-';

for i = 1:length(KH4)
    j = j+1;
    flyData(j).ID = strcat(strain,num2str(KH4(i)));
end
%}
