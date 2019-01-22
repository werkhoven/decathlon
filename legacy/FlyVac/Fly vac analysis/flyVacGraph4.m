function flyVacGraph4(data)


height=0.7;
figure;
hold on;
for i=1:size(data,1)
    rectangle('Position',[data(i,6) data(i,4) height data(i,5)-data(i,4)],'FaceColor','b');
    rectangle('Position',[data(i,6) data(i,2) height data(i,3)-data(i,2)],'FaceColor','c');
    rectangle('Position',[data(i,6) data(i,1) height 0.00000001],'FaceColor','k');
end