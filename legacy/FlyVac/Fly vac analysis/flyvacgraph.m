function flyVacGraph(data)


probUpper95=data(:,2)+data(:,3);
probLower95=data(:,2)-data(:,3);
% probUpper95=data(:,2)+2*data(:,3);
% probLower95=data(:,2)-2*data(:,3);
probs=data(:,2);
histData=data(:,1);
xvals=1:size(data,1);


    figure
        hold on;
    darkgray=[.65 .65 .65];
    darkblue=[.1 .2 .9];
    blueblue=[.1 .3 1]
    lightgray=[.93 .93 .93];
%     h=bar(probUpper95, 'hist')
%     set(h,'EdgeColor', lightgray);
%     set(h,'FaceColor', lightgray);
%         h=bar(probLower95, 'hist')
%     set(h,'EdgeColor', [1 1 1]);
%     set(h,'FaceColor', [1 1 1]);

    fill(xvals,probUpper95,lightgray,'EdgeColor', lightgray)
        fill(xvals,probLower95,[1 1 1],'EdgeColor', [1 1 1])
    
    plot(probs,'-o', 'LineWidth',3, 'MarkerEdgeColor', darkgray, 'MarkerFaceColor', darkgray, 'MarkerSize', 4, 'Color', darkgray);
    plot(histData,'-o', 'LineWidth',3, 'MarkerEdgeColor', darkblue, 'MarkerFaceColor', blueblue, 'MarkerSize', 4, 'Color', darkblue);
    xlim([0 size(data,1)+1])