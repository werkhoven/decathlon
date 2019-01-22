function flyvacgraph2(data)

height=0.7;

for i=1:size(data,1)
    rectangle('Position',[data(i,1)-2*data(i,3) i 4*data(i,3) height],'FaceColor','b');
    rectangle('Position',[data(i,1)-2*data(i,2) i 4*data(i,2) height],'FaceColor','c');
    rectangle('Position',[data(i,1) i 0.001 height],'FaceColor','k');
end