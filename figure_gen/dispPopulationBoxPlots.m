boxplot(data','Notch','on','Orientation','horizontal','Labels',labelNames);
title('LED Y-maze Population Data - Light Choice Probability');
axis([0 1 0 size(data',2)+1])