function [r]=decPlotLinRegression(x,y)

mX=nanmean(x);
mY=nanmean(y);
mXY=nanmean(x.*y);
mX2=nanmean(x.^2);
m=(mX*mY-mXY)/(mX^2-mX2);
b=mY-m*mX;

fitLine=[b m+b];
hold on
plot(fitLine,'-r');
legend(strcat('r = ',num2str(m)),'Location','northwest');
axis([0 1 0 1]);
scatter(x,y,'b');
hold off


% Output the slope of the line
r=m;