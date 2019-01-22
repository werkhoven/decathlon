function flyVacGraph3(data)

height=0.7;
figure;
hold on;
for i=1:size(data,1)
    rectangle('Position',[data(i,4) i data(i,5)-data(i,4) height],'FaceColor','b');
    rectangle('Position',[data(i,2) i data(i,3)-data(i,2) height],'FaceColor','c');
    rectangle('Position',[data(i,1) i 0.0000001 height],'FaceColor','k');
end